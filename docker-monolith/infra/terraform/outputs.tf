output "external_ip_address_app" {
  value = yandex_compute_instance.reddit[*].network_interface.0.nat_ip_address
}
output "hostname" {
  value = yandex_compute_instance.reddit[*].name
}
