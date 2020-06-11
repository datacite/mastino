resource "aws_efs_file_system" "stage" {
  creation_token = "efs-stage"

  tags = {
    Name = "EFS-Stage"
  }
}

resource "aws_elasticache_subnet_group" "memcached-stage" {
    name = "memcached-stage"
    description = "Elasticache memcached-stage subnet group"
    subnet_ids = [data.aws_subnet.datacite-private.id,
                  data.aws_subnet.datacite-alt.id]
}

resource "aws_route53_record" "memcached-stage" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "memcached.stage.datacite.org"
    type = "CNAME"
    ttl = var.ttl
    records = [aws_elasticache_cluster.memcached-stage.cache_nodes.0.address]
}
