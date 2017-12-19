provider "aws" {
  region              = "${var.region}"
}

resource "aws_vpc" "project" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name        = "${var.environment}-${var.project}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.project.id}"
  count                   = "${length(split(",",lookup(var.az,var.region)))}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, var.netbits, count.index + var.public_subnet_start)}"
  availability_zone       = "${element(split(",",lookup(var.az,var.region)), count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
    Name        = "${var.environment}-${var.project}-public-${count.index}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.project.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags {
    Name        = "${var.environment}-${var.project}-public"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",",lookup(var.az,var.region)))}"
  subnet_id      = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.project.id}"

  tags {
    Name        = "${var.environment}-${var.project}-${var.application}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "private" {
  vpc = true
}

resource "aws_nat_gateway" "private" {
  allocation_id = "${aws_eip.private.id}"
  subnet_id     = "${aws_subnet.public.0.id}"
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.project.id}"
  count                   = "${length(split(",",lookup(var.az,var.region)))}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, var.netbits, count.index + var.private_subnet_start)}"
  availability_zone       = "${element(split(",",lookup(var.az,var.region)), count.index)}"

  tags {
    Name        = "${var.environment}-${var.project}-private-${count.index}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.project.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id         = "${aws_nat_gateway.private.id}"
  }

  tags {
    Name        = "${var.environment}-${var.project}-private"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(split(",",lookup(var.az,var.region)))}"
  subnet_id      = "${element(aws_subnet.private.*.id,count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
