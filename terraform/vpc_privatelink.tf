# Isolated VPC with zero public internet exposure for Bedrock traffic
resource "aws_vpc" "ai_vpc" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.ai_vpc.id
  cidr_block        = "10.50.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-private-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.ai_vpc.id
  cidr_block        = "10.50.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.project_name}-private-b"
  }
}

resource "aws_security_group" "bedrock_vpce_sg" {
  name        = "${var.project_name}-bedrock-vpce-sg"
  description = "Allow HTTPS traffic from internal EKS/EC2 workloads to Bedrock"
  vpc_id      = aws_vpc.ai_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.ai_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS PrivateLink Interface Endpoint for Bedrock Runtime
resource "aws_vpc_endpoint" "bedrock_runtime" {
  vpc_id              = aws_vpc.ai_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  security_group_ids  = [aws_security_group.bedrock_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-bedrock-vpce"
  }
}
