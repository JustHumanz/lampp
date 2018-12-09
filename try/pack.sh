#!/usr/bin/env bash
echo "Script for install lampp(nginx,mariadb,phpmyadmin)"
sleep 7 &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done

sudo systemctl stop apache2 mysql
sudo systemctl disable apache2 mysql
sudo apt purge apache2 mysql-server mysql-client && sudo apt autoremove
sudo apt update && sudo apt install nginx mariadb-server mariadb-client phpmyadmin php-fpm curl -y &
sudo mkdir /opt/html &
read -s 'Username for mysql: ' user
read -sp 'Password for mysql: ' pass
echo -e "\ny\ny\n$pass\n$pass\ny\ny\ny\ny" | ./usr/bin/mysql_secure_installation
sudo systemctl enable nginx mariadb &
sudo systemctl start nginx mariadb &
sudo mysql -u root -p $pass -e GRANT USAGE ON *.* TO '$user'@localhost IDENTIFIED BY '$pass';
sudo curl https://raw.githubusercontent.com/JustHumanz/lampp/master/try/1.conf --output /etc/nginx/conf.d/1.conf &
sudo mv /etc/php/7.2/fpm/pool.d/www.conf /etc/php/7.2/fpm/pool.d/www.conf.backup &
sudo curl https://raw.githubusercontent.com/JustHumanz/lampp/master/try/www.conf --output /etc/php/7.2/fpm/pool.d/www.conf &
sudo curl https://raw.githubusercontent.com/JustHumanz/lampp/master/try/index.html --output /opt/html/index.html &
sudo systemctl restart php7.2-fpm.service nginx &
