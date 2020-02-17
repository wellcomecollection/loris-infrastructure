variable "task_name" {}

variable "env_vars" {
  description = "Environment variables to pass to the container"
  type        = map(string)
  default     = {}
}

variable "container_image" {}

variable "cpu" {
  default = 512
}

variable "memory" {
  default = 1024
}

variable "aws_region" {}

variable "ebs_host_path" {}
variable "ebs_container_path" {}
