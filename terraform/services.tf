# =============================================================================
# services.tf — Conteneurs des microservices
# Chaque service dépend implicitement de postgres via local.db_url
# =============================================================================

# Exemple d'utilisation du module service-stack pour user-service
module "user_service_stack" {
  source = "./modules/service-stack"

  name          = "user_service"
  build_context = "${path.root}/../services/user-service"
  internal_port = 3001
  external_port = var.user_service_port
  network_name  = docker_network.app.name
  project_name  = var.project_name
  enable_volume = true

  env_vars = [
    "PORT=3001",
    "DATABASE_URL=${local.db_url}",
  ]
}

# Ressource pour gérer la dépendance au postgres
resource "null_resource" "user_service_depends_on_postgres" {
  depends_on = [docker_container.postgres]
}

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
