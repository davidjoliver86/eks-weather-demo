data "aws_region" "current" {}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
}

resource "aws_subnet" "public" {
  for_each          = var.subnets.public
  vpc_id            = aws_vpc.this.id
  availability_zone = format("%s%s", data.aws_region.current.name, each.key)
  cidr_block        = each.value

  tags = {
    "kubernetes.io/role/elb" = "1"
    type                     = "public"
  }
}

resource "aws_subnet" "private" {
  for_each          = var.subnets.private
  vpc_id            = aws_vpc.this.id
  availability_zone = format("%s%s", data.aws_region.current.name, each.key)
  cidr_block        = each.value

  tags = {
    "kubernetes.io/role/internal-elb" = "1"
    type                              = "private"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_eip" "nat" {
  for_each = var.subnets.public
  domain   = "vpc"

  tags = {
    az = format("%s%s", data.aws_region.current.name, each.key)
  }
}

resource "aws_nat_gateway" "this" {
  for_each      = var.subnets.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    az = format("%s%s", data.aws_region.current.name, each.key)
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    type = "public"
  }
}

resource "aws_route_table" "private" {
  for_each = var.subnets.private
  vpc_id   = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = {
    type = "private"
    az   = format("%s%s", data.aws_region.current.name, each.key)
  }
}

resource "aws_route_table_association" "public" {
  for_each       = var.subnets.public
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each       = var.subnets.private
  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = aws_subnet.private[each.key].id
}
