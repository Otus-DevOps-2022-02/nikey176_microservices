variable "public_key_path" {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable "docker_disk_image" {
  description = "Disk image for reddit app in docker"
  default     = "docker-base"
}
variable "subnet_id" {
  description = "Subnets for modules"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}
variable "scale" {
  description = "Number of instances"
  default     = "1"
}
variable "service_account_key_file" {
  description = "key .json"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable "folder_id" {
  description = "Folder"
}
variable "cloud_id" {
  description = "Cloud"
}
