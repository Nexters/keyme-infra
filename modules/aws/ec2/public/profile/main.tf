resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-public-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_policy" "ec2_role_policy" {
  name = "${var.project_name}-public-ec2-policy"
  path = "/"
  policy = data.aws_iam_policy_document.ec2_role_policy.json
}

data "aws_iam_policy_document" "ec2_role_policy" {
  statement {
    sid = "AllowECRFullAccess"

    actions = [ 
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    effect = "Allow"

    resources = ["arn:aws:ecr:*"]
  }

  statement {
    sid = "AllowECRGetAuthorizationToken"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_policy_attachment" "ec2_policy_role_attachment" {
  name = "${var.project_name}-public-ec2-attachment"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_role_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-public-ec2-profile"
  role = aws_iam_role.ec2_role.name
}