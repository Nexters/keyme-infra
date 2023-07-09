# VPC
module "vpc_main" {
  source = "./modules/aws/vpc"
  vpc_name = "${var.project_name}-vpc"

  cidr = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets  
}

# ECR
module "ecr" {
  source = "./modules/aws/ecr"
  name = "${var.project_name}-api-server-ecr"
}

# EC2
module "ec2_sg" {
  source = "./modules/aws/security_group"
  name = "${var.project_name}-public-ec2-sg"
  vpc_id = module.vpc_main.vpc_id
  inbound_rules = var.ec2_inbound_rule
  outbound_rules = var.outbound_rule
}
