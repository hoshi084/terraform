# =============================================================================
# main.tf — Configuration du provider et du backend local
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  # State stocké localement par défaut.
  # Pour un backend distant (ex: HTTP, Consul), décommenter et adapter :
  # backend "local" {
  #   path = "terraform.tfstate"
  # }
}

# Le provider Docker se connecte au daemon Docker local.
# Sur Linux : socket unix:///var/run/docker.sock
# Sur Mac/Windows avec Docker Desktop : le socket est géré automatiquement
provider "docker" {}
