module "oai_ecs_service" {
    source  = "../../../../modules/services/oai"

    app_name = "oai"
    env = "stage"
    vpc_id = var.vpc_id
    desired_container_count = 1
    security_group_id = var.security_group_id
    subnet_datacite-private_id = var.subnet_datacite-private
    subnet_datacite-alt = var.subnet_datacite-alt
    task_cpu = 512
    task_memory = 1024
    namespace_id = var.namespace_id
    dns_record_name = "oai.stage.datacite.org"
    lb_priority = 61
    container_version = "latest"
    api_url = var.api_url
    api_password = var.api_password
    base_url = var.base_url
    public_key = var.public_key
    sentry_dsn = var.sentry_dsn
    log_level = "info"
}
