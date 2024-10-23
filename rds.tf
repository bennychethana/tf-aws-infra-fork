# Create a security group for the RDS instance (PostgreSQL)
resource "aws_security_group" "rds_security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 5432 # PostgreSQL port
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_security_group.id] # Only allow access from the webapp security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_security_group"
  }

  depends_on = [aws_vpc.vpc]
}

# Create a subnet group for RDS, using private subnets
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "rds_subnet_group"
  }
}

# Create the RDS instance for PostgreSQL
resource "aws_db_instance" "rds_instance" {
  identifier             = "csye6225"
  engine                 = "postgres"    # PostgreSQL engine
  instance_class         = "db.t3.micro" # Cheapest instance type
  allocated_storage      = 20
  db_name                = "csye6225"
  username               = "csye6225"
  password               = "password"
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible    = false # Not exposed to the public internet
  skip_final_snapshot    = true

  tags = {
    Name = "csye6225-rds"
  }

  depends_on = [aws_db_subnet_group.rds_subnet_group]
}
