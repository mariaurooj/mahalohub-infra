resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow all SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ssh -i "bastion-host.pem" -N -L 5436:flash-trade-dev-api.cveihgrsk6vs.us-east-1.rds.amazonaws.com:5432 ec2-user@ec2-54-152-145-136.compute-1.amazonaws.com -v

# ssh -i "bastion-host.pem"  -N -L 5436:flash-trade-dev-api.cveihgrsk6vs.us-east-1.rds.amazonaws.com:5432 ubuntu@ec2-3-92-203-140.compute-1.amazonaws.com -v

# psql -h flash-trade-dev-api.cveihgrsk6vs.us-east-1.rds.amazonaws.com -p 5432 -d flash_trade_dev_db -U secret_user

