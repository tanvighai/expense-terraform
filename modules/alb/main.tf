##Creating Security group

resource "aws_security_group" "security_group" {
  name        = "${var.env}-${var.alb_type}-sg"
  description = "${var.env}-${var.alb_type}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.alb_sg_allow_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.alb_type}-sg"
  }
}

##Creating a public load balancer
resource "aws_lb" "alb" {
  name               = "${var.env}-${var.alb_type}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group.id]
  subnets            = var.subnets
  tags = {
    Environment = "${var.env}-${var.alb_type}"
  }
}

##Creating a private load balancer
#resource "aws_lb" "abl" {
#  name               = "${var.env}-${var.alb_type}"
#  internal           = var.internal
#  load_balancer_type = "application"
#  security_groups    = [aws_security_group.security_group.id]
#  subnets            = var.subnets
#  tags = {
#    Environment = "${var.env}-${var.alb_type}"
#  }
#}

##creating a DNS record with automation
##the idea here is to first convert and ip to web address and then that address will point to or readdress to another web address
##where private load balancer will act as backend server
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.dns_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.alb.dns_name]
}