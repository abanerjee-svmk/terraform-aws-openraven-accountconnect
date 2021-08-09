terraform{
	required_providers{
		aws = {
			source = "hashicorp/aws"
			version = ">= 3.50.0"
		}
	}
}

resource "aws_iam_role" "openraven-discovery-role" {
  name               = "openraven-cross-account-${var.openraven_org_id}"
  assume_role_policy = <<-EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${var.openraven_aws_account_id}:role/orvn-${var.openraven_org_id}-cross-account"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "sts:ExternalId": "${var.external_id}"
          }
        }
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "openraven-lambda-setup" {
  name   = "openraven-lambda-setup-${var.openraven_org_id}"
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "lambda:CreateFunction",
                "lambda:InvokeFunction",
                "lambda:GetFunction",
                "lambda:DeleteFunction"
            ],
            "Resource": [
                "arn:aws:lambda:*:${var.discovery_account_id}:function:dmap-*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": "iam:PassRole",
            "Resource": [
                "arn:aws:iam::${var.discovery_account_id}:role/openraven-cross-account-${var.openraven_org_id}"
            ],
            "Effect": "Allow"
        }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "openraven-attach-lambda-create" {
  role       = aws_iam_role.openraven-discovery-role.name
  policy_arn = aws_iam_policy.openraven-lambda-setup.arn
}

resource "aws_iam_role_policy_attachment" "openraven-attach-read-only" {
  role       = aws_iam_role.openraven-discovery-role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "openraven-attach-aws-lambda-exec" {
  role       = aws_iam_role.openraven-discovery-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

