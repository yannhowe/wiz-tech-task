resource "aws_vpc" "wiz-tech-task" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Wiz Tech Task VPC"
  }
}

resource "aws_subnet" "wiz-tech-task-subnet-1" {
  vpc_id                  = aws_vpc.wiz-tech-task.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wiz-tech-task-subnet-1"
  }
}

resource "aws_subnet" "wiz-tech-task-subnet-2-private" {
  vpc_id                  = aws_vpc.wiz-tech-task.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wiz-tech-task-subnet-2-private"
  }
}

resource "aws_subnet" "wiz-tech-task-subnet-3-private" {
  vpc_id                  = aws_vpc.wiz-tech-task.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "wiz-tech-task-subnet-3-private"
  }
}

resource "aws_internet_gateway" "wiz-tech-task-internet-gateway" {
  vpc_id = aws_vpc.wiz-tech-task.id

  tags = {
    Name = "wiz-tech-task-internet-gateway"
  }
}

resource "aws_eip" "wiz-tech-task-nat-gateway-eip" {
  vpc = true
}

resource "aws_nat_gateway" "wiz-tech-task-nat-gateway" {
  allocation_id = aws_eip.wiz-tech-task-nat-gateway-eip.id
  subnet_id     = aws_subnet.wiz-tech-task-subnet-1.id
}

resource "aws_route_table" "wiz-tech-task-public-route-table" {
  vpc_id = aws_vpc.wiz-tech-task.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wiz-tech-task-internet-gateway.id
  }

  tags = {
    Name = "wiz-tech-task-public-route-table"
  }
}

resource "aws_route_table" "wiz-tech-task-private-route-table" {
  vpc_id = aws_vpc.wiz-tech-task.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.wiz-tech-task-nat-gateway.id
  }

  tags = {
    Name = "wiz-tech-task-private-route-table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.wiz-tech-task-subnet-1.id
  route_table_id = aws_route_table.wiz-tech-task-public-route-table.id
}

resource "aws_route_table_association" "private2_rt_a" {
  subnet_id      = aws_subnet.wiz-tech-task-subnet-2-private.id
  route_table_id = aws_route_table.wiz-tech-task-private-route-table.id
}

resource "aws_route_table_association" "private3_rt_a" {
  subnet_id      = aws_subnet.wiz-tech-task-subnet-3-private.id
  route_table_id = aws_route_table.wiz-tech-task-private-route-table.id
}


resource "aws_security_group" "allow_ssh_from_everywhere" {
  name        = "allow_ssh_from_everywhere"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.wiz-tech-task.id

  ingress {
    description = "Allow SSH from everywhere"
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
    Name = "allow_ssh_from_everywhere"
  }
}

resource "aws_security_group" "allow_icmp_from_everywhere" {
  name        = "allow_icmp_from_everywhere"
  description = "Allow ICMP inbound traffic"
  vpc_id      = aws_vpc.wiz-tech-task.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_icmp_from_everywhere"
  }
}

resource "aws_security_group" "allow_ssh_from_vpc" {
  name        = "allow_ssh_from_vpc"
  description = "Allow ssh inbound traffic from VPCs"
  vpc_id      = aws_vpc.wiz-tech-task.id

  ingress {
    description = "Allow ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.wiz-tech-task-subnet-1.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_from_vpc"
  }
}

resource "aws_security_group" "allow_mongo_from_vpc" {
  name        = "allow_mongo_from_vpc"
  description = "Allow mongodb inbound traffic"
  vpc_id      = aws_vpc.wiz-tech-task.id

  ingress {
    description = "Allow mongo from VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.wiz-tech-task-subnet-1.cidr_block, aws_subnet.wiz-tech-task-subnet-2-private.cidr_block, aws_subnet.wiz-tech-task-subnet-3-private.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_mongo_from_vpc"
  }
}