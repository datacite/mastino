variable "viringo_tags" {
  type = "map"
}

variable "vpc_id" {
    type = "string"
}

variable "namespace_id" {
    type = "string"
}

variable "security_group_id" {
    type = "string"
}

variable "subnet_datacite-private_id" {
    type = "string"
}

variable "subnet_datacite-alt_id" {
    type = "string"
}


# App specific variables

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
