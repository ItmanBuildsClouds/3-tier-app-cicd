#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd php-gd php-xml php-mbstring nfs-utils

systemctl start httpd
systemctl enable httpd

DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"
DB_ENDPOINT="${db_endpoint}"
EFS_ID="${efs_id}"
REGION="${region}"
MOUNT_POINT="/var/www/html/wp-content"

cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz

cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sed -i "s/username_here/$DB_USER/" wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
sed -i "s/localhost/$DB_ENDPOINT/" wp-config.php

mkdir -p $MOUNT_POINT

echo "$EFS_ID.efs.$REGION.amazonaws.com:/ $MOUNT_POINT nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" >> /etc/fstab
mount -a -t nfs4

setsebool -P httpd_can_network_connect_db 1

chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

systemctl restart httpd