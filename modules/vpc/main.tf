# VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "eks-vpc"
    Environment = var.env
  }
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name        = "eks-igw"
    Environment = var.env
  }
  depends_on = [aws_vpc.eks_vpc]
}

# Public Subnets
resource "aws_subnet" "eks_public_subnet" {
  vpc_id                  = aws_vpc.eks_vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                     = "eks-public-subnet-${count.index + 1}"
    Environment              = var.env
    "kubernetes.io/role/elb" = "1"
  }
  depends_on = [aws_vpc.eks_vpc]
}

#Public Route Table
resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
  tags = {
    Name        = "eks-public-route-table"
    Environment = var.env
  }
}

#Public Route Table Association
resource "aws_route_table_association" "eks_public_rt_association" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.eks_public_subnet[count.index].id
  route_table_id = aws_route_table.eks_public_rt.id
}


#Elastic IP for NAT Gateway
resource "aws_eip" "eks_nat_ip" {
  count = length(var.availability_zones)
  tags = {
    Name        = "eks-nat-ip"
    Environment = var.env
  }
  depends_on = [aws_vpc.eks_vpc]
}

# NAT Gateway for Private Subnet
resource "aws_nat_gateway" "eks_nat_gateway" {
  count         = length(var.availability_zones)
  subnet_id     = aws_subnet.eks_public_subnet[count.index].id
  allocation_id = aws_eip.eks_nat_ip[count.index].id
  tags = {
    Name        = "eks-nat"
    Environment = var.env
  }
  depends_on = [
    aws_internet_gateway.eks_igw,
    aws_eip.eks_nat_ip,
  ]
}

# Private Subnet
resource "aws_subnet" "eks_private_subnet" {
  vpc_id                  = aws_vpc.eks_vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = var.private_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name                              = "eks-private-subnet-${count.index + 1}"
    Environment                       = var.env
    "kubernetes.io/role/internal-elb" = "1"
  }
  depends_on = [aws_vpc.eks_vpc]
}

#Private Route Table
resource "aws_route_table" "eks_private_rt" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gateway[count.index].id
  }
  tags = {
    Name        = "eks-private-route-table"
    Environment = var.env
  }
}

#Private Route Table Association
resource "aws_route_table_association" "eks_private_rt_association" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = aws_subnet.eks_private_subnet[count.index].id
  route_table_id = aws_route_table.eks_private_rt[count.index].id
}