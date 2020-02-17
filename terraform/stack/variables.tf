variable "vpc_id" {}
variable "namespace" {}
variable "aws_region" {}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "certificate_domain" {}

variable "healthcheck_path" {
  default = "/image/"
}

variable "asg_min" {
  description = "Min number of instances"
  default     = 0
  type = number
}

variable "asg_desired" {
  description = "Desired number of instances"
  default     = 4
  type = number
}

variable "asg_max" {
  description = "Max number of instances"
  default     = 4
  type = number
}

variable "cpu" {
  default = 3960
  type = number
}

variable "memory" {
  default = 7350
  type = number
}

variable "task_desired_count" {
  default = 4
  type = number
}

variable "instance_type" {
  default = "c4.xlarge"
}

variable "app_container_image" {}

variable "app_container_port" {
  default = "8888"
}

variable "app_cpu" {
  default = 2948
  type = number
}

variable "app_memory" {
  default = 6144
  type = number
}

variable "sidecar_container_image" {}

variable "sidecar_container_port" {
  default = "9000"
}

variable "sidecar_cpu" {
  default = 128
  type = number
}

variable "sidecar_memory" {
  default = 128
  type = number
}

variable "ebs_container_path" {
  default = "/mnt/loris"
}

variable "ebs_size" {
  default = "180"
}

variable "ebs_volume_type" {
  default = "gp2"
}

variable "ebs_cache_cleaner_daemon_cpu" {
  default = 128
  type = number
}

variable "ebs_cache_cleaner_daemon_memory" {
  default = 64
  type = number
}

variable "ebs_cache_cleaner_daemon_max_age_in_days" {
  default = 30
  type = number
}

variable "ebs_cache_cleaner_daemon_max_size_in_gb" {
  default = 160
  type = number
}

variable "ebs_cache_cleaner_daemon_clean_interval" {
  default = "10m"
}

variable "ebs_cache_cleaner_daemon_image_version" {}
