resource "aws_db_parameter_group" "database" {
  name   = "${var.environment}-${var.project}-${var.application}-database"
  family = "${var.config_familly}"

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-${var.project}-${var.application}-database"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
    Application = "${var.application}"
    Component = "database"
  }
}

resource "aws_db_subnet_group" "database" {
  name        = "${var.environment}-${var.project}-${var.application}-database"
  description = "DB subnet for ${var.environment}-${var.project}-${var.application}-database"
  subnet_ids  = ["${aws_subnet.private.*.id}"]

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-${var.project}-${var.application}-database"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
    Application = "${var.application}"
    Component = "database"
  }
}

resource "aws_security_group" "database" {
  name   = "${var.environment}-${var.project}-${var.application}-database"
  vpc_id = "${aws_vpc.project.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.front-instances.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name        = "${var.environment}-${var.project}-${var.application}-database"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
    Application = "${var.application}"
    Component = "front"
  }
}


resource "aws_db_instance" "database" {
  identifier              = "${var.environment}-${var.project}-${var.application}-database"
  multi_az                = "${var.multi_az}"
  allocated_storage       = "${var.allocated_storage}"
  engine                  = "${var.engine_name}"
  engine_version          = "${var.engine_version}"
  instance_class          = "${var.db_instance}"
  name                    = "${var.db_name}"
  skip_final_snapshot     = "${var.skip_final_snapshot}"
  username                = "${var.db_username}"
  password                = "${var.db_password}"
  parameter_group_name    = "${aws_db_parameter_group.database.id}"
  vpc_security_group_ids  = ["${aws_security_group.database.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.database.name}"
  maintenance_window      = "${var.maintenance_window}"
  backup_retention_period = "${var.backup_retention_period}"
  backup_window           = "${var.backup_window}"
  apply_immediately       = "true"
  copy_tags_to_snapshot   = true

  snapshot_identifier     = "${var.snapshot_identifier}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-${var.project}-${var.application}-database"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
    Application = "${var.application}"
    Component = "database"
  }
}
