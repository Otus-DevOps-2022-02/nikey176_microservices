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

variable cluster {
  description = "The ID of the Kubernetes cluster that this node group belongs to"
}

variable scale {
  description = "The number of instances in the node group"
  default = 2
}

variable platform {
  description = "The ID of the hardware platform configuration for the instance"
  default = "standard-v2"
}

variable cores {
  description = "Number of CPU cores allocated to the instance"
  default = 2
}

variable memory {
  description = "The memory size allocated to the instance"
  default = 8
}

variable core_fraction {
  description = "Baseline core performance as a percent"
  default = 20
}

variable subnets {
  description = "The IDs of the subnets"
}

variable disk_size {
  description = "The size of the disk in GB"
  default = 64
}

variable disk_type {
  description = "The disk type"
  default = "network-hdd"
}