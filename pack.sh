#!/usr/bin/env bash
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi
echo "Script for install Lampp(Nginx,Mariadb,Phpmyadmin,Php7.2)"
read -p 'Username for mysql: ' user
read -sp 'Password for mysql: ' pass
echo
sleep 3 &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done

echo 'Check Service'
lo=$(systemctl is-active nginx)
if [[ $lo == "active" ]]; then
  echo 'disable nginx'
  service nginx stop && service nginx disable || systemctl start nginx && systemctl enable nginx
fi

lo1=$(systemctl is-active apache2)
if [[ $lo1 == "active" ]]; then
  echo 'disable apache2'
  service apache2 stop && service apache2 disable || systemctl start apache2 && systemctl enable apache2
fi

lo2=$(systemctl is-active mysql)
if [[ $lo2 == "active" ]]; then
  echo 'disable mysql'
  service mysql stop && service mysql disable
fi

lo3=$(systemctl is-active mariadb)
if [[ $lo3 == "active" ]]; then
  echo 'disable mariadb'
  service mariadb stop && service mariadb disable 
fi

#systemctl stop apache2 mysql nginx mariadb
#systemctl disable apache2 mysql nginx mariadb
apt purge apache2 mysql-server mysql-client nginx mariadb-server mariadb-client -y && apt autoremove -y
apt update && sudo apt install nginx mariadb-server mariadb-client php-fpm curl php-mysql -y
mkdir /opt/html
echo "Starting and enable mariadb and nginx"
service nginx start && service nginx enable
service mariadb start && service mariadb enable  || service mysql start && service mysql enable
echo -e "\ny\ny\n$pass\n$pass\ny\ny\ny\ny" | /usr/bin/mysql_secure_installation
mysql -u root -p$pass -e "GRANT USAGE ON *.* TO '$user'@localhost IDENTIFIED BY '$pass';"
curl https://raw.githubusercontent.com/JustHumanz/lampp/master/try/1.conf  --silent --output /etc/nginx/conf.d/1.conf
mv /etc/php/7.2/fpm/pool.d/www.conf /etc/php/7.2/fpm/pool.d/www.conf.backup
curl https://raw.githubusercontent.com/JustHumanz/lampp/master/try/www.conf  --silent --output /etc/php/7.2/fpm/pool.d/www.conf
curl https://raw.githubusercontent.com/JustHumanz/lampp/master/try/index.html  --silent --output   /opt/html/index.html
rm /etc/nginx/sites-enabled/default && rm /etc/nginx/sites-available/default
echo "<?php phpinfo();" > /opt/html/info.php

apt install phpmyadmin -y
ln -s /usr/share/phpmyadmin /opt/html
echo 'Restarting php-fpm and nginx'
systemctl restart php7.2-fpm.service nginx || service php7.2-fpm restart && service nginx restart
echo 'Try access http://localhost/phpmyadmin and http://localhost/info.php'
