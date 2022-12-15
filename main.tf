data "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = var.azure_aks_name
  resource_group_name = var.azure_aks_resource_group
}

provider "kubernetes" {
    host                   = data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.host
    username               = data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.username
    password               = data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.password
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.host
    username               = data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.username
    password               = data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.password
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.cluster_ca_certificate)
  }
}

locals {
  falcon_ccid = lower(var.falcon_cid)
  falcon_cid  = lower(substr(var.falcon_cid, 0, 32))
}

resource "kubernetes_namespace" "cs-falcon-namespace" {
  metadata {
    name = "falcon-system"
  }
}

resource "kubernetes_secret" "cs-cr-pullsecret" {
  metadata {
    name      = "cs-cr-pullsecret"
    namespace = kubernetes_namespace.cs-falcon-namespace.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "registry.crowdstrike.com" = {
          "username" = "fc-${local.falcon_cid}"
          "password" = "${var.falcon_sensor_token}"
          "auth"     = base64encode("fc-${local.falcon_cid}:${var.falcon_sensor_token}")
        }
      }
    })
  }
}

resource "helm_release" "cs-falcon-sensor" {
  name       = "cs-falcon-sensor"
  chart      = "falcon-sensor"
  repository = "https://crowdstrike.github.io/falcon-helm"
  namespace  = kubernetes_namespace.cs-falcon-namespace.metadata[0].name

  values = [<<-EOF
    falcon:
      cid: ${local.falcon_ccid}
      feature: enableLog
      trace: debug
    node:
      image:
        repository: registry.crowdstrike.com/falcon-sensor/us-1/release/falcon-sensor
        tag: 6.49.0-14604.falcon-linux.x86_64.Release.US-1
        pullSecrets: ${kubernetes_secret.cs-cr-pullsecret.metadata[0].name}
    EOF
  ]
}
