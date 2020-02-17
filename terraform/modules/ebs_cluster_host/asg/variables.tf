variable "name" {
  description = "Name of the ASG to create"
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

variable "ebs_volume_type" {}

variable "image_id" {
  description = "ID of the AMI to use on the instances"
}

variable "user_data" {
  description = "User data for EC2 container hosts"
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  description = "VPC for EC2 autoscaling group security group"
}
