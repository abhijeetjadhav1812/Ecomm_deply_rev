#!/bin/bash

dep_path=/home/ec2-user/Ecomm_deploy/

cd $dep_path

function print_color ()
{

case $1 in 

   "green") COLOR="\033[0;32m" ;;
   "red") COLOR="\033[0;31m" ;;
   "cyan") COLOR="\033[0;36m" ;;
   "*") COLOR="\033[0m" ;;
 
esac  
 
echo -e "${COLOR} $2 \e[0m"
}



function install_p()
{

  print_color "green" "\nInstaling the $1 now\n"
  sudo yum install $1 -y > yum_install_logs.txt

}

function start_serv ()
{
  print_color "green" "\nStarting the $serv_name now\n"
  sudo systemctl start $1
  print_color "cyan" "Checking the status of service"
  serv_status=$(sudo systemctl is-active $1)
   if [[ $serv_status = "active" ]]
   then
		print_color "green" "$1 is in active state"
   else
		print_color "red" "$1 is not in active state use journalctl command for further debug"
		
   fi
}

function enable_serv ()
{
 
   print_color "green" "\nEnabling the $serv_name now\n"
  sudo systemctl enable $1
 
}


function firewall_enable ()

{

sudo firewall-cmd --permanent --zone=public --add-port=$1
sudo firewall-cmd --reload

}

for p_name in $(cat packages.txt)
 do

   install_p $p_name

 done

for serv_name in $(cat services.txt)
 do

   start_serv $serv_name
 done

for serv_name in $(cat services.txt)
 do

   enable_serv $serv_name
 done


 print_color "cyan" "\nGoing to enable port for listed and installed services\n"

for port_id in $(cat ports.txt)
do

firewall_enable $port_id
 print_color "green" "\nPlease verify if $port_id is listed in --list-all option in output below\n"
sudo firewall-cmd --list-all | grep --color $port_id

done

sudo mysql < create_db.sql
print_color "green" "CAll for db creation done"
sudo mysql < db_load.sql 
print_color "green" "CALL for db load is done"

print_color "cyan" "Changing the default html page"
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf


print_color "cyan" "Cloning the git repo"
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/


print_color "cyan" "Changing the database to localhost as this is LAMP stack"
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php


curl http://localhost > curl.txt 

print_color "green" "We are all Set now!! check the website at localhost:80 or your IP:80"
