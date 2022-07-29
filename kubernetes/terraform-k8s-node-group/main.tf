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

resource "yandex_kubernetes_node_group" "nch-node-group" {
  name = "nch-node-group"
  cluster_id = var.cluster

  scale_policy {
    fixed_scale {
      size = var.scale
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair = true
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  instance_template {
    platform_id = var.platform
    resources {
      cores         = var.cores
      memory        = var.memory
      core_fraction = var.core_fraction
    }

    container_runtime {
      type = "docker"
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      subnet_ids = var.subnets
      nat = true
    }

    boot_disk {
      size = var.disk_size
      type = var.disk_type
    }
  }
}
