#output "subnet_pub_1a" {
#  value = module.ec2_network.subnet_pub_1a
#}

#output "subnet_pub_1b" {
#  value = module.ec2_network.subnet_pub_1b
#}

output "instance_ids" {
  value = module.ec2_instance.instance_ids
}

output "instance_public_ips" {
  value = module.ec2_instance.public_ips
}