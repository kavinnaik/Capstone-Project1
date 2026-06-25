resource "random_id" "suffix" {
  byte_length = 2
}

resource "aws_vpc" "main" {
  cidr_block           = var.network_address_space
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "project1-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_address_space
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "project1-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "project1-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "project1-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg-${random_id.suffix.hex}"
  description = "Allow HTTP access from my laptop"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project1-web-sg"
  }
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "project1-vpc-flow-logs"
  retention_in_days = 7
}

resource "aws_iam_role" "flow_logs_role" {
  name = "project1-flowlogs-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "project1-flowlogs-policy"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  log_destination_type = "cloud-watch-logs"
}

resource "aws_instance" "web_server" {
  ami                         = "ami-04df7d76c1b804451"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "project1-web-server"
  }

  depends_on = [
    aws_route_table_association.public
  ]
}

