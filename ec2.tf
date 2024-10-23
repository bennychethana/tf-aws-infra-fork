resource "aws_security_group" "webapp_security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "application security group"
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_instance" "webapp_instance" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_subnets[0].id
  vpc_security_group_ids      = [aws_security_group.webapp_security_group.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              echo "DATABASE_HOST='${aws_db_instance.rds_instance.address}'" >> /etc/environment
              echo "DATABASE_USER='${var.rds_username}'" >> /etc/environment
              echo "DATABASE_PASSWORD='${var.rds_password}'" >> /etc/environment
              echo "DATABASE_NAME='${var.rds_name}'" >> /etc/environment
              echo "DATABASE_PORT='${var.rds_port}'" >> /etc/environment

              # Source the new environment variables
              source /etc/environment

              # Run migrations as csye6225 user
              sudo -u csye6225 bash -c 'source /home/csye6225/webapp/venv/bin/activate && python3 /home/csye6225/webapp/manage.py makemigrations && python3 /home/csye6225/webapp/manage.py migrate'

              # Reload and restart services
              systemctl daemon-reload
              systemctl enable webapp.service
              systemctl restart webapp.service

              EOF

  root_block_device {
    volume_size           = var.ec2_intance_volume_size
    volume_type           = var.ec2_volume_type
    delete_on_termination = true
  }

  disable_api_termination = false

  tags = {
    Name = "webapp_instance"
  }

  depends_on = [aws_internet_gateway.igw, aws_subnet.public_subnets, aws_security_group.webapp_security_group, aws_db_instance.rds_instance]
}