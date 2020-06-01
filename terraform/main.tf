module "loris_2020_06_01" {
  source = "./stack"

  namespace = "loris-2020-06-01"

  certificate_domain = "api.wellcomecollection.org"

  aws_region = var.aws_region

  vpc_id          = local.vpc_id
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  app_container_image     = local.loris_image
  sidecar_container_image = local.nginx_image

  asg_desired        = 4
  desired_task_count = 4

  # The cache cleaner is published from the dockerfiles repo, and so is versioned
  # separately from ECR.  We pin it to a specific release so it can't change
  # under our feet.
  # See: https://github.com/wellcometrust/dockerfiles
  ebs_cache_cleaner_daemon_image_version = "144"

  ebs_size                                = "200"
  ebs_cache_cleaner_daemon_max_size_in_gb = "150"
  ebs_cache_cleaner_daemon_clean_interval = "1m"
}
