variable "private_key_path" {
  type    = string
  default = "./IEDEVINFRA.pem"
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair"
  default     = "IEDEVINFRA"
}

variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS Region"
}

variable "network_address_space" {
  default = "10.1.0.0/16"
}

variable "subnet_address_space" {
  default = "10.1.0.0/24"
}

variable "instance_type" {
  default = "t2.micro"
}
 