variable "project_name" { }

variable "host_domain_name" { }
variable "sub_domain" { }
variable "api_server_domain" { }

variable "vpc_cidr" { }
variable "az_names" { }
variable "public_subnets" { }
variable "private_subnets" { }

variable "ec2_inbound_rule" { }
variable "db_inbound_rule" { }
variable "outbound_rule" { }

variable "s3_origin_id" { }

variable "key_pair_name" { }
variable "db_username" { }
variable "db_password" { }