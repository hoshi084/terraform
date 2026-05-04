# =============================================================================
# outputs.tf — Valeurs exportées après terraform apply
# =============================================================================

output "frontend_url" {
  description = "URL du frontend"
  value       = "http://localhost:${var.frontend_port}"
}

output "user_service_url" {
  description = "URL du user-service"
  value       = "http://localhost:${var.user_service_port}"
}

output "product_service_url" {
  description = "URL du product-service"
  value       = "http://localhost:${var.product_service_port}"
}

output "order_service_url" {
  description = "URL du order-service"
  value       = "http://localhost:${var.order_service_port}"
}

output "network_name" {
  description = "Nom du réseau Docker créé"
  value       = docker_network.app.name
}

output "postgres_container_name" {
  description = "Nom du conteneur PostgreSQL (hostname sur le réseau Docker)"
  value       = docker_container.postgres.name
}

output "services_ports" {
  description = "Map des ports hôtes pour tous les services"
  value       = local.all_service_ports
}
