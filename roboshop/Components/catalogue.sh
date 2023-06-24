#!/bin/bash

COMPONENT=catalogue
LOGFILE="/tmp/${COMPONENT}.log"
ID=$(id -u)
APPUSER="roboshop"


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

curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash - &>> $LOGFILE
status $?

echo "Install ${COMPONENT}"
yum install nodejs -y &>> $LOGFILE
status $?

id ${APPUSER} &>> $LOGFILE

if [ $? -ne 0 ]; then
echo "Create a service account"
useradd roboshop
fi
status $?

echo "Donwloading the component"
curl -s -L -o /tmp/catalogue.zip "https://github.com/stans-robot-project/catalogue/archive/main.zip"
status $?

echo "Copy the ${COMPONENT} to ${APPUSER} home directory"
cd /home/${APPUSER}/
unzip /tmp/${COMPONENT}.zip &>> $LOGFILE
mv ${COMPONENT}-main ${COMPONENT} &>> $LOGFILE
chown -R ${APPUSER}:${APPUSER} /home/roboshop/${COMPONENT} &>> $LOGFILE
status $?



