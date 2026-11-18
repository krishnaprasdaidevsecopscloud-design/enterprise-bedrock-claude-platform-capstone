# Enterprise AI Security: Block prompt injections and redact PII automatically
resource "aws_bedrock_guardrail" "enterprise_guardrail" {
  name                      = "${var.project_name}-guardrail"
  blocked_input_messaging   = "Request blocked by Enterprise AI Security Guardrails."
  blocked_outputs_messaging = "Response redacted due to Enterprise Data Privacy policy."
  description               = "Enforces PII masking and prompt injection protection for Claude"

  content_policy_config {
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "PROMPT_ATTACK"
    }
    filters_config {
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
      type            = "HATE"
    }
  }

  sensitive_information_policy_config {
    pii_entities_config {
      action = "ANONYMIZE"
      type   = "EMAIL"
    }
    pii_entities_config {
      action = "ANONYMIZE"
      type   = "PHONE"
    }
    pii_entities_config {
      action = "BLOCK"
      type   = "AWS_SECRET_KEY"
    }
  }
}

resource "aws_bedrock_guardrail_version" "prod_version" {
  guardrail_arn = aws_bedrock_guardrail.enterprise_guardrail.guardrail_arn
  description   = "Production Guardrail v1"
}
