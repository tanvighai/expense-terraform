
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  env = var.env
  project_name = "expense"

#  private_subnets        = var.private_subnets
#  public_subnets         = var.public_subnets
#  azs                    = var.azs
#  account_no             = var.account_no
#  default_vpc_id         = var.default_vpc_id
#  default_vpc_cidr       = var.default_vpc_cidr
#  default_route_table_id = var.default_route_table_id
}










