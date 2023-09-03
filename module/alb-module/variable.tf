variable "ami" {
   default = "ami-051f7e7f6c2f40dc1"
  
}

variable "vpc-id" {
   description = "Virtual private cloud identity number"
  
}

variable "public_subnets" {
   description = "SubnetIds to be attached to load balancer"
  
}
