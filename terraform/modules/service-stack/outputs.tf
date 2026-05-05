output "container_name" {
  description = "Nom du conteneur créé"
  value       = docker_container.this.name
}

output "container_id" {
  description = "ID du conteneur Docker"
  value       = docker_container.this.id
}

output "image_id" {
  description = "ID de l'image Docker construite"
  value       = docker_image.this.image_id
}

output "volume_name" {
  description = "Nom du volume créé (null si pas de volume)"
  value       = var.enable_volume ? docker_volume.this[0].name : null
}