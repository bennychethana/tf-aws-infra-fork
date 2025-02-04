# Create a security group for the RDS instance (PostgreSQL)
resource "aws_security_group" "rds_security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 5432 # PostgreSQL port
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_security_group.id] # Only allow access from the webapp security group
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

resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "postgres-db-parameter-group"
  family      = "postgres16"
  description = "Custom parameter group for PostgreSQL DB instance"

  tags = {
    Name = "postgres-db-parameter-group"
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = false
  # override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Secret for RDS Database Password
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "rds-db-password-fixed"
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.db_secrets_key.key_id
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
  })
}

# Create the RDS instance for PostgreSQL
resource "aws_db_instance" "rds_instance" {
  identifier        = var.rds_instance_identifier
  engine            = var.rds_engine
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  db_name           = var.rds_name
  username          = var.rds_username
  # password               = var.rds_password 
  password               = random_password.db_password.result
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible    = false
  skip_final_snapshot    = true

  # encryption with KMS key
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_key.arn

  tags = {
    Name = "csye6225-rds"
  }

  depends_on = [aws_db_subnet_group.rds_subnet_group]
}
