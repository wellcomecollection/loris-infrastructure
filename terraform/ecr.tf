resource "aws_ecr_repository" "nginx_loris_delta" {
  name = "uk.ac.wellcome/nginx_loris-delta"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ecr_repository" "loris" {
  name = "uk.ac.wellcome/loris"

  lifecycle {
    prevent_destroy = true
  }
}
