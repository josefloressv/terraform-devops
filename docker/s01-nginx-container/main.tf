terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.14.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "myenginxapp" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginxcontainer" {
  image = docker_image.myenginxapp.latest
  name  = "tfenginx"
  ports {
    internal = 80
    external = 8000
  }
}

#doc https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs