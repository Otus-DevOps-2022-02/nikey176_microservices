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

resource "yandex_compute_instance" "reddit" {
  name  = "docker-reddit-${count.index + 1}"
  count = var.scale
  labels = {
    tags = "docker-host"
  }

  resources {
    cores         = 4
    memory        = 6
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.docker_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  scheduling_policy {
    preemptible = true
  }

  allow_stopping_for_update = true
  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }

  #  provisioner "remote-exec" {
  #    inline = [
  #      "sudo docker container run --name reddit -d -p 9292:9292 nchernukha/otus-reddit:1.0"
  #    ]
  #  }
}
