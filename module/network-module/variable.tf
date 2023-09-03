variable "vpc-CIDR" {
    default = "192.168.0.0/16"
  
}


#map of maps for create subnets
variable "prefix" {
   type = map
   default = {
      sub-1 = {
         az = "use1-az1"
         cidr = "192.168.0.0/24"
      }
      sub-2 = {
         az = "use1-az2"
         cidr = "192.168.2.0/24"
      }
      
   }
}


variable "suffix" {
   type = map
   default = {
      sub-1 = {
         az = "use1-az3"
         cidr = "192.168.1.0/24"
      }
      sub-2 = {
         az = "use1-az4"
         cidr = "192.168.122.0/24"
      }
      
   }
}

variable "ami" {
   default = "ami-051f7e7f6c2f40dc1"
  
}

