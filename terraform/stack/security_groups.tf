resource "aws_security_group" "service_lb_security_group" {
  name        = "${var.namespace}_service_lb_security_group"
  description = "Allow traffic between services and load balancer"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol  = "tcp"
    from_port = 9000
    to_port   = 9000
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-service-lb"
  }
}

resource "aws_security_group" "external_lb_security_group" {
  name        = "${var.namespace}_external_lb_security_group"
  description = "Allow traffic between load balancer and internet"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-external-lb"
  }
}

resource "aws_security_group" "service_egress_security_group" {
  name        = "${var.namespace}_service_egress_security_group"

  # TODO: This description doesn't describe what the security group does;
  # it's a copy/paste error from another module.
  #
  # Unfortunately you can't change the description of a security group,
  # only create a new one/destroy the old one.  This is a bit of a faff,
  # so I didn't do it when I upgraded this to Terraform 0.12, but if the need
  # arises, we should ditch this.
  #
  # The conditional means it will continue to be applied to the *existing*
  # Loris stack, but it won't be copied to newer stacks.
  #
  # If the name of the stack is no longer `loris-2019-01-30`, you can
  # delete this line.
  description = var.namespace == "loris-2019-01-30" ? "Allow traffic between services" : ""

  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-egress"
  }
}
