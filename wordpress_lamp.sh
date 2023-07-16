#!/bin/bash
sudo yum update -y

sudo yum install -y httpd24 php72 mysql57-server php72-mysqlnd
sudo service httpd start
sudo chkconfig httpd on

sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
#test page
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php