# Template Task Definitions with a Password 
data "template_file" "neo" {
   template = "${file("task-definitions/neo.json")}"

   vars { 
      neo_password   = "${var.neo_password}"
      neo_url        = "${var.neo_url}"
   }
}

data "template_file" "wsgi" {
   template = "${file("task-definitions/wsgi.json")}"

   vars {
      proxy_url      = "${var.proxy_url}"
      neo_url        = "${var.neo_url}"
      neo_user       = "${var.neo_user}"
      neo_password   = "${var.neo_password}"
   }
}

data "template_file" "bagit" {
   template = "${file("task-definitions/bagit.json")}"

   vars {
      neo_url        = "${var.neo_url}"
      neo_user       = "${var.neo_user}"
      neo_password   = "${var.neo_password}"
   }
}

