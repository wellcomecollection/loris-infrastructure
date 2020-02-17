resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name = "${var.namespace}"
  vpc  = "${var.vpc_id}"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.namespace}"
}

locals {
  sidecar_container_name = "sidecar"
}

module "task" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service.git//task_definition/container_with_sidecar?ref=8c79ba9235f5d9384af2126825a9eb1c80f7895c"

  task_name = var.namespace

  cpu    = var.app_cpu + var.sidecar_cpu
  memory = var.app_memory + var.sidecar_memory

  use_awslogs = true

  app_container_image = var.app_container_image
  app_container_port  = var.app_container_port
  app_cpu             = var.app_cpu
  app_memory          = var.app_memory

  app_mount_points = [
    {
      sourceVolume  = "ebs"
      containerPath = var.ebs_container_path
    },
  ]

  sidecar_container_image = var.sidecar_container_image
  sidecar_container_port  = var.sidecar_container_port
  sidecar_cpu             = var.sidecar_cpu
  sidecar_memory          = var.sidecar_memory
  sidecar_container_name  = local.sidecar_container_name

  ebs_volume_name = "ebs"
  ebs_host_path   = "/ebs/loris"

  launch_type = "EC2"

  aws_region = var.aws_region
}

module "service" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service.git//service?ref=v1.2.0"

  service_name = var.namespace
  cluster_arn  = aws_ecs_cluster.cluster.arn

  desired_task_count = max(2, var.desired_task_count)

  task_definition_arn = module.task.arn

  subnets = var.private_subnets

  namespace_id = aws_service_discovery_private_dns_namespace.namespace.id

  security_group_ids = [
    aws_security_group.service_lb_security_group.id,
    aws_security_group.service_egress_security_group.id,
  ]

  # We always run at least 2 instances.  Setting the minimum healthy percent
  # to 50% means that ECS can scale down tasks during deployment (but there's
  # always at least one task running), and otherwise we can allocate 100% of
  # the available CPU/memory to tasks at all times.
  #
  # See https://github.com/wellcomecollection/docs/blob/master/research/2020-01-14-ecs-scaling-big-tasks.md
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  launch_type = "EC2"

  target_group_arn = module.target_group.arn
  container_name   = local.sidecar_container_name
  container_port   = var.sidecar_container_port
}

module "target_group" {
  source = "../modules/target_group"

  service_name = var.namespace

  vpc_id = var.vpc_id
  lb_arn = aws_alb.loris.arn

  listener_port  = 80
  container_port = var.sidecar_container_port

  healthcheck_path = var.healthcheck_path
}
