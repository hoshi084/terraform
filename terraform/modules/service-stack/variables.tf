variable "name" {
  description = "Nom du service (utilisé pour le conteneur et l'image)"
  type        = string
}

variable "build_context" {
  description = "Contexte de build pour l'image Docker (chemin vers le répertoire)"
  type        = string
}

variable "dockerfile_path" {
  description = "Chemin vers le Dockerfile relatif au build_context"
  type        = string
  default     = "Dockerfile"
}

variable "internal_port" {
  description = "Port interne du conteneur"
  type        = number
}

variable "external_port" {
  description = "Port exposé sur l'hôte"
  type        = number
}

variable "network_name" {
  description = "Nom du réseau Docker à rejoindre"
  type        = string
}

variable "env_vars" {
  description = "Variables d'environnement (format KEY=VALUE)"
  type        = list(string)
  default     = []
}

variable "project_name" {
  description = "Nom du projet pour les labels"
  type        = string
}

variable "enable_volume" {
  description = "Si true, crée un volume pour ce service"
  type        = bool
  default     = false
}