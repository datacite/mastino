variable "app_name" {
    type = "string"
    description = "Name of the application e.g. client-api"
}

variable "env" {
    type = "string"
    description = "Environment prod|stage|test"
}

variable "vpc_id" {}

variable "desired_container_count" {
    type = "string"
}

variable "lb_name" {
    type = "string"
    default = "lb-${var.env}"
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

variable "container_port" {
    type = "number"
    default = 80
}

variable "launch_type" {
    type = "string"
    default = "FARGATE"
}

variable "requires_compatibilities" {
    type = "list"
    default = ["FARGATE"]
}

variable "network_mode" {
  type        = string
  description = "The network mode to use for the task. This is required to be `awsvpc` for `FARGATE` `launch_type` or `null` for `EC2` `launch_type`"
  default     = "awsvpc"
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

variable "container_definition_json" {
  type        = string
  description = "A string containing a JSON-encoded array of container definitions"
}

variable "health_check_path" {
  type        = string
  description = "The path to the health check endpoint"
  default     = "/heartbeat"
}

variable "namespace_id" {
    type = "string"
}

variable "lb_priority" {
    type = "number"
    default = 1
}

variable "dns_record_name" {
    type = "string"
    description = "Fully qualified domain name for the record i.e. api.datacite.org"
}

variable "ttl" {
  default = "300"
}
