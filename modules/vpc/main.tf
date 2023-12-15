
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
}

#Create Network Gateway
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "${var.env}-ngw"
  }
}

