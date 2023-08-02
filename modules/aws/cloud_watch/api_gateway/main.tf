resource "aws_cloudwatch_log_group" "apigateway_log_group" {
  name = "${var.project_name}-api-gateway-log-group"
  retention_in_days = 14
  
  tags = {
    Application = "ApiGatewayLog"
  }
}