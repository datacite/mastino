
variable "env" {
    type = "string"
    description = "Environment prod|stage|test"
}

variable "container_version" {
    type = "string"
    description = "Version of the container to deploy"
    default = "latest"
}

variable "vpc_id" {}

variable "desired_container_count" {
    type = "string"
}

variable "security_group_id" {
    type = "string"
}

variable "subnet_datacite-private" {
    type = "string"
}

variable "subnet_datacite-alt" {
    type = "string"
}

variable "task_cpu" {
  type        = number
  description = "The number of CPU units used by the task. If using `FARGATE` launch type `task_cpu` must match [supported memory values](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size)"
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "The amount of memory (in MiB) used by the task. If using Fargate launch type `task_memory` must match [supported cpu value](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size)"
  default     = 512
}

variable "lb_priority" {
    type = "number"
    default = 1
}

variable "dns_record_name" {
    type = "string"
    description = "Fully qualified domain name for the record i.e. api.datacite.org"
}

variable "namespace_id" {
    type = "string"
}

variable "base_url" {
  default = "https://oai.stage.datacite.org/oai"
}

variable "api_url" {
  default = "http://client-api.stage.local"
}

variable "api_password" {
    type = "string"
}

variable "sentry_dsn" {
    type = "string"
}

variable "public_key" {
    type = "string"
}
