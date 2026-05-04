output "container_id" {
  description = "ID du conteneur Docker créé"
  value       = docker_container.this.id
}

output "container_name" {
  description = "Nom du conteneur (utilisable comme hostname sur le réseau Docker)"
  value       = docker_container.this.name
}

output "container_ip" {
  description = "IP du conteneur sur le réseau Docker"
  value       = docker_container.this.network_data[0].ip_address
}
