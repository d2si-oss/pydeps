data "template_file" "variables" {
  template = "${file("${path.cwd}/files/variables.tpl")}"

  vars {
    project_website1_database_mariadb_user="${var.db_username}"
    project_website1_database_mariadb_password="${var.db_password}"
    project_website1_database_mariadb_port="${element(split(":",aws_db_instance.database.endpoint),1)}"
    project_website1_database_mariadb_dns="${element(split(":",aws_db_instance.database.endpoint),0)}"
    project_website1_database_mariadb_database="${var.db_name}"
  }
}

data "template_cloudinit_config" "userdata" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = "${file("${path.cwd}/files/cloud_init.cfg")}"
  }
  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.variables.rendered}"
    filename     = "variables"
  }
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.cwd}/files/userdata.sh")}"
    filename     = "userdata.sh"
  }
}
