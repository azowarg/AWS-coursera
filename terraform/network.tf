terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.50.0"
    }
  }
}

resource "aws_vpc" "app-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    "Name" = "app-vpc"
  }
}
resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    "Name" = "app-igw"
  }
}

resource "aws_subnet" "subnets" {
  vpc_id                  = aws_vpc.app-vpc.id
  for_each                = var.subnets
  cidr_block              = each.value.cidr
  availability_zone       = each.value.zone
  map_public_ip_on_launch = each.value.external_ip
  tags = {
    "Name" = each.key
  }

}
resource "aws_route_table" "app-routetable-public" {
  vpc_id = aws_vpc.app-vpc.id
  route {
    gateway_id = aws_internet_gateway.app-igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    "Name" = "app-routetable-public"
  }
}
resource "aws_route_table_association" "public" {
  for_each = {
    for subnet, params in var.subnets : subnet => params
    if params.external_ip
  }
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.app-routetable-public.id

}

resource "aws_route_table" "app-routetable-private" {
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    "Name" = "app-routetable-private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = {
    for subnet, params in var.subnets : subnet => params
    if !params.external_ip
  }
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.app-routetable-private.id

}