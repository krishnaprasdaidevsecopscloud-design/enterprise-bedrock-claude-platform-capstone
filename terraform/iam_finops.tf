# Least-privilege IAM Role restricting access strictly to approved Claude models
resource "aws_iam_role" "bedrock_app_role" {
  name = "${var.project_name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "://amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "bedrock_least_privilege" {
  name = "${var.project_name}-invoke-policy"
  role = aws_iam_role.bedrock_app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowApprovedClaudeModelsOnly"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-3-5-sonnet-*",
          "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-3-5-haiku-*"
        ]
      },
      {
        Sid    = "EnforceGuardrailUsage"
        Effect = "Allow"
        Action = [
          "bedrock:ApplyGuardrail"
        ]
        Resource = aws_bedrock_guardrail.enterprise_guardrail.guardrail_arn
      }
    ]
  })
}

# FinOps Governance: CloudWatch Alarm to catch runaway Claude token consumption
resource "aws_cloudwatch_metric_alarm" "bedrock_token_spike" {
  alarm_name          = "${var.project_name}-high-token-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "InputTokenCount"
  namespace           = "AWS/Bedrock"
  period              = 3600
  statistic           = "Sum"
  threshold           = var.monthly_token_alarm_threshold
  alarm_description   = "FinOps Alert: Hourly Bedrock input token usage exceeded threshold."
}
