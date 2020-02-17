module "cluster_host" {
  source = "../modules/ebs_cluster_host"

  cluster_name = aws_ecs_cluster.cluster.name

  asg_name = var.namespace

  asg_min     = var.asg_min
  asg_desired = var.asg_desired
  asg_max     = var.asg_max

  instance_type = var.instance_type

  ebs_size        = var.ebs_size
  ebs_volume_type = var.ebs_volume_type

  subnets      = var.private_subnets
  vpc_id       = var.vpc_id
}
