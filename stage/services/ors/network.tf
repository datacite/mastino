// # References
//    # Security Groups
//       # https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html#AddRemoveRules

// # Build a VPC
//    # .id
//    # .default_security_group_id
//    # .default_network_acl_id
//    # .default_route_table_id

// resource "aws_vpc" "mainVPC" {
//    cidr_block = "10.0.0.0/16"
//    enable_dns_support = true
//    enable_dns_hostnames = true
//    tags {
//       Name = "Main"
//    }
// }

// # Alter Route Table of Default Subnet
// # Grab default Subnet
//    # Need to set ipv4 auto settings and default route table with 0.0.0.0/0 to internet gateway
//    # .id
// resource "aws_subnet" "pubSubnet" {
//    vpc_id = "${aws_vpc.mainVPC.id}"
//    cidr_block = "10.0.1.0/24"
//    tags {
//       Name = "Main"
//    }
// }

// # alter security group for containers
// # security group for wsgi container, bagit services
// resource "aws_security_group" "allow_all" {
//    name = "allow_all"
//    description = "Allow all inbound traffic"
//    vpc_id = "${aws_vpc.mainVPC.id}"
//    ingress {
//       from_port = 0
//       to_port = 0
//       protocol = "-1"
//       cidr_blocks = ["0.0.0.0/0"]
//    }
//    egress {
//       from_port = 0
//       to_port  = 0
//       protocol = "-1"
//       cidr_blocks = ["0.0.0.0/0"]
//    }
// }

// # only let inbound traficc to bolt port from this subnet
// resource "aws_security_group" "allow_subnet" {
//    name = "allow_subnet"
//    description = "Allows service to talk to subnet"
//    vpc_id = "${aws_vpc.mainVPC.id}"
//    ingress {
//       from_port = 0
//       to_port = 0 
//       protocol = "-1"
//       cidr_blocks = ["${aws_subnet.pubSubnet.cidr_block}"]
//    }
//    egress {
//       from_port = 0     
//       to_port = 0
//       protocol = "-1"
//       cidr_blocks = ["${aws_subnet.pubSubnet.cidr_block}"]
//    }
// }

// # Create a new Internet Gateway
// resource "aws_internet_gateway" "main" {
//    vpc_id = "${aws_vpc.mainVPC.id}"

//    tags {
//       Name = "main"
//    }
// }


// # Create a New Route Table for a public subnet
// # missing local rules
// resource "aws_route_table" "publicRoute" {
//    vpc_id = "${aws_vpc.mainVPC.id}"
//    route {
//      cidr_block = "0.0.0.0/0"
//      gateway_id = "${aws_internet_gateway.main.id}"
//    }
// }

// # Associate it as the route table of the public subnet
// resource "aws_route_table_association" "publicRoute" {
//    subnet_id            = "${aws_subnet.pubSubnet.id}"
//    route_table_id       = "${aws_route_table.publicRoute.id}"
// }


// # Set up private DNS for service discovery on default Subnet
// resource "aws_service_discovery_private_dns_namespace" "neo_namespace" {
//    name = "ors.local"
//    description = "DNS for connecting containers to backend neo service in fargate"
//    vpc = "${aws_vpc.mainVPC.id}"
// }

// # Set up Service Discovery Service for the namespace
//    # Can add health check later
// resource "aws_service_discovery_service" "neo" {
//    name = "neo"

//    health_check_custom_config {
//        failure_threshold = 1
//      }

//    dns_config {
//       namespace_id = "${aws_service_discovery_private_dns_namespace.neo_namespace.id}"
//       dns_records {
//             ttl = 6000
//             type = "A"
//          } 
//    }
// }

