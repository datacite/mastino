
variable "app_name" {
  description = "Name of the application (e.g., client-api)"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., stage, test, prod)"
  type        = string
}

variable "task_desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "CPU units for Fargate"
  type        = string
}

variable "task_memory" {
  description = "Memory in MiB for Fargate"
  type        = string
}

variable "container_definition_json" {
  type        = string
  description = "A string containing a JSON-encoded array of container definitions"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "vpc_id" {
  description = "VPC ID where resources are deployed"
  type        = string
}

variable "security_group_id" {
    type = string
}

variable "subnet_datacite-private_id" {
    type = string
}

variable "subnet_datacite-alt_id" {
    type = string
}

variable "namespace_id" {
  description = "ID of the Service Discovery Namespace"
  type        = string
}

variable "load_balancer_config" {
  description = "Optional load balancer configuration. If empty, no load balancer is attached."
  type        = list(object({
    target_group_arn = string
    container_port   = number
  }))
  default     = []
}

