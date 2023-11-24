variable "environment" {
  description = "The environment for the queues"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "The tags for the queues"
  type        = map(string)
  default     = {}
}