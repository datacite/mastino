resource "aws_db_parameter_group" "datacite57" {
    name = "datacite57"
    family = "mysql5.7"
    description = "RDS datacite parameter group"

    parameter {
      name = "character_set_server"
      value = "utf8"
    }

    parameter {
      name = "collation_server"
      value = "utf8_unicode_ci"
    }

    parameter {
      name = "character_set_client"
      value = "utf8"
    }

    parameter {
      name = "max_allowed_packet"
      value = 50000000
    }

    parameter {
      name = "read_only"
      value = "0"
    }

    parameter {
      name = "slow_query_log"
      value = "1"
    }

    parameter {
      name = "log_queries_not_using_indexes"
      value = "1"
    }

    parameter {
      name = "log_throttle_queries_not_using_indexes"
      value = "0"
    }
}

resource "aws_db_subnet_group" "datacite" {
    name = "datacite"
    description = "RDS production subnet group"
    subnet_ids = [
      "${data.aws_subnet.datacite-public.id}",
      "${data.aws_subnet.datacite-public-alt.id}",
      "${data.aws_subnet.datacite-private.id}",
      "${data.aws_subnet.datacite-alt.id}"
    ]
}

resource "aws_route53_record" "internal-db2" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "db.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "aws_route53_record" "internal-db2-ec2" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "db.ec2.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "aws_route53_record" "internal-db7" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "dbread.ec2.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "aws_route53_record" "split-db1" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "db1.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "aws_route53_record" "internal-db1-ec2" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "db1.ec2.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "aws_route53_record" "rds-production" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "production.rds.datacite.org"
  type = "CNAME"
  ttl = "${var.ttl}"
  records = ["${data.aws_db_instance.db.address}"]
}

resource "librato_space" "rds" {
    name = "RDS"
}

resource "librato_space_chart" "db-cpu" {
  name = "DB CPU"
  space_id = "${librato_space.rds.id}"
  type = "line"

  stream {
    metric = "AWS.RDS.CPUUtilization"
    source = "eu-west-1.db2"
  }
  stream {
    metric = "AWS.RDS.CPUUtilization"
    source = "eu-west-1.db-test"
  }
}

resource "librato_space_chart" "db-read-iops" {
  name = "DB Read IOPS"
  space_id = "${librato_space.rds.id}"
  type = "line"

  stream {
    metric = "AWS.RDS.ReadIOPS"
    source = "eu-west-1.db2"
  }
  stream {
    metric = "AWS.RDS.ReadIOPS"
    source = "eu-west-1.db-test"
  }
}

resource "librato_space_chart" "db-write-iops" {
  name = "DB Write IOPS"
  space_id = "${librato_space.rds.id}"
  type = "line"

  stream {
    metric = "AWS.RDS.WriteIOPS"
    source = "eu-west-1.db2"
  }
  stream {
    metric = "AWS.RDS.WriteIOPS"
    source = "eu-west-1.db-test"
  }
}

resource "librato_space_chart" "db-connections" {
  name = "DB Connections"
  space_id = "${librato_space.rds.id}"
  type = "line"

  stream {
    metric = "AWS.RDS.DatabaseConnections"
    source = "eu-west-1.db2"
  }
  stream {
    metric = "AWS.RDS.DatabaseConnections"
    source = "eu-west-1.db-test"
  }
}

resource "librato_space_chart" "db-storage" {
  name = "DB Free Storage"
  space_id = "${librato_space.rds.id}"
  type = "line"

  stream {
    metric = "AWS.RDS.FreeStorageSpace"
    source = "eu-west-1.db2"
  }
  stream {
    metric = "AWS.RDS.FreeStorageSpace"
    source = "eu-west-1.db-test"
  }
}

resource "librato_space_chart" "db-write-latency" {
  name = "DB Write Latency"
  space_id = "${librato_space.rds.id}"
  type = "line"

  stream {
    metric = "AWS.RDS.WriteLatency"
    source = "eu-west-1.db2"
  }
  stream {
    metric = "AWS.RDS.WriteLatency"
    source = "eu-west-1.db-test"
  }
}

resource "librato_space_chart" "db-swap" {
  name = "DB Swap Usage"
  space_id = "${librato_space.rds.id}"
  type = "line"

  stream {
    metric = "AWS.RDS.SwapUsage"
    source = "eu-west-1.db2"
  }
  stream {
    metric = "AWS.RDS.SwapUsage"
    source = "eu-west-1.db-test"
  }
}

// resource "librato_alert" "db2-connections" {
//   name = "db2.connections"
//   description = "Too many db2 database connections"
//   rearm_seconds = "3600"
//   services = ["${librato_service.slack.id}"]
//   condition {
//     type = "above"
//     threshold = 800
//     duration = 300
//     metric_name = "AWS.RDS.DatabaseConnections"
//     source = "eu-west-1.db2"
//     summary_function = "average"
//   }
// }
