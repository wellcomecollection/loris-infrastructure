resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name = var.namespace
  vpc  = var.vpc_id
}

resource "aws_ecs_cluster" "cluster" {
  name = var.namespace
}

resource "aws_cloudwatch_log_group" "sidecar_log_group" {
  name              = "ecs/sidecar_${var.namespace}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "ecs/${var.namespace}"
  retention_in_days = 7
}

data "aws_region" "current" {}

locals {
  uwsgi_socket_volume = "uwsgi_socket"
  uwsgi_socket_dir    = "/var/run/uwsgi"
}

module "sidecar_container" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/container_definition?ref=v2.6.0"

  name  = "sidecar"
  image = var.sidecar_container_image

  cpu    = var.sidecar_cpu
  memory = var.sidecar_memory

  mount_points = [
    {
      sourceVolume  = local.uwsgi_socket_volume
      containerPath = local.uwsgi_socket_dir
    }
  ]
  port_mappings = [
    {
      containerPort = var.sidecar_container_port
      hostPort      = var.sidecar_container_port
      protocol      = "tcp"
    }
  ]
  # Increase somaxconn to prevent connections being dropped by the shared socket
  system_controls = [
    {
      namespace = "net.core.somaxconn"
      value     = "1024"
    }
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.sidecar_log_group.name
      awslogs-region        = data.aws_region.current.name
      awslogs-stream-prefix = "ecs"
    }
    secretOptions = []
  }
}

module "app_container" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/container_definition?ref=v2.6.0"

  name  = "app"
  image = var.app_container_image

  cpu    = var.app_cpu
  memory = var.app_memory
  mount_points = [
    {
      sourceVolume  = "ebs",
      containerPath = var.ebs_container_path
    },
    {
      sourceVolume  = local.uwsgi_socket_volume
      containerPath = local.uwsgi_socket_dir
    }
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.app_log_group.name
      awslogs-region        = data.aws_region.current.name
      awslogs-stream-prefix = "ecs"
    }
    secretOptions = []
  }
}

module "task" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/task_definition?ref=v2.6.0"

  task_name = var.namespace
  cpu       = var.app_cpu + var.sidecar_cpu
  memory    = var.app_memory + var.sidecar_memory

  container_definitions = [
    module.app_container.container_definition,
    module.sidecar_container.container_definition
  ]

  ebs_volume_name = "ebs"
  ebs_host_path   = "/ebs/loris"
  extra_volumes = [
    {
      name      = local.uwsgi_socket_volume
      host_path = ""
    }
  ]

  launch_types = ["EC2"]
}

module "service" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/service?ref=v2.6.0"

  cluster_arn  = aws_ecs_cluster.cluster.arn
  service_name = var.namespace

  task_definition_arn = module.task.arn
  desired_task_count  = max(2, var.desired_task_count)
  container_name      = "sidecar"
  container_port      = var.sidecar_container_port

  # We always run at least 2 instances.  Setting the minimum healthy percent
  # to 50% means that ECS can scale down tasks during deployment (but there's
  # always at least one task running), and otherwise we can allocate 100% of
  # the available CPU/memory to tasks at all times.
  #
  # See https://github.com/wellcomecollection/docs/blob/master/research/2020-01-14-ecs-scaling-big-tasks.md
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "EC2"

  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.namespace.id
  subnets                        = var.private_subnets
  security_group_ids = [
    aws_security_group.service_lb_security_group.id,
    aws_security_group.service_egress_security_group.id,
  ]
  target_group_arn = aws_alb_target_group.http.arn
}
