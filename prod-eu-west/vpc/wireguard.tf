module "wireguard" {
  source                        = "git@github.com:datacite/terraform-wireguard.git"
  ssh_key_id                    = ""
  vpc_id                        = var.vpc_id
  additional_security_group_ids = [aws_security_group.wireguard_ssh_check.id]
  subnet_ids                    = ["${data.aws_subnet.datacite-public.id}", "${data.aws_subnet.datacite-public-alt.id}"]
  target_group_arns             = [aws_lb_target_group.wireguard.arn]
  asg_min_size                  = 1
  asg_desired_capacity          = 2
  asg_max_size                  = 5
  wg_server_net                 = ""
  wg_client_public_keys = []
}

resource "aws_lb" "wireguard" {
  name               = "wireguard"
  load_balancer_type = "network"
  internal           = false
  subnets            = ["${data.aws_subnet.datacite-public.id}", "${data.aws_subnet.datacite-public-alt.id}"]
}

resource "aws_security_group" "wireguard_ssh_check" {
  name   = "wireguard_ssh_check"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_subnet.datacite-public.cidr_block}", "${data.aws_subnet.datacite-public-alt.cidr_block}"]
  }
}

resource "aws_lb_target_group" "wireguard" {
  name_prefix = "wg"
  port        = 51820
  protocol    = "UDP"
  vpc_id      = var.vpc_id

  health_check {
    port     = 22
    protocol = "TCP"
  }

}

resource "aws_lb_listener" "wireguard" {
  load_balancer_arn = aws_lb.wireguard.arn
  port              = 51820
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wireguard.arn
  }
}
