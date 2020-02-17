locals {
  ebs_device_name = "/dev/xvdb"
}

resource "aws_launch_configuration" "launch_config" {
  security_groups = module.security_groups.instance_security_groups

  key_name                    = ""
  image_id                    = var.image_id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
  user_data                   = var.user_data
  associate_public_ip_address = true

  ebs_block_device {
    volume_size = var.ebs_size
    volume_type = var.ebs_volume_type
    device_name = local.ebs_device_name
  }

  lifecycle {
    create_before_destroy = true
  }
}
