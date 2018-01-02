data "aws_instance" "compose-test" {
  instance_id = "i-6807898c"
}

resource "aws_route53_record" "internal-compose-test" {
   zone_id = "${data.aws_route53_zone.internal.zone_id}"
   name = "compose.test.datacite.org"
   type = "A"
   ttl = "${var.ttl}"
   records = ["10.0.0.4"]
}
