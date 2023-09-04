terraform {
  required_providers {

    aws = {
    source="hashicorp/aws"

    }

  }
}


provider aws {}




module "vpc" {
  source = "./module/network-module"
  
}

module "alb" {
  source = "./module/alb-module"

  vpc-id =module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}


module "db" {

  source = "./module/db-module"
  vpc-id =module.vpc.vpc_id
  websg = module.vpc.privatesg
  private_subnets = module.vpc.private_subnets
}

module "s3" {

  source = "./module/s3-module"
  
}












