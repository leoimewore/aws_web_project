
resource "aws_security_group" "dbsg" {
  vpc_id = var.vpc-id
  name = "database_traffic"
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = "3306"
    protocol = "tcp"
    to_port = "3306"
    security_groups = [var.websg]
  }
  

  egress{
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    to_port = 0
    protocol = -1
  }


  tags = {
    "Name" = "allow http"
  }
}


resource "aws_db_instance" "default" {
  allocated_storage    = var.allocated_storage
  db_name              = "customer_db"
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.main.id
  vpc_security_group_ids = [aws_security_group.dbsg.id]
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = var.private_subnets

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_secretsmanager_secret" "example" {
  name = "example"
}


import {
  to = aws_secretsmanager_secret.example
  id = "arn:aws:secretsmanager:us-east-1:691490196261:secret:db_credentials-06Y90z"
}

data "aws_secretsmanager_secrets" "name" {
  
  
}
