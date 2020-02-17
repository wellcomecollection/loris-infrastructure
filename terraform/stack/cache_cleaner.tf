module "cache_cleaner_task" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service.git//task_definition/single_container?ref=f8418aeb6ba9144070e83c84983a7e845b12be94"

  task_name  = "${var.namespace}_cache_cleaner"

  container_image = "wellcome/cache_cleaner:${var.ebs_cache_cleaner_daemon_image_version}"

  cpu    = var.ebs_cache_cleaner_daemon_cpu
  memory = var.ebs_cache_cleaner_daemon_memory

  mount_points = [
    {
      sourceVolume  = "ebs"
      containerPath = "/data"
    },
  ]

  use_awslogs = true

  env_vars = {
    CLEAN_INTERVAL = var.ebs_cache_cleaner_daemon_clean_interval
    MAX_AGE        = var.ebs_cache_cleaner_daemon_max_age_in_days
    MAX_SIZE       = "${var.ebs_cache_cleaner_daemon_max_size_in_gb}G"
  }

  ebs_volume_name = "ebs"
  ebs_host_path   = "/ebs/loris"

  launch_type = "EC2"

  aws_region = var.aws_region
}

resource "aws_ecs_service" "cache_cleaner_service" {
  name            = "${var.namespace}_cache_cleaner_daemon"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = module.cache_cleaner_task.arn

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
