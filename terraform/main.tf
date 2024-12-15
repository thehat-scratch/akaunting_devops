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

# Optional: Database container (MySQL example)
resource "docker_image" "mysql_image" {
  name = "mysql:8.0"
}

resource "docker_container" "mysql_db" {
  name  = "akaunting-db"
  image = docker_image.mysql_image.name
  env = [
    "MYSQL_ROOT_PASSWORD=rootpassword",
    "MYSQL_DATABASE=akaunting",
    "MYSQL_USER=akaunting_user",
    "MYSQL_PASSWORD=userpassword"
  ]
  networks_advanced {
    name = docker_network.akaunting_network.name
  }

  # Remove the 'volumes' block as requested
  # volumes {
  #   container_path = "/var/lib/mysql"
  #   host_path      = "/path/to/mysql/data"  # This line is removed
  # }

  # You can use a Docker volume instead if needed, here's how:
  # volumes {
  #   container_path = "/var/lib/mysql"
  #   volume_name    = "mysql_data"
  # }
}