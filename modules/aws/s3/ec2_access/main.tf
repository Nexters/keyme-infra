resource "aws_s3_bucket" "s3" {
  bucket = var.name
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
}