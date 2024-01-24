provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


data "template_file" "queue-stage" {
  template = file("sqs.json")

  vars = {
    region = var.region
  }

}
