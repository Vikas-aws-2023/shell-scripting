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
rm -rf ${COMPONENT} &>> $LOGFILE
unzip /tmp/${COMPONENT}.zip &>> $LOGFILE
status $?

echo "Modifying the owner ship"
mv ${COMPONENT}-main ${COMPONENT} &>> $LOGFILE
chown -R ${APPUSER}:${APPUSER} /home/roboshop/${COMPONENT} &>> $LOGFILE
status $?

echo "Installing ${COMPONENT} module"
cd /home/${APPUSER}/${COMPONENT}/ &>> $LOGFILE
npm install &>> $LOGFILE
status $?

echo "update the ${COMPONENT} systemd file"
sed -i -e 's/MONGO_DNSNAME/172.31.88.111/' /home/${APPUSER}/${COMPONENT}/systemd.service &>> $LOGFILE
mv /home/${APPUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>> $LOGFILE
status $?

echo "Now, lets set up the service with systemctl"

systemctl daemon-reload &>> $LOGFILE
systemctl restart ${COMPONENT} &>> $LOGFILE
systemctl enable ${COMPONENT} &>> $LOGFILE
systemctl status ${COMPONENT} -l
status $?

echo "Installation is completed successfully"








