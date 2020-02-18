output "asg_name" {
  value = aws_cloudformation_stack.ecs_asg.outputs["AsgName"]
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.instance_profile.name
}

output "instance_profile_role_name" {
  value = aws_iam_role.instance_role.name
}

output "ebs_device_name" {
  value = local.ebs_device_name
}
