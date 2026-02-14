resource "aws_internet_gateway" "ec2-igw" {
  vpc_id = aws_vpc.ec2-vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

resource "aws_route_table" "ec2_public_route_table" {
  vpc_id = aws_vpc.ec2-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ec2-igw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-pub-route-table"
    }
  )
}