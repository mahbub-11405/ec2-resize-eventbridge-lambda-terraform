
resource "aws_cloudwatch_event_rule" "resize_schedule" {
  name                = var.name
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "resize_target" {
  rule      = aws_cloudwatch_event_rule.resize_schedule.name
  target_id = "target-${var.name}"
  arn       = var.lambda_arn

  input = jsonencode({
    instance_id = var.instance_id,
    target_type = var.target_type
  })
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge-${var.name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.resize_schedule.arn

  depends_on = [aws_cloudwatch_event_rule.resize_schedule]
}
