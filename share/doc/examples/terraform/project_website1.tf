### Web Load Balancer
resource "aws_elb" "front-elb" {
  name = "${var.environment}-${var.project}-${var.application}-front"

  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.front-elb.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  tags {
    Name        = "${var.environment}-${var.project}-${var.application}-front"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
    Application = "${var.application}"
    Component = "front"
  }
}

resource "aws_security_group" "front-elb" {
  name   = "${var.environment}-${var.project}-${var.application}-front-elb"
  vpc_id = "${aws_vpc.project.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment}-${var.project}-${var.application}-front-elb"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
    Application = "${var.application}"
    Component = "front"
  }
}

# Web instances
data "aws_ami" "front-instances" {
  most_recent = true
  name_regex = "${var.front_ami_name_regex}"
}

resource "aws_launch_configuration" "front-instances" {
  name_prefix     = "${var.environment}-${var.project}-${var.application}-front-"
  image_id        = "${data.aws_ami.front-instances.id}"
  instance_type   = "${var.front_instance}"
  security_groups = ["${aws_security_group.front-instances.id}"]
#  user_data       = "${file("../01_configuration_management/web_configure_userdata.sh")}"
}

resource "aws_autoscaling_group" "front-instances" {
  name_prefix          = "${var.environment}-${var.project}-${var.application}-front-"
  vpc_zone_identifier  = ["${aws_subnet.private.*.id}"]

  launch_configuration      = "${aws_launch_configuration.front-instances.name}"
  load_balancers = ["${aws_elb.front-elb.name}"]

  max_size         = "2"
  min_size         = "1"
  desired_capacity = "2"

  health_check_grace_period = "300"
  health_check_type         = "EC2"

  lifecycle {
    create_before_destroy = true
  }
  tags = [
    {
      key                 = "Name"
      value               = "${var.environment}-${var.project}-${var.application}-front"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "${var.owner}"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "${var.project}"
      propagate_at_launch = true
    },
    {
      key                 = "EOTP"
      value               = "${var.eotp}"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "Application"
      value               = "${var.application}"
      propagate_at_launch = true
    },
    {
      key                 = "Component"
      value               = "front"
      propagate_at_launch = true
    }
  ]
}

resource "aws_security_group" "front-instances" {
  name   = "${var.environment}-${var.project}-${var.application}-front-instances"
  vpc_id = "${aws_vpc.project.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.front-elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name        = "${var.environment}-${var.project}-${var.application}-front-instances"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    EOTP        = "${var.eotp}"
    Environment = "${var.environment}"
    Application = "${var.application}"
    Component = "front"
  }
}

### Database
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

### Outputs
output "front_endpoint" {
  value = "${aws_elb.front-elb.dns_name}"
}
