# Route53
resource "aws_route53_zone" "zone_main" {
  name = var.host_domain_name
  comment = var.host_domain_name
}

# ACM
resource "aws_acm_certificate" "acm" {
  domain_name       = var.sub_domain
  validation_method = "DNS"
}

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

module "ec2_profile" {
  source = "./modules/aws/ec2/public/profile"
  project_name = var.project_name
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name = var.key_pair_name
  public_key = file("~/.ssh/${var.key_pair_name}.pub")
}

resource "aws_instance" "public_ec2" {
  ami = "ami-0e4a9ad2eb120e054" # Amazon Linux2(ap-northeast-2)
  instance_type = "t2.micro" # 프리티어

  subnet_id = module.vpc_main.public_subnets_ids[0]
  vpc_security_group_ids = [
    module.ec2_sg.id
  ]

  key_name = aws_key_pair.ec2_key_pair.key_name
  user_data = file("./modules/aws/ec2/public/user_data.sh")
  iam_instance_profile = module.ec2_profile.ec2_profile

  tags = {
    Name = "${var.project_name}-public-ec2"
  }
}

resource "aws_eip" "ec2_eip" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "public_ec2_eip" {
  allocation_id = aws_eip.ec2_eip.id
  instance_id = aws_instance.public_ec2.id
}

# RDS
module "db_sg" {
  source = "./modules/aws/security_group"
  name = "${var.project_name}-rds-sg"
  vpc_id = module.vpc_main.vpc_id
  inbound_rules = var.db_inbound_rule
  outbound_rules = var.outbound_rule
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.project_name}-db-subnet-group"
  subnet_ids = module.vpc_main.private_subnets_ids
}

resource "aws_db_instance" "db" {
  identifier = "${var.project_name}-rds"
  vpc_security_group_ids = [ module.db_sg.id ]
  availability_zone = var.az_names[0]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  # 기본 데이터 인코딩 - utf8mb4
  engine = "mysql"
  engine_version = "8.0.32"
  instance_class = "db.t4g.micro"
  
  db_name = "${var.project_name}"
  username             = var.db_username
  password             = var.db_password

  max_allocated_storage = 1000
  allocated_storage = 20
  backup_retention_period = 5 # 백업본 저장기간
  ca_cert_identifier = "rds-ca-2019"
  storage_encrypted = true

  copy_tags_to_snapshot = true
  skip_final_snapshot = true
}

# S3
module "s3" {
  source = "./modules/aws/s3/ec2_access"
  name = "${var.project_name}-ec2-access-s3"
}

# API Gateway
module "api_gateway" {
  source = "./modules/aws/api_gateway"
  name = "${var.project_name}-api-gateway"

  stage = "$default"
  protocol_type = "HTTP"

  integration_type = "HTTP_PROXY"
  integration_method = "ANY"
  integration_ip = aws_eip.ec2_eip.public_ip

  route_key = "ANY /{proxy+}"
}

resource "aws_apigatewayv2_domain_name" "apigateway_domain_name" {
  # api gateway 커스텀 도메인 등록
  domain_name = var.api_server_domain

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.acm.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "api_gateway" {
  # route53에 - api gateway 커스텀 도메인 등록
  name    = aws_apigatewayv2_domain_name.apigateway_domain_name.domain_name
  type    = "A"
  zone_id = aws_route53_zone.zone_main.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.apigateway_domain_name.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.apigateway_domain_name.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api_mapping" "api_gateway" {
  # api gateway과 등록한 커스텀 domain연결
  api_id      = module.api_gateway.id
  domain_name = aws_apigatewayv2_domain_name.apigateway_domain_name.id
  stage       = module.api_gateway.stage_id
}

# CloudWatch Log
module "ec2_log_group" {
  source = "./modules/aws/cloud_watch/api_ec2"
  project_name = var.project_name
}