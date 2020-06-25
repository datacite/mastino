resource "aws_subnet" "datacite-private-3" {
    vpc_id = var.vpc_id
    cidr_block = "10.0.31.0/24"
    availability_zone = "eu-west-1c"

    tags = {
        Name = "datacite-private-3"
    }
}
