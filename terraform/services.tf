# =============================================================================
# services.tf — Conteneurs des microservices
# Chaque service dépend implicitement de postgres via local.db_url
# =============================================================================

# Version avec for_each pour comparaison
resource "docker_container" "services_foreach" {
  for_each = local.services

  name  = "${var.project_name}_${each.key}_service"
  image = each.value.image_id

  restart = var.restart_policy

  env = [
    "PORT=${each.value.port}",
    "DATABASE_URL=${local.db_url}",
  ]

  ports {
    internal = each.value.port
    external = each.value.host_port
  }

  networks_advanced {
    name = docker_network.app.name
  }

  depends_on = [docker_container.postgres]

  labels {
    label = "project"
    value = var.project_name
  }

  labels {
    label = "service"
    value = "${each.key}-service"
  }
}

resource "docker_container" "frontend" {
  name  = "${var.project_name}_frontend"
  image = docker_image.frontend.image_id

  restart = var.restart_policy

  ports {
    internal = 80
    external = var.frontend_port
  }

  networks_advanced {
    name = docker_network.app.name
  }

  labels {
    label = "project"
    value = var.project_name
  }

  labels {
    label = "service"
    value = "frontend"
  }
}
