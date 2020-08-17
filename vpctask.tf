resource "aws_vpc" "vpc1" {
  cidr_block  = "192.168.0.0/16"
  enable_dns_support="true"
  enable_dns_hostnames="true"
  instance_tenancy = "default"

  tags = {
    Name = "vpctask"
  }
}


resource "aws_subnet" "publicsubnet" {
  vpc_id     =  aws_vpc.vpc1.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "privatesubnet" {
  vpc_id     =  aws_vpc.vpc1.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_internet_gateway" "ingateway" {
  vpc_id =  aws_vpc.vpc1.id

  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "routetable" {
  vpc_id =  aws_vpc.vpc1.id
  
  tags = {
    Name = "route_table"
  }
}

resource "aws_route" "route" {
  route_table_id   =   aws_route_table.routetable.id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id =  aws_internet_gateway.ingateway.id
  
}

resource "aws_route_table_association" "routetableassoc" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.routetable.id
}



resource "tls_private_key" "task3_key" { 
  algorithm = "RSA"
}

resource "aws_key_pair" "task3_key" {
key_name = "task3_key"
public_key= tls_private_key.task3_key.public_key_openssh
}


resource "aws_security_group" "wpsg" {
  name        = "wordpress"
  description = "allow ssh and http"
  vpc_id = aws_vpc.vpc1.id
ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

tags = {
    Name = "wordpress"
  }
}



resource "aws_security_group" "mysqlsg" {
  name   = "mysql"
  description = "allow mysql"
  vpc_id   =   aws_vpc.vpc1.id


  ingress {
    description = "MYSQL/Aurora"
    from_port  = 0
    to_port  = 3306
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
  egress {
    from_port  = 0
    to_port  = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "mysql"
  }
}





resource "aws_instance" "wordpress" {
  ami  = "ami-000cbce3e1b899ebd"
  instance_type  = "t2.micro"
  key_name        = "task3_key"
  security_groups =  [  aws_security_group.wpsg.id  ]
  subnet_id =  aws_subnet.publicsubnet.id
  
  tags = {
    Name = "wpos"
  }
}


resource "aws_instance" "mysql" {
  ami          = "ami-08706cb5f68222d09"
  instance_type  = "t2.micro"
  key_name        = "task3_key"
  security_groups =  [  aws_security_group.mysqlsg.id  ]
  subnet_id =  aws_subnet.privatesubnet.id

  tags = {
    Name = "mysqlos"
  }
}


