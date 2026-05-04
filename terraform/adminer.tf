# =============================================================================
# adminer.tf — Interface web PostgreSQL Adminer
# =============================================================================

resource "docker_container" "adminer" {
  name  = "shopmicrfo_adminer"
  image = "adminer:latest"

  # Match all the imported container's attributes exactly
  restart     = "no"
  user        = "adminer"
  working_dir = "/var/www/html"

  command = [
    "php",
    "-S",
    "[::]:8080",
    "-t",
    "/var/www/html"
  ]

  entrypoint = [
    "entrypoint.sh",
    "docker-php-entrypoint"
  ]

  env = []  # Match the imported container's empty env

  ports {
    internal = 8080
    external = 8081
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  ports {
    internal = 8080
    external = 8081
    ip       = "::"
    protocol = "tcp"
  }

  network_mode = "shopmicrfo_network"
}