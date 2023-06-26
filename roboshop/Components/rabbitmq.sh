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
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
status $?

echo "Install ${COMPONENT}"
yum install rabbitmq-server -y
status $?

echo "Start ${COMPONENT}"
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
systemctl status rabbitmq-server -l
status $?

echo "creating ${COMPONENT} ${APPUSER}"
rabbitmqctl add_user roboshop roboshop123
status $?

echo "Configure the previlizes for ${COMPONENT} ${APPUSER}"
rabbitmqctl set_user_tags roboshop administrator
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
status $?

