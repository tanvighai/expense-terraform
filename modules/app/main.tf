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
#  iam_instance_profile {
#    name = "test"
#  }

  image_id = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data = base64encode(templatefile("${path.module}/userdata.sh" ,{
    role_name = var.component
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
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}