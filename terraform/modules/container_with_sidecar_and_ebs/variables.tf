variable "task_name" {}

variable "cpu" {}
variable "memory" {}

variable "app_container_image" {}
variable "app_container_port" {}
variable "app_cpu" {}
variable "app_memory" {}

variable "app_env_vars" {
  description = "Environment variables to pass to the container"
  type        = map(string)
  default     = {}
}

variable "sidecar_container_image" {}
variable "sidecar_container_port" {}
variable "sidecar_cpu" {}
variable "sidecar_memory" {}

variable "sidecar_env_vars" {
  description = "Environment variables to pass to the container"
  type        = map(string)
  default     = {}
}

variable "sidecar_is_proxy" {
  default = "false"
}

variable "aws_region" {}

variable "ebs_host_path" {}
variable "ebs_container_path" {}
