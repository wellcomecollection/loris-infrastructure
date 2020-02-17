resource "aws_security_group" "full_egress" {
  vpc_id = var.vpc_id
  name   = "${var.name}_full_egress_${random_id.sg_append.hex}"

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
  description = var.name == "loris-2019-01-30" ? "controls direct access to application instances" : ""

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_id" "sg_append" {
  keepers = {
    sg_id = var.name
  }

  byte_length = 8
}
