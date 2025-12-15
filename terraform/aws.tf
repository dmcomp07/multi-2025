# AWS RDS Instance
resource "aws_db_instance" "production" {
  allocated_storage    = var.db_allocated_storage
  db_name              = replace(var.db_name, "-", "_")
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = var.db_instance_class
  username             = var.db_username
  password             = random_password.db_password.result
  parameter_group_name = aws_db_parameter_group.production.name
  skip_final_snapshot  = var.environment == "prod" ? false : true
  final_snapshot_identifier = var.environment == "prod" ? "${var.cluster_name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  multi_az = var.environment == "prod" ? true : false

  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = var.environment == "prod" ? 30 : 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  enable_clouddwatch_logs_exports = ["postgresql"]

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = var.common_tags
}

# RDS Parameter Group
resource "aws_db_parameter_group" "production" {
  name   = "${var.cluster_name}-${var.environment}-params"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = var.common_tags
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.cluster_name}-${var.environment}-rds"
  description = "RDS security group"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}

# KMS Key for RDS encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = var.common_tags
}

# Random password for RDS
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.cluster_name}-${var.environment}-db-password"
  recovery_window_in_days = 7

  tags = var.common_tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id      = aws_secretsmanager_secret.db_password.id
  secret_string  = random_password.db_password.result
}
