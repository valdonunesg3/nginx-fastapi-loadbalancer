module "ec2_network" {
  source       = "./modules/network"
  cidr_block   = var.cidr_block
  project_name = var.project_name
  tags         = local.tags
}

module "ec2_instance" {
  source         = "./modules/ec2"
  cidr_block     = var.cidr_block
  project_name   = var.project_name
  tags           = local.tags
  vpc_id         = module.ec2_network.vpc_id
  subnet_id      = module.ec2_network.subnet_pub_1b
  instance_count = var.instance_count
}