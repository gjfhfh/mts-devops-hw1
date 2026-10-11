terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host     = var.docker_host
  ssh_opts = ["-i", pathexpand(var.ssh_key_path), "-o", "StrictHostKeyChecking=accept-new"]
}

resource "docker_network" "web" {
  name = "tf-web-net"
}

resource "docker_volume" "html" {
  name = "tf-nginx-html"
}

resource "docker_image" "nginx" {
  name = "nginx:1.27-alpine"
}

resource "docker_container" "nginx" {
  name  = "tf-nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.web.name
  }

  volumes {
    volume_name    = docker_volume.html.name
    container_path = "/usr/share/nginx/html"
  }

  ports {
    internal = 80
    external = var.external_port
  }
}
