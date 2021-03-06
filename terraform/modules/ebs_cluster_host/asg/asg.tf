resource "aws_cloudformation_stack" "ecs_asg" {
  name          = var.name
  template_body = data.template_file.cluster_ecs_asg.rendered

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "cluster_ecs_asg" {
  template = file("${path.module}/asg.json.template")

  vars = {
    launch_config_name  = aws_launch_configuration.launch_config.name
    vpc_zone_identifier = jsonencode(var.subnets)
    asg_min_size        = var.asg_min
    asg_desired_size    = var.asg_desired
    asg_max_size        = var.asg_max
    asg_name            = var.name
  }
}
