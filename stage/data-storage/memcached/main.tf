resource "aws_elasticache_cluster" "memcached-stage" {
    cluster_id = "memcached-stage"
    engine = "memcached"
    engine_version = "1.4.34"
    node_type = "cache.m3.medium"
    port = 11211
    num_cache_nodes = 1
    security_group_ids = ["${data.aws_security_group.datacite-private.id}"]
    subnet_group_name = "${aws_elasticache_subnet_group.memcached-stage.name}"
    apply_immediately = true
    lifecycle {
      prevent_destroy = "true"
    }
}

resource "aws_elasticache_subnet_group" "memcached-stage" {
    name = "memcached-stage"
    description = "Elasticache memcached-stage subnet group"
    subnet_ids = ["${data.aws_subnet.datacite-private.id}",
                  "${data.aws_subnet.datacite-alt.id}"]
}

resource "aws_route53_record" "memcached-test" {
    zone_id = "${data.aws_route53_zone.internal.zone_id}"
    name = "memcached.test.datacite.org"
    type = "CNAME"
    ttl = "${var.ttl}"
    records = ["${aws_elasticache_cluster.memcached-stage.cache_nodes.0.address}"]
}
