# =============================================================================
# variables.tf
# =============================================================================

variable "project_name" {
  description = "Préfixe utilisé pour nommer toutes les ressources Docker"
  type        = string
  default     = "shopmicrfo"
}

variable "network_subnet" {
  description = "Sous-réseau du réseau Docker bridge créé pour le projet"
  type        = string
  default     = "172.20.0.0/16"
}

# --- Ports exposés sur l'hôte ---

variable "frontend_port" {
  description = "Port hôte pour accéder au frontend"
  type        = number
  default     = 8080
}

variable "user_service_port" {
  description = "Port hôte pour accéder au user-service"
  type        = number
  default     = 3001
}

variable "product_service_port" {
  description = "Port hôte pour accéder au product-service"
  type        = number
  default     = 3002
}

variable "order_service_port" {
  description = "Port hôte pour accéder au order-service"
  type        = number
  default     = 3003
}

variable "postgres_port" {
  description = "Port hôte pour accéder à PostgreSQL (debug uniquement)"
  type        = number
  default     = 5432
}

# --- Base de données ---

variable "db_name" {
  description = "Nom de la base de données PostgreSQL"
  type        = string
  default     = "shopdb"
}

variable "db_user" {
  description = "Utilisateur PostgreSQL"
  type        = string
  default     = "shopuser"
}

variable "db_password" {
  description = "Mot de passe PostgreSQL"
  type        = string
  sensitive   = true
  default     = "shoppassword"
}

# --- Images Docker ---

variable "postgres_image_tag" {
  description = "Tag de l'image PostgreSQL officielle"
  type        = string
  default     = "16-alpine"
}

variable "services_image_tag" {
  description = "Tag appliqué aux images buildées des microservices"
  type        = string
  default     = "latest"
}
