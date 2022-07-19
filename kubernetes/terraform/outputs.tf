output "zone_app" {
  value = yandex_compute_instance.k8s.0.zone
}
output "external_ip_k8s_node_1" {
  value = yandex_compute_instance.k8s.0.network_interface.0.nat_ip_address
}
output "external_ip_k8s_node_2" {
  value = yandex_compute_instance.k8s.1.network_interface.0.nat_ip_address
}
