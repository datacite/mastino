resource "aws_elasticache_cluster" "memcached-us" {
    cluster_id = "memcached-us"
    engine = "memcached"
    engine_version = "1.4.24"
    node_type = "cache.m4.large"
    port = 11211
    num_cache_nodes = 1
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
    subnet_group_name = "${aws_elasticache_subnet_group.memcached-us.name}"
    apply_immediately = true
    lifecycle {
      prevent_destroy = "true"
    }
}

resource "aws_elasticache_subnet_group" "memcached-us" {
    name = "memcached-us"
    description = "Elasticache memcached subnet group"
    subnet_ids = ["${data.aws_subnet.datacite-private.id}",
                  "${data.aws_subnet.datacite-alt.id}"]
}

resource "aws_route53_record" "memcached2" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "memcached2.datacite.org"
    type = "CNAME"
    ttl = "30"
    records = ["${aws_elasticache_cluster.memcached-us.cache_nodes.0.address}"]
}