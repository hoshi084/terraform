# =============================================================================
# network.tf — Réseau Docker dédié au projet
#
# Tous les conteneurs rejoignent ce réseau et peuvent se joindre
# par leur nom de conteneur (DNS interne Docker).
# =============================================================================

resource "docker_network" "app" {
  name   = "${var.project_name}_network"
  driver = "bridge"

  ipam_config {
    subnet = var.network_subnet
  }

  labels {
    label = "project"
    value = var.project_name
  }

  # Docker ajoute automatiquement des attributs dans ipam_config (gateway, aux_address)
  # non déclarés dans notre config → ignore_changes évite une recréation inutile du réseau
  lifecycle {
    ignore_changes = [ipam_config]
  }
}
