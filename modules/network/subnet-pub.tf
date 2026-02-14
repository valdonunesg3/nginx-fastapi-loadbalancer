resource "aws_subnet" "ec2_subnet_public_1a" {
  vpc_id                  = aws_vpc.ec2-vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone       = "${data.aws_region.current.region}a"
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-subnet-pub-1a"
    }
  )

}

resource "aws_subnet" "ec2_subnet_public_1b" {
  vpc_id                  = aws_vpc.ec2-vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, 2)
  availability_zone       = "${data.aws_region.current.region}b"
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-subnet-pub-1b"
    }
  )
}

resource "aws_route_table_association" "ec2_rtb_assoc_1a" {
  subnet_id      = aws_subnet.ec2_subnet_public_1a.id
  route_table_id = aws_route_table.ec2_public_route_table.id
}

resource "aws_route_table_association" "eks_rtb_assoc_1b" {
  subnet_id      = aws_subnet.ec2_subnet_public_1b.id
  route_table_id = aws_route_table.ec2_public_route_table.id
}