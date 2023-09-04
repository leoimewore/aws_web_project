variable "allocated_storage" {
    default = 20
  
}
variable "engine" {
    default = "mysql"
  
}

variable "engine_version" {
    default = "5.7.37"
  
}

variable "instance_class" {
    default = "db.t2.micro"
  
}
variable "username" {
    default = ""
  
}

variable "password" {
    default = ""
  
}

variable "vpc-id" {
   description = "Virtual private cloud identity number"
  
}

variable "websg" {
    description = "security group for the ec2 instances"
  
}

variable "private_subnets" {
    description = "private subnets for the database"
  
}

