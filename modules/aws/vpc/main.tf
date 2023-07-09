resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags = {
    Name = format("%s", var.vpc_name)
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s-igw", var.vpc_name)
  } 
}

# public
resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets
  vpc_id = aws_vpc.vpc.id
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["zone"]

  tags = {
    Name = format(
      "%s-public-subnet-%s",
      var.vpc_name,
      each.key
    )
  }
}

resource "aws_route_table" "public_route_table" {
  for_each = var.public_subnets
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = format(
      "%s-public-route-table-%s",
      var.vpc_name,
      each.key
    )
  }
}

resource "aws_route_table_association" "public_route" {
  for_each = var.public_subnets
  subnet_id = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_route_table[each.key].id
}

# private
resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets
  vpc_id = aws_vpc.vpc.id
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["zone"]

  tags = {
    Name = format(
      "%s-private-subnet-%s",
      var.vpc_name,
      each.key
    )
  }
}

resource "aws_route_table" "private_route_table" {
  for_each = var.private_subnets
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format(
      "%s-private-route-table-%s",
      var.vpc_name,
      each.key
    )
  }
}

resource "aws_route_table_association" "private_route" {
  for_each = var.private_subnets
  subnet_id = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_route_table[each.key].id 
}



