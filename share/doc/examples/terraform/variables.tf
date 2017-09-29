# Tags
variable "environment" {}
variable "owner" {}
variable "eotp" {
  default = ""
}
variable "project" {}
variable "application" {}

variable "region" {}
variable "vpc_cidr" {}
variable "public_subnet_start" {}
variable "private_subnet_start" {}

variable "map_public_ip_on_launch" {
  default = false
}

variable "netbits" {
  default = "8"
}

variable "az" {
  type = "map"

  default = {
    eu-central-1 = "eu-central-1a,eu-central-1b"
    eu-west-1    = "eu-west-1a,eu-west-1b"
  }
}

variable "front_ami_name_regex" {
  default = "amzn-ami-hvm-.*-x86_64-gp2"
}
variable "front_instance" {
  default = "t2.small"
}
