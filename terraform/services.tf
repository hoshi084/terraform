# =============================================================================
# services.tf — Conteneurs des microservices
# Chaque service dépend implicitement de postgres via local.db_url
# =============================================================================

resource "docker_container" "user_service" {
  name  = "${var.project_name}_user_service"
  image = docker_image.user_service.image_id

  restart = "unless-stopped"

  env = [
    "PORT=3001",
    "DATABASE_URL=${local.db_url}",
  ]

  ports {
    internal = 3001
    external = var.user_service_port
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
    value = "user-service"
  }
}

resource "docker_container" "product_service" {
  name  = "${var.project_name}_product_service"
  image = docker_image.product_service.image_id

  restart = "unless-stopped"

  env = [
    "PORT=3002",
    "DATABASE_URL=${local.db_url}",
  ]

  ports {
    internal = 3002
    external = var.product_service_port
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
    value = "product-service"
  }
}

resource "docker_container" "order_service" {
  name  = "${var.project_name}_order_service"
  image = docker_image.order_service.image_id

  restart = "unless-stopped"

  env = [
    "PORT=3003",
    "DATABASE_URL=${local.db_url}",
    # Les services se joignent par leur nom de conteneur sur le réseau Docker
    "USER_SERVICE_URL=http://${docker_container.user_service.name}:3001",
    "PRODUCT_SERVICE_URL=http://${docker_container.product_service.name}:3002",
  ]

  ports {
    internal = 3003
    external = var.order_service_port
  }

  networks_advanced {
    name = docker_network.app.name
  }

  depends_on = [
    docker_container.postgres,
    docker_container.user_service,
    docker_container.product_service,
  ]

  labels {
    label = "project"
    value = var.project_name
  }

  labels {
    label = "service"
    value = "order-service"
  }
}

resource "docker_container" "frontend" {
  name  = "${var.project_name}_frontend"
  image = docker_image.frontend.image_id

  restart = "unless-stopped"

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
