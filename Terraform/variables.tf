
variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
  default     = "nh-aks-rg"
}

variable "location" {
  type        = string
  description = "Resources location in Azure"
  default     = "Israel Central"
}

variable "cluster_name" {
  type        = string
  description = "AKS name in Azure"
  default     = "nh-aks-cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.32.3"
}

variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
  default     = 3
}

variable "node_resource_group" {
  type        = string
  description = "RG name for cluster resources in Azure"
  default     = "nh-aks-node-resources"
}

variable "acr_name" {
  type        = string
  description = "ACR name"
  default     = "nitzanacr"
}

variable "node_count" {
  description = "The number of nodes in the AKS cluster"
  type        = number
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "client_id" {
  type        = string
  description = "Azure service principal client ID"
}

variable "client_secret" {
  type        = string
  description = "Azure service principal client secret"
}
