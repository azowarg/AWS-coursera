variable "default_vpc" {
  default = "vpc-0473fc68d8d3a589f"
}
variable "subnets" {
  type = map(any)
  default = {
    "Public Subnet 1" = {
      "zone"        = "us-east-1a"
      "cidr"        = "10.1.1.0/24"
      "external_ip" = true
    }
    "Public Subnet 2" = {
      "zone"        = "us-east-1b"
      "cidr"        = "10.1.2.0/24"
      "external_ip" = true
    }
    "Private Subnet 1" = {
      "zone"        = "us-east-1a"
      "cidr"        = "10.1.3.0/24"
      "external_ip" = false
    }
    "Private Subnet 2" = {
      "zone"        = "us-east-1b"
      "cidr"        = "10.1.4.0/24"
      "external_ip" = false
    }
  }
}