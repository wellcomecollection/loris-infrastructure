resource "aws_cloudwatch_log_group" "task" {
  name = "ecs/${var.task_name}"

  retention_in_days = "${var.log_retention_in_days}"
}
