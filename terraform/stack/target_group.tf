locals {
  # Must only contain alphanumerics and hyphens.
  target_group_name = replace(var.namespace, "_", "-")
}

resource "aws_alb_target_group" "http" {
  name = local.target_group_name

  target_type = "ip"

  protocol = "HTTP"
  port     = var.sidecar_container_port
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTP"
    path     = var.healthcheck_path
    matcher  = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.loris.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.http.arn
  }
}
