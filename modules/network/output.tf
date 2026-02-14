#output "subnet_pub_1a" {
#  value = aws_subnet.ec2_subnet_public_1a.id
#}
output "subnet_pub_1b" {
  value = aws_subnet.ec2_subnet_public_1b.id
}

output "vpc_id" {
  value = aws_vpc.ec2-vpc.id
}
