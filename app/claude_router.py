import os
import boto3

# Initialize Bedrock Runtime client (automatically routes via PrivateLink inside VPC)
bedrock = boto3.client("bedrock-runtime", region_name=os.getenv("AWS_REGION", "us-east-1"))

GUARDRAIL_ID = os.getenv("BEDROCK_GUARDRAIL_ID", "REPLACE_WITH_TF_OUTPUT")
GUARDRAIL_VERSION = os.getenv("BEDROCK_GUARDRAIL_VERSION", "1")

# Model IDs for FinOps cost tiering
HAIKU_MODEL = "anthropic.claude-3-5-haiku-20241022-v1:0"
SONNET_MODEL = "anthropic.claude-3-5-sonnet-20241022-v2:0"


def invoke_claude_finops(prompt: str, complexity: str = "low", large_context: str = "") -> dict:
    """
    Routes simple tasks to Claude Haiku (~75% cheaper) and complex tasks to Sonnet,
    while attaching Bedrock Guardrails and Prompt Caching checkpoints.
    """
    selected_model = SONNET_MODEL if complexity == "high" else HAIKU_MODEL

    system_blocks = [
        {"text": "You are a Senior Linux & Cloud SRE Assistant. Be concise and secure."}
    ]

    # Enable Prompt Caching when passing large runbooks or logs (>1,024 tokens)
    if large_context:
        system_blocks.append({"text": large_context})
        system_blocks.append({"cachePoint": {"type": "default"}})

    response = bedrock.converse(
        modelId=selected_model,
        messages=[{"role": "user", "content": [{"text": prompt}]}],
        system=system_blocks,
        guardrailConfig={
            "guardrailIdentifier": GUARDRAIL_ID,
            "guardrailVersion": GUARDRAIL_VERSION,
        },
        inferenceConfig={"maxTokens": 512, "temperature": 0.2},
    )

    usage = response.get("usage", {})
    return {
        "model_used": selected_model,
        "reply": response["output"]["message"]["content"][0]["text"],
        "input_tokens": usage.get("inputTokens", 0),
        "cache_read_tokens": usage.get("cacheReadInputTokens", 0),
        "output_tokens": usage.get("outputTokens", 0),
    }


if __name__ == "__main__":
    # Example test: Low complexity log triage routes to Haiku automatically
    result = invoke_claude_finops(
        prompt="Summarize why exit code 137 happens in a Linux Kubernetes pod.",
        complexity="low",
    )
    print(result)
