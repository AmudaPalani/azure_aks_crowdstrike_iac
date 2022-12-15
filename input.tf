variable "tenant_id" {
  description = "tenant id"
  default     = ""
  type        = string
}

variable "subscription_id" {
  description = "subscription id"
  default     = ""
  type        = string
}

variable "client_id" {
  description = "client id"
  default     = ""
  type        = string
}

variable "client_secret" {
  description = "client secret"
  default     = ""
  type        = string
}

variable "falcon_cid" {
  type = string
  description = "Falcon CID including checksum (00000000000000000000000000000000-00)."

  validation {
    condition     = can(regex("^[0-9a-fA-F]{32}-[0-9a-fA-F]{2}$", var.falcon_cid))
    error_message = "Falcon CID is not correct. Please ensure the CID includes the checksum."
  }
}

variable "falcon_cliend_id" {
  type = string
}

variable "falcon_client_secret" {
  type      = string
  sensitive = true
}

variable "falcon_sensor_token" {
  type      = string
  sensitive = true
}

variable "azure_aks_name" {
  type = string
}

variable "azure_aks_resource_group" {
  type = string
}
