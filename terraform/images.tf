data "aws_ssm_parameter" "loris_release" {
  name = "/loris/images/latest/loris"
}

data "aws_ssm_parameter" "loris_nginx_release" {
  name = "/platform/images/latest/nginx_loris"
}

locals {
  loris_image = data.aws_ssm_parameter.loris_release.value
  nginx_image = data.aws_ssm_parameter.loris_nginx_release.value
}
