# Build de l'image Docker
resource "docker_image" "this" {
  name = "${var.project_name}_${var.name}:${var.image_tag}"

  build {
    context    = var.build_context
    dockerfile = var.dockerfile_path
  }
}

# Volume optionnel
resource "docker_volume" "this" {
  count = var.enable_volume ? 1 : 0

  name = "${var.project_name}_${var.name}_data"
}

# Création du conteneur
resource "docker_container" "this" {
  name  = "${var.project_name}_${var.name}"
  image = docker_image.this.image_id

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  networks_advanced {
    name = var.network_name
  }

  env = var.env_vars

  # Monter le volume si activé
  dynamic "volumes" {
    for_each = var.enable_volume ? [1] : []
    content {
      volume_name    = docker_volume.this[0].name
      container_path = "/app/data"
    }
  }

  depends_on = [docker_volume.this]

  restart = "unless-stopped"

  labels {
    label = "project"
    value = var.project_name
  }

  labels {
    label = "service"
    value = var.name
  }
}