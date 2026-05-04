# =============================================================================
# Module : microservice
# Encapsule la création d'un conteneur Docker pour un microservice.
# Réutilisable pour user-service, product-service, order-service, etc.
# =============================================================================

resource "docker_container" "this" {
  name    = var.name
  image   = var.image_id
  restart = "unless-stopped"
  env     = var.env_vars

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  networks_advanced {
    name = var.network_name
  }

  labels {
    label = "project"
    value = var.project_name
  }

  labels {
    label = "service"
    value = var.name
  }

  lifecycle {
    # Ignore les changements d'image pour ne pas recréer le conteneur
    # à chaque modification mineure — à adapter selon les besoins
    ignore_changes = [image]
  }
}
