#create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
  depends_on = [aws_vpc.vpc]

}

# create public subnets
resource "aws_subnet" "public_subnets" {
  count                   =    length(local.selected_zones)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = local.selected_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet-${count.index}"
  }
  depends_on = [
    aws_vpc.vpc,
  ]
}

# public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_route_table"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Association of Public Route Table with Public Subnets
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(local.selected_zones)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
  depends_on = [
    aws_subnet.public_subnets,
    aws_route_table.public_route_table
  ]
}

# create private subnets
resource "aws_subnet" "private_subnets" {
  count                   = length(local.selected_zones)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + length(local.selected_zones))
  availability_zone       = local.selected_zones[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "private_subnet-${count.index}"
  }
  depends_on = [
    aws_vpc.vpc,
  ]
}

# private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "private_route_table"
  }
}

# Association of Private Route Table with Private Subnets
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(local.selected_zones) # Use the count of available zones
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
  depends_on = [
    aws_subnet.private_subnets,
    aws_route_table.private_route_table
  ]
}
