resource "aws_elasticache_cluster" "memcached" {
    cluster_id = "memcached"
    engine = "memcached"
    engine_version = "1.4.24"
    node_type = "cache.m4.large"
    port = 11211
    num_cache_nodes = 1
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
    subnet_group_name = "${aws_elasticache_subnet_group.memcached.name}"
    apply_immediately = true
    lifecycle {
      prevent_destroy = "true"
    }
}

resource "aws_elasticache_subnet_group" "memcached" {
    name = "memcached"
    description = "Elasticache memcached subnet group"
    subnet_ids = ["${data.aws_subnet.datacite-private.id}",
                  "${data.aws_subnet.datacite-alt.id}"]
}

resource "aws_route53_record" "memcached1" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "memcached1.datacite.org"
    type = "CNAME"
    ttl = "30"
    records = ["${aws_elasticache_cluster.memcached.cache_nodes.0.address}"]
}

/* resource "librato_space_chart" "memcached-network" {
  name = "Memcached Network Traffic"
  space_id = "${librato_space.cache.id}"
  type = "line"

  stream {
    metric = "AWS.ElastiCache.NetworkBytesIn"
    source = "eu-west-1.memcached.0001"
  }
  stream {
    metric = "AWS.ElastiCache.NetworkBytesOut"
    source = "eu-west-1.memcached.0001"
  }
}

resource "librato_space_chart" "memcached-hits" {
  name = "Memcached Hits and Misses"
  space_id = "${librato_space.cache.id}"
  type = "line"

  stream {
    metric = "AWS.ElastiCache.GetHits"
    source = "eu-west-1.memcached.0001"
  }
  stream {
    metric = "AWS.ElastiCache.GetMisses"
    source = "eu-west-1.memcached.0001"
  }
} */
