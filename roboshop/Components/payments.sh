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

USERID=$(id -u roboshop)
GROUPID=$(id -u roboshop)

echo "Update uid and gid for ${COMPONENT}.ini file"
sed -i -e "/^uid/ c uid=${USERID}" -e "/^gid/ c gid=${GROUPID}" cd /home/${APPUSER}/${COMPONENT}/${COMPONENT}.ini &>> $LOGFILE
status $?

echo "update the ${COMPONENT} systemd file"
sed -i -e 's/CARTHOST/172.31.89.15/' -e 's/USERHOST/172.31.82.55/' -e 's/AMQPHOST/172.31.91.5/' /home/${APPUSER}/${COMPONENT}/systemd.service &>> $LOGFILE
mv /home/${APPUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>> $LOGFILE
status $?

echo "Now, lets set up the service with systemctl"

systemctl daemon-reload &>> $LOGFILE
systemctl restart ${COMPONENT} &>> $LOGFILE
systemctl enable ${COMPONENT} &>> $LOGFILE
systemctl status ${COMPONENT} -l &>> $LOGFILE
status $?

echo "Installation is completed successfully"
