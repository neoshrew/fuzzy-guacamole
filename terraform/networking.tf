locals {
  n_cidr_bits    = ceil(log(var.az_count, 2))
  az_cidr_blocks = [
    for az_num in range(var.az_count):
    cidrsubnet(var.vpc_cidr, local.n_cidr_bits, az_num)
  ]
  # Usually this would all be split up, however given I'll be making
  # a single public Instance for this exercise, leave the
  # private alone for the time being.
  # public_az_blocks = [
  #   for az_num in range(var.az_count):
  #   cidrsubnet(local.az_cidr_blocks[az_num], 1, 0)
  # ]
  # private_az_blocks = [
  #   for az_num in range(var.az_count):
  #   cidrsubnet(local.az_cidr_blocks[az_num], 1, 0)
  # ]
}

data aws_availability_zones azs {}

resource aws_vpc this {
  cidr_block = var.vpc_cidr

  tags = {
    Name = local.project_prefix
  }
}

resource aws_internet_gateway this {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.project_prefix
  }
}

resource aws_subnet public {
  count = var.az_count

  vpc_id     = aws_vpc.this.id
  cidr_block = local.az_cidr_blocks[count.index]

  tags = {
    Name = "${local.project_prefix} Public subnet ${count.index}"
  }
}

resource aws_route_table public {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.project_prefix} Public"
  }
}

resource aws_route_table_association public_igw {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource aws_route public_igw {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.this.id
}
