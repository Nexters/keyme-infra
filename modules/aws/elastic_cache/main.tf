resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.name}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  num_cache_nodes      = 1
  apply_immediately    = true
  security_group_ids = [
    var.security_group_id
  ] 
  subnet_group_name = aws_elasticache_subnet_group.redis_subnet_group.name
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.name}-elasticache-subnet-group"
  subnet_ids = var.subnet_ids
}