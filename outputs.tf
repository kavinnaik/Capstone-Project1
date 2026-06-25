output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web_server.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web_server.public_dns
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

