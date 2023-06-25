#!/bin/bash

COMPONENT=redis
LOGFILE="/tmp/${COMPONENT}.log"
ID=$(id -u)
# APPUSER="roboshop"


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

echo "Configur the ${COMPONENT} repo"

curl -L https://raw.githubusercontent.com/stans-robot-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>> $LOGFILE
status $?

echo "Install ${COMPONENT}"
yum install ${COMPONENT}-6.2.11 -y -y &>> $LOGFILE
status $?

echo "Update the ${COMPONENT} BindIP"

sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/${COMPONENT}.conf &>> $LOGFILE
sed -i -e 's/127.0.0.1/0.0.0.0/' //etc/redis/${COMPONENT}.conf &>> $LOGFILE
status $?

echo "Updated Systemctl"
systemctl enable redis &>> $LOGFILE
systemctl restart redis &>> $LOGFILE
systemctl status redis -l &>> $LOGFILE
status $?

echo "Installation successfully completed on ${COMPONENT} component"