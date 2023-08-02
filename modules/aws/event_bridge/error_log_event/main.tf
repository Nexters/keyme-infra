// evnet brdige가 작동할 rule
resource "aws_cloudwatch_event_rule" "error_log_event_rule" {
  name = "${var.project_name}-error-log-event-rule"
  description = "Error Log Event Rule"
  schedule_expression = "rate(2 minutes)"
}

resource "aws_cloudwatch_event_target" "profile_generator_lambda_target" {
  arn = "arn:aws:lambda:ap-northeast-2:787596990041:function:keyme-serlverless-prod-errLogSendToDiscord"
  rule = aws_cloudwatch_event_rule.error_log_event_rule.name
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_rw_fallout_retry_step_deletion_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = module.profile_generator_lambda.lambda_function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.profile_generator_lambda_event_rule.arn
}