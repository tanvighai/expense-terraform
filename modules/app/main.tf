##since we have an autoscaling infra so the nodes or servers will be created automatically,
##hence launch template has to defined for the auto created nodes
#create a security group
resource "aws_security_group" "security_group" {
  name        = "${var.env}-${var.component}-sg"
  description = "${var.env}-${var.component}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  ##adding workstation to the security group so that only this node can establish ssh connection with the servers inside the
  ##private network
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.bastion_node_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.component}-sg"
  }
}
##let's created a lunch template
##we will be using template file for storing the configurations
resource "aws_launch_template" "template" {
  name = "${var.env}-${var.component}"
  #lets connect the created roles to their respective instances
  iam_instance_profile {
   name = aws_iam_role.role.name
 }

  image_id = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data = base64encode(templatefile("${path.module}/userdata.sh" ,{
    role_name = var.component
    env =var.env
}))
  #templatefile("${path.module}/backends.tftpl", { port = 8080, ip_addrs = ["10.0.0.1", "10.0.0.2"] })
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.env}-${var.component}"
    }
  }

}
#in which subnet our nodes will be launched is not being provided in the launch template
##so lets create an autoscaling group

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = var.subnets
  name = "${var.env}-${var.component}"
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  target_group_arns = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}

##earlier we user role to fetch the parameters form parameter store since we will be having and automated system
## server should fetch the credentials on their own from parameter store
#lets create role

resource "aws_iam_role" "role" {
  name               = "${var.env}-${var.component}-role"
  assume_role_policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  }
  )

  inline_policy {
    name = "${var.env}-${var.component}-policy"
    policy = jsonencode(
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
              "ssm:DescribeParameters",
              "ssm:GetParametersByPath",
              "ssm:GetParameters",
              "ssm:GetParameterHistory",
              "ssm:GetParameter"
            ],
            "Resource": "*"
          }
        ]
      }


    )

}

  tags = {
    tag-key = "${var.env}-${var.component}-role"
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.env}-${var.component}-role"
  role = aws_iam_role.role.name
}


##create target group
resource "aws_lb_target_group" "tg" {
  name     = "${var.env}-${var.component}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled = true
    healthy_threshold = 2
    interval = 5
    unhealthy_threshold = 2
    port = var.app_port
    path = "/health"
    timeout = 3
  }
}









