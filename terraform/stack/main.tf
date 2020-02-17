resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name = "${var.namespace}"
  vpc  = "${var.vpc_id}"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.namespace}"
}

module "task" {
  source = "../modules/container_with_sidecar_and_ebs"

  aws_region = "${var.aws_region}"
  task_name  = "${var.namespace}"

  cpu    = "${var.cpu}"
  memory = "${var.memory}"

  app_container_image = "${var.app_container_image}"
  app_container_port  = "${var.app_container_port}"

  app_cpu    = "${var.app_cpu}"
  app_memory = "${var.app_memory}"

  sidecar_container_image = "${var.sidecar_container_image}"
  sidecar_container_port  = "${var.sidecar_container_port}"

  sidecar_cpu    = "${var.sidecar_cpu}"
  sidecar_memory = "${var.sidecar_memory}"

  ebs_host_path      = "/ebs/loris"
  ebs_container_path = "${var.ebs_container_path}"

  sidecar_is_proxy = "true"
}

module "service" {
  source = "../modules/http_service"

  service_name       = "${var.namespace}"
  task_desired_count = "${var.task_desired_count}"

  security_group_ids = [
    "${aws_security_group.service_lb_security_group.id}",
    "${aws_security_group.service_egress_security_group.id}",
  ]

  deployment_minimum_healthy_percent = "50"
  deployment_maximum_percent         = "200"

  ecs_cluster_id = "${aws_ecs_cluster.cluster.id}"

  vpc_id = "${var.vpc_id}"

  subnets = "${var.private_subnets}"

  namespace_id = "${aws_service_discovery_private_dns_namespace.namespace.id}"

  container_port = "${var.sidecar_container_port}"
  container_name = "${module.task.sidecar_task_name}"

  task_definition_arn = "${module.task.task_definition_arn}"

  healthcheck_path = "${var.healthcheck_path}"

  listener_port = "80"
  lb_arn        = "${aws_alb.loris.arn}"

  launch_type = "EC2"
}

module "cache_cleaner_task" {
  source = "../modules/single_container_with_ebs"

  aws_region = "${var.aws_region}"
  task_name  = "${var.namespace}_cache_cleaner"

  ebs_host_path      = "/ebs/loris"
  ebs_container_path = "/data"

  container_image = "wellcome/cache_cleaner:${var.ebs_cache_cleaner_daemon_image_version}"

  cpu    = "${var.ebs_cache_cleaner_daemon_cpu}"
  memory = "${var.ebs_cache_cleaner_daemon_memory}"

  env_vars = {
    CLEAN_INTERVAL = "${var.ebs_cache_cleaner_daemon_clean_interval}"
    MAX_AGE        = "${var.ebs_cache_cleaner_daemon_max_age_in_days}"
    MAX_SIZE       = "${var.ebs_cache_cleaner_daemon_max_size_in_gb}G"
  }
}

resource "aws_ecs_service" "cache_cleaner_service" {
  name            = "${var.namespace}_cache_cleaner_daemon"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${module.cache_cleaner_task.task_definition_arn}"

  launch_type         = "EC2"
  scheduling_strategy = "DAEMON"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets          = "${var.private_subnets}"
    security_groups  = []
    assign_public_ip = false
  }
}

module "iam" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service.git//service/iam_role?ref=v1.2.0"

  service_name = aws_ecs_service.cache_cleaner_service.name
}
