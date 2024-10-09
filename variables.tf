variable "aws_region" {
  type        = string
  description = "value of AWS Region to deploy resources"
}

variable "cidr" {
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
 
variable "aws_availability_zones" {
  type        = list(string)
  description = "value of availability zones"
}
 
variable "public_subnets_cidr_blocks" {
  type        = list(string)
  description = "value of public subnets cidr blocks"
}
 
variable "private_subnets_cidr_blocks" {
  type        = list(string)
  description = "value of private subnets cidr blocks"
}