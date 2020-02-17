variable "aws_region" {}

variable "env_vars" {
  description = "Environment variables to pass to the container"
  type        = map(string)
  default     = {}
}

variable "task_name" {}

variable "container_image" {}

variable "cpu" {}
variable "memory" {}

variable "mount_points" {
  type    = list(map(string))
  default = []
}

variable "command" {
  type    = list(string)
  default = []
}
