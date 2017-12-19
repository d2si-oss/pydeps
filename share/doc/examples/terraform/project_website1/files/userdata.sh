#!/bin/bash

echo $0
# update packages

yum -y update
yum -y upgrade

# install and configure web service
yum install -y httpd24 php56 php56-mysqlnd
service httpd start
chkconfig httpd on
groupadd www
usermod -a -G www ec2-user

# create website
chmod 2775 /var/www

echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

source "$(dirname $0)/variables"
cat >/var/www/html/db_connect.php <<EOF
<?php
\$servername = "$project_website1_database_mariadb_dns";
\$port = "$project_website1_database_mariadb_port";
\$username = "$project_website1_database_mariadb_user";
\$password = "$project_website1_database_mariadb_password";
\$dbname = "$project_website1_database_mariadb_database";

// Create connection
\$conn = new mysqli(\$servername, \$username, \$password, \$dbname, \$port);

// Check connection
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}
echo "Connected successfully to ". \$servername;
?>
EOF

find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chmod 0664 {} +
