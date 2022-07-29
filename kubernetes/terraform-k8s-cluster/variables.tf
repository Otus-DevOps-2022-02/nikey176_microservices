variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable "service_account_key_file" {
  description = "key .json"
}
variable service_account_id {
  description = "Service account to be used for provisioning Compute Cloud and VPC resources for Kubernetes cluster"
}

variable node_service_account_id {
  description = "Service account to be used by the worker nodes of the Kubernetes cluster to access Container Registry or to push node logs and metrics"
}

variable network {
  description = "The ID of the cluster network"
}

variable channel {
  description = "Cluster release channel"
  default = "RAPID"
}

variable master_version {
  description = "Version of Kubernetes master"
  default = "1.19"
}