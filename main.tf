
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  env = var.env
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets
  azs = var.azs

}





#resource "null_resource" "test" {
#  provisioner "local-exec" {
#    command = "echo hello world - ${var.env} Environment"
#  }
#}




#variable "env" {}
#terraform {
#  backend "s3" {}
#}
