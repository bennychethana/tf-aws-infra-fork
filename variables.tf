variable "aws_region" {
  type        = string
  description = "value of AWS Region to deploy resources"
}

variable "vpc_cidr" {
  type        = string
  description = "value of cidr block"
}

variable "vpc_name" {
  type        = string
  description = "value of vpc name"
}

variable "internet_gateway_name" {
  type        = string
  description = "value of internet gateway"
}