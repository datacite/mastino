
module "oai_ecs_service" {
    source  = "../../service"

    app_name = "oai"
    env = var.env
    vpc_id = var.vpc_id
    desired_container_count = var.desired_container_count
    security_group_id = var.security_group_id
    subnet_datacite-private_id = var.subnet_datacite-private
    subnet_datacite-alt = var.subnet_datacite-alt
    task_cpu = var.task_cpu
    task_memory = var.task_memory
    container_definition_json = data.template_file.oai_task.rendered
    namespace_id = var.namespace_id
    dns_record_name = var.dns_record_name
    lb_priority = var.lb_priority
}

data "template_file" "oai_task" {
  template = "${file("oai.json")}"

  vars {
    app_name           = "oai"
    container_version  = var.container_version
    log_group          = oai_ecs_service.log_group_name
    api_url            = var.api_url
    api_password       = var.api_password
    base_url           = var.base_url
    public_key         = var.public_key
    sentry_dsn         = var.sentry_dsn
    log_level          = var.log_level
  }
}
