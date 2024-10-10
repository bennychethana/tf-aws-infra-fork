# AWS Networking Infrastructure Setup with Terraform

This repository contains Terraform configuration files to set up networking resources in AWS. The resources created include Virtual Private Clouds (VPC), subnets, Internet Gateways, Route Tables, and Routes.

## Prerequisites

- AWS account with proper permissions (dev and demo accounts).
- Terraform installed on your machine.
- AWS CLI installed and configured on your machine.
- Valid AWS profiles set up in the AWS CLI for Terraform to use:
    1. dev profile
    2. demo profile

## Infrastructure Setup

This Terraform configuration will set up the following AWS resources:
1. A VPC.
2. 3 public subnets (one in each availability zone).
3. 3 private subnets (one in each availability zone).
4. An Internet Gateway attached to the VPC.
5. A public route table with a route to the Internet Gateway for the public subnets.
6. A private route table for the private subnets.
7. Required associations between route tables and subnets.

## Terraform Commands

- `terraform init`
- `terraform plan`
- `terraform apply`
- `terraform destroy`
- `terraform fmt`
- `terraform validate`

## Developer Details
- Name : Chethana Benny
- Email : benny.c@northeastern.edu