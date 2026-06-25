variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}

variable "network_address_space" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_address_space" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.1.0.0/24"
}

variable "allowed_ip" {
  description = "Public IP allowed to access the web server"
  type        = string
  default     = "20.192.6.130/32"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}



