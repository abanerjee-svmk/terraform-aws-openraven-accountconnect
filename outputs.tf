output "openraven-discovery-role-arn"{
	description = "OpenRaven Discovery Role arn"
	value = aws_iam_role.openraven-discovery-role.arn
}

output "openraven-lambda-setup-policy-arn"{
	description = "OpenRaven Lambda Setup Policy arn"
	value = aws_iam_policy.openraven-lambda-setup.arn
}