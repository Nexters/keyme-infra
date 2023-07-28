resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name = "${var.project_name}-api-log-group"
  
  tags = {
    Application = "MainApi"
  }
}