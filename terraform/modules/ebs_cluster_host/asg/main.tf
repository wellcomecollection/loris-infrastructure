module "cloudformation_stack" {
  source = "./asg"

  subnet_list        = var.subnets
  asg_name           = var.name
  launch_config_name = module.launch_config.name

  asg_max     = var.asg_max
  asg_desired = var.asg_desired
  asg_min     = var.asg_min
}

module "launch_config" {
  source = "./launch_config"

  key_name              = ""
  image_id              = var.image_id
  instance_type         = var.instance_type
  instance_profile_name = module.instance_profile.name
  user_data             = var.user_data

  associate_public_ip_address = true
  instance_security_groups    = module.security_groups.instance_security_groups

  ebs_size        = var.ebs_size
  ebs_volume_type = var.ebs_volume_type
}

module "security_groups" {
  source = "./security_groups"

  name   = var.name
  vpc_id = var.vpc_id

  controlled_access_cidr_ingress    = []
  controlled_access_security_groups = []
  custom_security_groups            = []
}

module "instance_profile" {
  source = "./instance_profile"
  name   = var.name
}
