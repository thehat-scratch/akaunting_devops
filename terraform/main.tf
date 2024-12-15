terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.0"  # Specify the desired version
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"  # Docker socket for local environment
}

# Docker network
resource "docker_network" "akaunting_network" {
  name = "akaunting_network"
}

# Docker container for Akaunting app
resource "docker_container" "akaunting_app" {
  name  = "akaunting-app"
  image = "hicham2004/akaunting-app:v1"  # Updated Docker image
  ports {
    internal = 80
    external = 8080
  }
  networks_advanced {
    name = docker_network.akaunting_network.name
  }
}

# Docker image for MySQL database
resource "docker_image" "mysql_image" {
  name = "mysql:8.0"
}

# Docker container for MySQL database
resource "docker_container" "mysql_db" {
  name  = "akaunting-db"
  image = docker_image.mysql_image.name
  
  # Avoid hardcoding sensitive information directly in the configuration
  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=akaunting",
    "MYSQL_USER=akaunting_user",
    "MYSQL_PASSWORD=${var.mysql_user_password}"
  ]

  networks_advanced {
    name = docker_network.akaunting_network.name
  }

  # Optional: Docker volume for persistent data (if needed)
  # Uncomment and configure as required
  # volumes {
  #   container_path = "/var/lib/mysql"
  #   volume_name    = "mysql_data"
  # }
}

# Variables for sensitive data
variable "mysql_root_password" {
  description = "The root password for the MySQL database"
  type        = string
}

variable "mysql_user_password" {
  description = "The password for the MySQL user"
  type        = string
}
