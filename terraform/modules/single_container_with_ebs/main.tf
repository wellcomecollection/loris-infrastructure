module "container_definition" {
  source = "./container_definition"

  aws_region = "${var.aws_region}"

  container_image = "${var.container_image}"

  task_name = "${var.task_name}"

  env_vars = "${var.env_vars}"

  cpu    = "${var.cpu}"
  memory = "${var.memory}"

  mount_points = "${module.task_definition.mount_points}"
}

module "task_definition" {
  source    = "../task_definition"
  task_name = "${var.task_name}"

  task_definition_rendered = "${module.container_definition.rendered}"

  ebs_container_path = "${var.ebs_container_path}"
  ebs_host_path      = "${var.ebs_host_path}"

  cpu    = "${var.cpu}"
  memory = "${var.memory}"
}
