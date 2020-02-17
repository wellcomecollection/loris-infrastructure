locals {
  mount_points   = "${jsonencode(var.mount_points)}"
  log_group_name = "${var.task_name}"
  container_name = "app"
  command        = "${jsonencode(var.command)}"

  log_group_prefix = "ecs"
}

data "template_file" "definition" {
  template = "${file("${path.module}/task_definition.json.template")}"

  vars = {
    log_group_region = "${var.aws_region}"
    log_group_name   = aws_cloudwatch_log_group.app.name
    log_group_prefix = local.log_group_prefix

    container_image = "${var.container_image}"
    container_name  = "${local.container_name}"

    environment_vars = "${module.env_vars.env_vars_string}"

    command = "${local.command}"

    cpu    = "${var.cpu}"
    memory = "${var.memory}"

    mount_points = "${local.mount_points}"
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name = "${local.log_group_prefix}/${var.task_name}"

  retention_in_days = 7
}

module "env_vars" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service.git//task_definition/modules/env_vars?ref=v1.2.0"

  env_vars = "${var.env_vars}"
}
