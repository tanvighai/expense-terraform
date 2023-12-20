env = "dev"
project_name = "expense"
vpc_cidr = "10.0.0.0/16"
public_subnets = ["10.0.0.0/24" , "10.0.1.0/24"]
private_subnets = ["10.0.2.0/24" , "10.0.3.0/24"]
azs = ["us-east-1a" , "us-east-1b"]
account_no = "447398680555"
default_vpc_id = "vpc-0c05c87b359349799"
default_vpc_cidr = "172.31.0.0/16"
default_route_table_id = "rtb-0d13c14bc49e6c243"
bastion_node_cidr = [ "172.31.42.51/32"]
desired_capacity       = 2
max_size               = 10
min_size               = 2
instance_class         = "db.t3.medium"
prometehus_cidr        = ["172.31.39.198/32"]

