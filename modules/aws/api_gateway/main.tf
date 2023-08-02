resource "aws_apigatewayv2_api" "api_gateway" {
  name = var.name
  protocol_type = var.protocol_type

}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  name = var.stage
  auto_deploy = true

  access_log_settings {
    destination_arn = var.log_group_arn
    format = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"user\":\"$context.identity.user\",\"requestTime\":\"$context.requestTime\",\"httpMethod\":\"$context.httpMethod\",\"resourcePath\":\"$context.routeKey\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"responseLength\":\"$context.responseLength\"}"
  }
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id = aws_apigatewayv2_api.api_gateway.id

  integration_type = var.integration_type
  integration_method = var.integration_method
  integration_uri = "http://${var.integration_ip}:80/{proxy}"
}

resource "aws_apigatewayv2_route" "route" {
  api_id = aws_apigatewayv2_api.api_gateway.id

  route_key = var.route_key
  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}