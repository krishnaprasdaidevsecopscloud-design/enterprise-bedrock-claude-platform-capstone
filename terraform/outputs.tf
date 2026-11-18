output "vpc_id" {
  value = aws_vpc.ai_vpc.id
}

output "bedrock_vpce_id" {
  value = aws_vpc_endpoint.bedrock_runtime.id
}

output "guardrail_id" {
  value = aws_bedrock_guardrail.enterprise_guardrail.guardrail_id
}

output "guardrail_version" {
  value = aws_bedrock_guardrail_version.prod_version.version
}
