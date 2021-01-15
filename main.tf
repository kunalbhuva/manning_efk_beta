provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "manning-beta-env" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "manning-beta-env"
  }
}

resource "aws_subnet" "subnet-uno" {
  cidr_block        = cidrsubnet(aws_vpc.manning-beta-env.cidr_block, 3, 1)
  vpc_id            = aws_vpc.manning-beta-env.id
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "ingress-all-test" {
  name = "allow-all-sg"

  vpc_id = aws_vpc.manning-beta-env.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "kb-manning-efk-beta" {
  key_name   = "kb-manning-efk-beta"
  public_key = file(var.key_pair_path["public_key_path"])
}


resource "aws_instance" "instance_1" {
  ami             = "ami-0739f8cdb239fe9ae"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.kb-manning-efk-beta.key_name
  security_groups = [aws_security_group.ingress-all-test.id]
  subnet_id       = aws_subnet.subnet-uno.id
  user_data       = file("cloud-config.yaml")

  tags = {
    Name = "kb manning instance 1"
  }
}

resource "aws_eip" "ip-manning-beta-env-1" {
  instance = aws_instance.instance_1.id
  vpc      = true
}

# resource "aws_instance" "instance_2" {
#   ami             = "ami-0739f8cdb239fe9ae"
#   instance_type   = "t2.micro"
#   key_name        = aws_key_pair.kb-manning-efk-beta.key_name
#   security_groups = [aws_security_group.ingress-all-test.id]
#   subnet_id       = aws_subnet.subnet-uno.id
#   user_data       = file("cloud-config.yaml")

#   tags = {
#     Name = "kb manning instance 2"
#   }
# }

# resource "aws_eip" "ip-manning-beta-env-2" {
#   instance = aws_instance.instance_2.id
#   vpc      = true
# }

resource "aws_internet_gateway" "manning-beta-env-gw" {
  vpc_id = aws_vpc.manning-beta-env.id

  tags = {
    Name = "manning-beta-env-gw"
  }
}

resource "aws_route_table" "route-table-manning-beta-env" {
  vpc_id = aws_vpc.manning-beta-env.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.manning-beta-env-gw.id
  }
  tags = {
    Name = "manning-beta-env-route-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet-uno.id
  route_table_id = aws_route_table.route-table-manning-beta-env.id
}

# resource "aws_instance" "instance_2" {
#   ami           = "ami-0739f8cdb239fe9ae"
#   instance_type = "t2.micro"
# }
