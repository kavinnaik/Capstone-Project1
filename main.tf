# UNIQUE SUFFIX

resource "random_id" "suffix" {
  byte_length = 2
}

# DATA
data "aws_availability_zones" "available" {}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  } 
}

# NETWORKING

resource "aws_vpc" "vpc" {
  cidr_block           = var.network_address_space
  enable_dns_hostnames = true

  tags = {
    Name = "project1-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "project1-igw"
  }
}

resource "aws_subnet" "subnet" {
  cidr_block              = var.subnet_address_space
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "project1-subnet"
  }
}

# ROUTING

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "project1-rt"
  }
}

resource "aws_route_table_association" "rta-subnet" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rtb.id
}

# SECURITY GROUP

resource "aws_security_group" "aws-sg" {
  name   = "mysecuritygroup-${random_id.suffix.hex}"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["20.192.6.130/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    Name = "project1-web-sg"
  }
}

# VPC FLOW LOGS

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "/aws/vpc/flowlogs-${random_id.suffix.hex}"
}

resource "aws_iam_role" "flow_logs_role" {
  name = "vpc-flow-logs-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"

        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "vpc-flow-logs-policy-${random_id.suffix.hex}"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "vpc_flow_log" {
  vpc_id               = aws_vpc.vpc.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
}

# EC2 INSTANCE

resource "aws_instance" "instance1" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.aws-sg.id]
  key_name               = var.key_name

  user_data = file("${path.module}/userdata.sh")

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "project1-web-server"
  }
}

# OUTPUTS

output "instance_id" {
  value = aws_instance.instance1.id
}

output "public_ip" {
  value = aws_instance.instance1.public_ip
}

output "public_dns" {
  value = aws_instance.instance1.public_dns
}

output "website_url" {
  value = "http://${aws_instance.instance1.public_dns}"
}
 