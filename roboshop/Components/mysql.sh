#!/bin/bash

COMPONENT=mysql
LOGFILE="/tmp/${COMPONENT}.log"

if [ $ID -ne 0 ]; then
echo "This action perform only root user"
exit 1
fi

status(){

    if [ $1 -eq 0 ]; then
        echo "Success"
    else
        echo "Failure"
    fi
}

echo "Confifure ${COMPONENT} component"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo &>> $LOGFILE
status $?

echo "Install ${COMPONENT} component"
yum install mysql-community-server -y &>> $LOGFILE
status $?

echo "Starting ${COMPONENT} component"
systemctl enable mysqld
systemctl start mysqld
status $?
echo "Fetch the default root password"
DEFAULT_ROOT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk  '{print $NF}') &>> $LOGFILE
# echo "Default Password is = ${DEFAULT_ROOT_PASSWORD}"
status $?


echo "show databases;" | mysql -uroot -pRoboShop@1 &>> $LOGFILE
if [ $? -ne 0 ]; then
echo "Change the default root user pasword  if the default password is not change"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1'; " | mysql --connect-expired-password -uroot -p${DEFAULT_ROOT_PASSWORD} &>> $LOGFILE
status $?
fi


echo "show plugins;" | mysql -uroot -pRoboShop@1 | grep validate_password &>> $LOGFILE
if [ $? -eq 0 ]; then
echo "UNINSTALL PLUGIN validate_password;" | mysql -uroot -pRoboShop@1 &>> $LOGFILE
status $?
fi


echo "Downloading the ${COMPONENT} schema"
curl -s -L -o /tmp/mysql.zip "https://github.com/stans-robot-project/mysql/archive/main.zip" &>> $LOGFILE
status $?

echo "Extract the schema"
cd /tmp
unzip -o /tmp/${COMPONENT}.zip &>> $LOGFILE
status $?

echo "Inject the schema"
cd ${COMPONENT}-main
mysql -u root -pRoboShop@1 <shipping.sql &>> $LOGFILE
status $?




