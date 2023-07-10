output "url" {
  value = aws_apigatewayv2_stage.stage.invoke_url
}

output "endpoint" {
  value = aws_apigatewayv2_api.api_gateway.api_endpoint
}

output "id" {
  value = aws_apigatewayv2_api.api_gateway.id
}

output "stage_id" {
  value = aws_apigatewayv2_stage.stage.id
}