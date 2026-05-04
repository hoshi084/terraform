# =============================================================================
# postgres.tf — Conteneur PostgreSQL
# =============================================================================

resource "docker_container" "postgres" {
  name  = "${var.project_name}_postgres"
  image = docker_image.postgres.image_id

  restart = "unless-stopped"

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]

  # Port PostgreSQL exposé sur l'hôte pour inspection directe
  ports {
    internal = 5432
    external = var.postgres_port
  }

  # Montage du volume de données
  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.app.name
  }

  # Health check : attend que Postgres accepte des connexions
  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U ${var.db_user} -d ${var.db_name}"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
    start_period = "10s"
  }

  labels {
    label = "project"
    value = var.project_name
  }
}
