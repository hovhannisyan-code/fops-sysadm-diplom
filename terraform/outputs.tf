output "bastion_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "web_private_ips" {
  value = yandex_compute_instance.web[*].network_interface[0].ip_address
}

output "prometheus_ip" {
  value = yandex_compute_instance.prometheus.network_interface[0].ip_address
}

output "grafana_ip" {
  value = yandex_compute_instance.grafana.network_interface[0].nat_ip_address
}

output "grafana_private_ip" {
  value = yandex_compute_instance.grafana.network_interface[0].ip_address
}

output "alb_external_ip" {
  value = yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address
}

output "elasticsearch_ip" {
  value = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
}

output "kibana_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
}

output "kibana_private_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].ip_address
}