variable "docker_host" {
  description = "Адрес Docker-демона (VM по SSH)"
  type        = string
  default     = "ssh://deployer@111.88.162.79"
}

variable "ssh_key_path" {
  description = "Приватный SSH-ключ для доступа к VM"
  type        = string
  default     = "~/.ssh/mts_devops"
}

variable "external_port" {
  description = "Нестандартный внешний порт nginx"
  type        = number
  default     = 8080
}
