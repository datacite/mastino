# Service Discovery Namepace
resource "aws_service_discovery_private_dns_namespace" "internal" {
  name = "local"
  vpc = "${data.aws_subnet.datacite-private.vpc_id}"
}