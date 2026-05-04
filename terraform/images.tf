# =============================================================================
# images.tf — Build et pull des images Docker
#
# La ressource docker_image avec un bloc "build" appelle "docker build"
# au moment du terraform apply, à partir du Dockerfile local.
# =============================================================================

# Image PostgreSQL officielle (pull depuis Docker Hub)
resource "docker_image" "postgres" {
  name         = "postgres:${var.postgres_image_tag}"
  keep_locally = true # Ne pas supprimer l'image au terraform destroy
}

# Build du user-service à partir du Dockerfile local
resource "docker_image" "user_service" {
  name = "${var.project_name}/user-service:${var.services_image_tag}"

  build {
    context    = "${path.root}/../services/user-service"
    dockerfile = "Dockerfile"
  }

  # Force le rebuild si le contenu des sources change
  triggers = {
    source_hash = sha256(join("", [
      filesha256("${path.root}/../services/user-service/Dockerfile"),
      filesha256("${path.root}/../services/user-service/src/index.js"),
      filesha256("${path.root}/../services/user-service/package.json"),
    ]))
  }
}

resource "docker_image" "product_service" {
  name = "${var.project_name}/product-service:${var.services_image_tag}"

  build {
    context    = "${path.root}/../services/product-service"
    dockerfile = "Dockerfile"
  }

  triggers = {
    source_hash = sha256(join("", [
      filesha256("${path.root}/../services/product-service/Dockerfile"),
      filesha256("${path.root}/../services/product-service/src/index.js"),
      filesha256("${path.root}/../services/product-service/package.json"),
    ]))
  }
}

resource "docker_image" "order_service" {
  name = "${var.project_name}/order-service:${var.services_image_tag}"

  build {
    context    = "${path.root}/../services/order-service"
    dockerfile = "Dockerfile"
  }

  triggers = {
    source_hash = sha256(join("", [
      filesha256("${path.root}/../services/order-service/Dockerfile"),
      filesha256("${path.root}/../services/order-service/src/index.js"),
      filesha256("${path.root}/../services/order-service/package.json"),
    ]))
  }
}

resource "docker_image" "frontend" {
  name = "${var.project_name}/frontend:${var.services_image_tag}"

  build {
    context    = "${path.root}/../services/frontend"
    dockerfile = "Dockerfile"
  }

  triggers = {
    source_hash = sha256(join("", [
      filesha256("${path.root}/../services/frontend/Dockerfile"),
      filesha256("${path.root}/../services/frontend/src/index.html"),
      filesha256("${path.root}/../services/frontend/nginx.conf"),
    ]))
  }
}
