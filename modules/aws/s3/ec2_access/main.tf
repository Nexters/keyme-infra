resource "aws_s3_bucket" "s3" {
  bucket = var.name
}

resource "aws_s3_bucket_public_access_block" "name" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "s3_hosting" {
  bucket = aws_s3_bucket.s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.s3_policy_data.json
}

data "aws_iam_policy_document" "s3_policy_data" {
  statement {
    sid = "AllowAllS3ActionToEC2AndLambda"
    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "lambda.amazonaws.com"
      ]
    }

    actions = [
      "s3:*",
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.s3.arn}/*",
      "${aws_s3_bucket.s3.arn}",
    ]
  }

  statement {
    sid = "AllowGetPublic"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }

    actions = [ "s3:GetObject" ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.s3.arn}/*",
      "${aws_s3_bucket.s3.arn}",
    ]
  }
}