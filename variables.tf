variable "cidr_block" {
  type        = string
  description = "Networking CIDR block to be used for the VPC"
}

variable "project_name" {
  type        = string
  description = "Project name to used to name the resources (Name tag) "
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to be created"
}

