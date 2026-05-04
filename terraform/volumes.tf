# =============================================================================
# volumes.tf — Volumes Docker pour la persistance des données
# =============================================================================

# Volume pour les données PostgreSQL
# Sans ce volume, les données sont perdues à chaque terraform destroy/apply
resource "docker_volume" "postgres_data" {
  name = "${var.project_name}_postgres_data"

  labels {
    label = "project"
    value = var.project_name
  }
}
