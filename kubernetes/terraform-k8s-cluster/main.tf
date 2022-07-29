terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.73.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

// Create a new cluster
resource "yandex_kubernetes_cluster" "nch-cluster" {
  name        = "nch-cluster"
  service_account_id = var.service_account_id
  node_service_account_id = var.node_service_account_id
  release_channel = var.channel
  node_ipv4_cidr_mask_size = 24
  network_id = var.network

  master {
    version = var.master_version
    public_ip = true
    zonal {
      zone = var.zone
    }
    maintenance_policy {
      auto_upgrade = true
    }

  }  

}
