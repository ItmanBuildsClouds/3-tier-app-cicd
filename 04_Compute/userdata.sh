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
WP_DIR="/var/www/html"

cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

mkdir -p $WP_DIR
mkdir -p $MOUNT_POINT

echo "$EFS_ID.efs.$REGION.amazonaws.com:/ $MOUNT_POINT nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" >> /etc/fstab
mount -a -t nfs4

if [ ! -d "$MOUNT_POINT/index.php" ]; then
    cp -R /tmp/wordpress/wp-content/* $MOUNT_POINT/
    touch $MOUNT_POINT/install_complete.txt
fi

yum install -y rsync
rsync -a --exclude="wp-content" /tmp/wordpress/ $WP_DIR/

cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php
sed -i "s/database_name_here/$DB_NAME/" $WP_DIR/wp-config.php
sed -i "s/username_here/$DB_USER/" $WP_DIR/wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" $WP_DIR/wp-config.php
sed -i "s/localhost/$DB_ENDPOINT/" $WP_DIR/wp-config.php

setsebool -P httpd_can_network_connect_db 1
chown -R apache:apache $WP_DIR
chmod -R 755 $WP_DIR
chmod -R 775 $MOUNT_POINT

rm -rf /tmp/wordpress
rm -f /tmp/latest.tar.gz
systemctl restart httpd