provider "aws" {
  profile = "zeebe"
  region  = "sa-east-1"
}

resource "aws_security_group" "security_group_zeebe" {
  name        = "security_group_zeebe"
  description = "Ambiente Zeebe"

  vpc_id = "vpc-00beed42ea5ec1568"

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
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

  tags = {
    Name = "security_group_zeebe"
  }
}
