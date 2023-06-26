#!/bin/bash

COMPONENT=mysql

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
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo
status $?

echo "Install ${COMPONENT} component"
yum install mysql-community-server -y
status $?

echo "Starting ${COMPONENT} component"
systemctl enable mysqld
systemctl restart mysqld
status $?

echo "Fetch the default root password"
DEFAULT_ROOT_PASSWORD= $(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
echo "Default Password is = ${DEFAULT_ROOT_PASSWORD}"
status $?
