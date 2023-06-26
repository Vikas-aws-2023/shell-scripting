#!/bin/bash

COMPONENT=payment
LOGFILE="/tmp/${COMPONENT}.log"
APPUSER="roboshop"
ID=$(id -u)

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

echo "Install Phyton for ${COMPONENT} component"
yum install python36 gcc python3-devel -y
status $?

id ${APPUSER} &>> $LOGFILE
if [ $? -ne 0 ]; then
echo "Create a service account"
useradd roboshop
fi
status $?

echo "Donwloading the component"
curl -L -s -o /tmp/payment.zip "https://github.com/stans-robot-project/payment/archive/main.zip" &>> $LOGFILE
status $?

echo "Copy the ${COMPONENT} to ${APPUSER} home directory"
cd /home/${APPUSER}/
rm -rf ${COMPONENT} &>> $LOGFILE
unzip /tmp/${COMPONENT}.zip &>> $LOGFILE
status $?

echo "Modifying the owner ship"
mv ${COMPONENT}-main ${COMPONENT} &>> $LOGFILE
chown -R ${APPUSER}:${APPUSER} /home/roboshop/${COMPONENT} &>> $LOGFILE
status $?


echo "Install the dependecies fro ${COMPONENT} component"
cd /home/${APPUSER}/${COMPONENT} &>> $LOGFILE
pip3 install -r requirements.txt &>> $LOGFILE
status $?