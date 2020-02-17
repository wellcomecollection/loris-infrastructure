variable "vpc_id" {}

variable "subnets" {
  type = list(string)
}

variable "ecs_cluster_id" {}
variable "service_name" {}
variable "task_definition_arn" {}
variable "container_port" {}

variable "launch_type" {
  default = "FARGATE"
}

variable "task_desired_count" {
  default = 1
  type    = number
}

variable "deployment_minimum_healthy_percent" {
  type    = number
  default = 100
}

variable "deployment_maximum_percent" {
  type    = number
  default = 200
}

variable "security_group_ids" {
  type = list(string)
}

variable "assign_public_ip" {
  default = false
}

variable "container_name" {}
variable "lb_arn" {}
variable "listener_port" {}
variable "healthcheck_path" {}
variable "namespace_id" {}
