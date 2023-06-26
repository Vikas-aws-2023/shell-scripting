#!/bin/bash

COMPONENT=rabbitmq
LOGFILE="/tmp/${COMPONENT}.log"
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

echo "${COMPONENT} dependency"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>> $LOGFILE
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>> $LOGFILE
status $?

echo "Install ${COMPONENT}"
yum install rabbitmq-server -y &>> $LOGFILE
status $?

echo "Start ${COMPONENT}"
systemctl enable rabbitmq-server &>> $LOGFILE
systemctl start rabbitmq-server &>> $LOGFILE
systemctl status rabbitmq-server -l &>> $LOGFILE
status $?

rabbitmqctl list_users | grep roboshop &>> $LOGFILE

if [ $? -ne 0 ]; then
echo "creating ${COMPONENT} ${APPUSER}"
rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
status $?
fi

echo "Configure the previlizes for ${COMPONENT} ${APPUSER}"
rabbitmqctl set_user_tags roboshop administrator &>> $LOGFILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
status $?

echo "${COMPONENT}  instalation is completed successfully"

