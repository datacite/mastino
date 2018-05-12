output "ecs_solr_id" {
  value = "${element(aws_instance.ecs-solr.*.id, var.search_tags["id"])}"
}