variable "cluster_name" {}

variable "asg_name" {
  description = "Name of the ASG"
}

variable "asg_min" {
  description = "Minimum number of instances"
  type        = number
}

variable "asg_desired" {
  description = "Desired number of instances"
  type        = number
}

variable "asg_max" {
  description = "Max number of instances"
  type        = number
}

variable "instance_type" {
  description = "AWS instance type"
}

variable "ebs_size" {}

variable "ebs_volume_type" {
  default = "standard"
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {}
