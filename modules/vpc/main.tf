
#Create A VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
  }
}
#Create 4subnets 2 public and 2 private in the same VPC range is given in input.tfvars

#1.public subnet
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "public_subnet-${count.index+1}"
  }
}
#Private subnet
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private_subnet-${count.index+1}"
  }
}

#creating internet gateway and attaching it to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

#configure and elastic ip address basically which will be the ip address of our VPC
resource "aws_eip" "ngw" {
  domain   = "vpc"
  tags = {
    Name = "${var.env}ngw"
  }
}

#Create Network Gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "${var.env}-ngw"
  }
}

#Creating two route tables

#public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
#why we have taken 0.0.0.0
  #Add IGW to Public route table
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

#Private route table must have routing for default vpc and NAT gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  #why we have taken 0.0.0.0
  #Add NGW to private route table
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  #Add peering connection to private route table
  route {
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }
  tags = {
    Name = "private"
  }
}

#Add Peering connection
resource "aws_vpc_peering_connection" "peering" {
  peer_owner_id = var.account_no
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept = true
  tags = {
    Name = "peering from default-vpc-to-${var.env}-vpc"
  }
}

#ADD peering connection from default route table to default vpc
resource "aws_route" "default_route_table_id" {
  route_table_id            = var.default_route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

#since we will not be creating any instance in the public subnet so there is no need for peering connection however for private it is needed
#Add default and NGW to private route table
#Add IGW to Public route table

###ADD public route table to public subnet and private route table to private subnet via route tale association resource

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}