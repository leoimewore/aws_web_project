

resource "aws_vpc" "main" {
  cidr_block = var.vpc-CIDR
  tags = {
    Name = "main"
  }
}




data "aws_subnets" "selected" {
  filter {
    name   = "tag:Name"
    values = ["Public-subnet-*"]
  }
}

data "aws_subnet" "example" {
  for_each = toset(data.aws_subnets.selected.ids)
  id       = each.value
}



resource "aws_subnet" "main-subnet" {
  for_each = var.prefix
 
  availability_zone_id = each.value["az"]
  cidr_block = each.value["cidr"]
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "Public-subnet-${each.key}"
  }
}

resource "aws_subnet" "private-subnet" {
  for_each = var.suffix
 
  availability_zone_id = each.value["az"]
  cidr_block = each.value["cidr"]
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "Private-subnet-${each.key}"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["Private-subnet-*"]
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}



resource "aws_internet_gateway" "Igw" {
  vpc_id =aws_vpc.main.id 

  tags = {
    Name="Igw"
  } 
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }

  tags = {
    Name = "PublicRT"
  }
}


resource "aws_route_table_association" "route1" {
  count ="${length(data.aws_subnet.example)}"
  subnet_id = "${element([for s in data.aws_subnet.example : s.id],count.index)}"
  route_table_id = aws_route_table.rt1.id
}

resource "aws_eip" "ip" {
  domain     = "vpc"
  count ="${length(data.aws_subnet.private)}"
  tags = {
    Name = "t4-elasticIP"
  }
}

//Start from here???


resource "aws_nat_gateway" "privatengw" {

  count ="${length(data.aws_subnet.example)}"
  allocation_id = "${element(aws_eip.ip.*.id, count.index)}"
  subnet_id = "${element([for s in data.aws_subnet.example : s.id],count.index)}"

  tags = {
    Name = "gw NAT-${count.index}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.Igw]
}


resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.main.id
  count ="${length(data.aws_subnet.private)}"
 


  route {
    
    cidr_block = "0.0.0.0/0"
    gateway_id= "${element(aws_nat_gateway.privatengw.*.id,count.index)}"
  }

  tags = {
    Name = "PrivateRT${count.index}"
  }
}


resource "aws_route_table_association" "route2" {
  count ="${length(data.aws_subnet.private)}"
  subnet_id = "${element([for s in data.aws_subnet.private : s.id],count.index)}"
  route_table_id = "${element(aws_route_table.rt2.*.id, count.index)}"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3"
}

resource "aws_vpc_endpoint_route_table_association" "example" {
  count ="${length(data.aws_subnet.private)}"
  route_table_id = "${element(aws_route_table.rt2.*.id, count.index)}"
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}




resource "aws_instance" "myec2" {
    ami = "ami-051f7e7f6c2f40dc1"
    instance_type = "t2.micro"
    count ="${length(data.aws_subnet.private)}"
    subnet_id = "${element([for s in data.aws_subnet.private : s.id],count.index)}"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.private_sg.id]
    tags = {
        Name ="ec2-${count.index}"
    }
  
}

resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id
  name = "ssh-s3"
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "TCP"
    to_port = 22
  }

   ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 80
    protocol = "TCP"
    to_port = 80
  }


  egress{
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    to_port = 0
    protocol = -1
  }


  tags = {
    "Name" = "ssh into s3"
  }
}



