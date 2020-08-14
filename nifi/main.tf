provider "aws" {
  profile = "default"
  region  = "sa-east-1"
}

resource "aws_security_group" "security_group_nifi" {
  name        = "security_group_nifi"
  description = "Ambiente Nifi"

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
    Name = "security_group_nifi"
  }
}

resource "aws_db_subnet_group" "db_subnet_nifi" {
  name_prefix = "db_subnet_nifi"
  subnet_ids = ["subnet-0af5e79e16b97d051", "subnet-01508ca966f06f53a"]

  tags = {
    "Name" = "db_subnet_nifi"
  }
}

# Create a database server
resource "aws_db_instance" "ambary_db" {
  engine            = "mysql"
  engine_version    = "8.0.20"
  instance_class    = "db.t3.small"
  name              = "ambary_db"
  username          = "rootuser"
  password          = "rootpasswd"
  allocated_storage = 5 
  skip_final_snapshot = true
  
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet_nifi.name}"
  # etc, etc; see aws_db_instance docs for more
}




data "aws_ami" "amazon-linux-2-ami" {
 most_recent = true

 filter {
  name   = "owner-alias"
  values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }

 owners = ["amazon"]
}

resource "aws_instance" "ambari" {
  ami = "${data.aws_ami.amazon-linux-2-ami.id}"
  instance_type = "t3.micro"

  key_name = "Terraform"

  subnet_id = var.subnet_ids[0]
  vpc_security_group_ids = ["${aws_security_group.security_group_nifi.id}"]

  user_data = <<-EOF
    #! /bin/bash  -xe
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1


    sudo wget -nv http://public-repo-1.hortonworks.com/ambari/amazonlinux2/2.x/updates/2.7.3.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
    sudo yum repolist
    sudo yum update -y

    sudo yum install java-1.8.0-openjdk.x86_64 -y

    sudo wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.21-1.el8.noarch.rpmhttps://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.21-1.el8.noarch.rpm
    sudo yum install mysql-connector-java-8.0.21-1.el8.noarch.rpm -y

    sudo yum install ambari-server -y

    sudo ambari-server setup -s --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar --database=mysql --databasehost=${aws_db_instance.ambary_db.endpoint} --databaseport=${aws_db_instance.ambary_db.port} --databasename=ambary_db --databaseusername=rootuser --databasepassword=rootpasswd
  EOF

  tags = {
    "Name" = "ambari"
  }
 }