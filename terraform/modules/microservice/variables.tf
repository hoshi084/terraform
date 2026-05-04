variable "name" {
  description = "Nom du conteneur"
  type        = string
}

variable "image_id" {
  description = "ID de l'image Docker (depuis docker_image.xxx.image_id)"
  type        = string
}

variable "internal_port" {
  description = "Port écouté par le processus dans le conteneur"
  type        = number
}

variable "external_port" {
  description = "Port exposé sur la machine hôte"
  type        = number
}

variable "network_name" {
  description = "Nom du réseau Docker à rejoindre"
  type        = string
}

variable "env_vars" {
  description = "Variables d'environnement passées au conteneur (format KEY=VALUE)"
  type        = list(string)
  default     = []
}

variable "depends_on_containers" {
  description = "Liste de conteneurs dont ce service dépend (pour les depends_on explicites)"
  type        = list(string)
  default     = []
}

variable "project_name" {
  description = "Nom du projet (pour les labels)"
  type        = string
}
