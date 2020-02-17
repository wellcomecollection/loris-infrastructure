module "asg" {
  source = "./asg"

  name = var.asg_name

  asg_min     = var.asg_min
  asg_desired = var.asg_desired
  asg_max     = var.asg_max

  instance_type = var.instance_type

  ebs_size        = var.ebs_size
  ebs_volume_type = var.ebs_volume_type

  # amzn-ami-2018.03.a-amazon-ecs-optimized
  image_id = "ami-c91624b0"

  user_data   = data.template_file.userdata.rendered

  subnets = var.subnets
  vpc_id  = var.vpc_id
}

data "template_file" "userdata" {
  template = file("${path.module}/ebs.tpl")

  vars = {
    cluster_name  = var.cluster_name
    ebs_volume_id = module.asg.ebs_volume_id
    ebs_host_path = local.ebs_host_path
  }
}

module "instance_policy" {
  source = "./instance_role_policy"

  cluster_name               = var.cluster_name
  instance_profile_role_name = module.asg.instance_profile_role_name
}
