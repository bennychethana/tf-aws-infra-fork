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

variable "ami_id" {
  type        = string
  description = "value of ami id"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ec2_volume_type" {
  description = "EC2 volume type"
  type        = string
}

variable "ec2_intance_volume_size" {
  description = "EC2 instance volume size"
  type        = number
}

variable "rds_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "rds_name" {
  description = "Database name"
  type        = string
}

variable "rds_username" {
  description = "Database username"
  type        = string
}

variable "rds_port" {
  description = "Database port"
  type        = number
  default     = 5432

}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "rds_engine" {
  description = "RDS engine"
  type        = string
}

variable "rds_instance_identifier" {
  description = "RDS identifier"
  type        = string
}

variable "rds_allocated_storage" {
  description = "RDS storage size"
  type        = number
}

variable "domain_name" {
  type        = string
  description = "The domain name for the application (e.g., example.com)"
}

variable "key_name" {
  type        = string
  description = "The name of the EC2 key pair to use"
}

variable "scaleup_threshold" {
  type        = number
  description = "The threshold for scaling up"
}

variable "scaledown_threshold" {
  type        = number
  description = "The threshold for scaling down"
}