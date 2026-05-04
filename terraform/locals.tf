# =============================================================================
# locals.tf — Valeurs calculées réutilisées dans plusieurs fichiers
# =============================================================================

locals {
  # URL de connexion PostgreSQL construite à partir des variables
  # Le hostname est le nom du conteneur postgres sur le réseau Docker
  db_url = "postgresql://${var.db_user}:${var.db_password}@${docker_container.postgres.name}:5432/${var.db_name}"

  # Étiquettes communes appliquées à tous les conteneurs
  common_labels = {
    project    = var.project_name
    managed_by = "terraform"
  }

  # Noms des services — utilisés pour construire les noms de conteneurs et d'images
  services = {
    user    = { port = 3001, host_port = var.user_service_port }
    product = { port = 3002, host_port = var.product_service_port }
    order   = { port = 3003, host_port = var.order_service_port }
  }
}
