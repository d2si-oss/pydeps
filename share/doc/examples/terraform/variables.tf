# Tags
variable "environment" {}
variable "owner" {}
variable "project" {}
variable "application" {}

variable "eotp" {
  default = ""
}

# Network
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

# web service
variable "front_ami_name_regex" {
  default = "amzn-ami-hvm-.*-x86_64-gp2"
}
variable "front_instance" {
  default = "t2.small"
}

# Database
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}

variable "config_familly" {
  default = "mariadb10.0"
}
variable "multi_az" {
  default = "false"
}
variable "allocated_storage" {
  default = 10
}
variable "engine_name" {
  default = "mariadb"
}
variable "engine_version" {
  default = "10.0.24"
}
variable "db_instance" {
  default = "db.t2.micro"
}
variable "maintenance_window" {
  default = "Mon:00:00-Mon:02:00"
}
variable "backup_retention_period" {
  default = "10"
}
variable "backup_window" {
  default = "03:00-03:30"
}
variable "skip_final_snapshot" {
  default = true
}
variable "snapshot_identifier" {
  default = ""
}
