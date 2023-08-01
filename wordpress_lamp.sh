#!/bin/bash
sudo yum -y update
sudo yum install -y httpd
sudo service httpd start
sudo chkconfig httpd on

sudo yum install -y php
sudo yum install -y mariadb105-server
sudo yum install -y php-mysqlnd

sudo systemctl enable mariadb
sudo systemctl start mariadb

#change permissions on necessary directories
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
#test page
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

#configure TLS/SSL
sudo yum install -y mod_ssl
sudo service httpd restart

#configure database
#TODO: replace password with pam
sudo mysql -u root -Bse "
CREATE DATABASE wordpress;
CREATE USER wordpress_svc_db IDENTIFIED BY '*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19';
GRANT ALL PRIVILEGES ON wordpress.* to wordpress_svc_db WITH GRANT OPTION;
"

#install wordpress
cd ~
wget https://wordpress.org/latest.tar.gz && tar -xzvf latest.tar.gz
rm latest.tar.gz
cp ~/wordpress/wp-config-sample.php ~/wordpress/wp-config.php

#set wp-config.php settings.
#TODO: harden wordpress db creds
touch ~/wordpress/wp-config.php
echo "<?php" >> ~/wordpress/wp-config.php
echo "define( 'DB_NAME', 'wordpress' );" >> ~/wordpress/wp-config.php
echo "define( 'DB_USER', 'wordpress_svc_db' );" >> ~/wordpress/wp-config.php
echo "define( 'DB_PASSWORD', 'password' );" >> ~/wordpress/wp-config.php
echo "define( 'DB_HOST', 'localhost' );" >> ~/wordpress/wp-config.php
echo "define( 'DB_CHARSET', 'utf8' );" >> ~/wordpress/wp-config.php
echo "define( 'DB_COLLATE', '' );" >> ~/wordpress/wp-config.php
curl https://api.wordpress.org/secret-key/1.1/salt/ >> ~/wordpress/wp-config.php
echo "\$table_prefix = 'wp_';" >> ~/wordpress/wp-config.php
echo "define( 'AP_DEBUG', false );" >> ~/wordpress/wp-config.php
echo "if( ! defined( 'ABSPATH') ) { define( 'ABSPATH', __DIR__ . '/' );}" >> ~/wordpress/wp-config.php
echo "require_once ABSPATH . 'wp-settings.php';" >> ~/wordpress/wp-config.php
