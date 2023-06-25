#!/bin/bash

COMPONENT=frontend
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

echo "Nginix install"
yum install nginx -y &>> $LOGFILE

status $?

echo "Downloading the ${COMPONENT} component"

curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"

status $?

echo "Perfoming cleanup"
cd /usr/share/nginx/html
rm -rf * &>> $LOGFILE



echo "Extract the content"
unzip /tmp/${COMPONENT}.zip &>> $LOGFILE
mv ${COMPONENT}-main/* . &>> $LOGFILE
mv static/* . &>> $LOGFILE
rm -rf ${COMPONENT}-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

status $?


echo "Update the config file"
sed -i -e "/catalogue/s/localhost/172.31.84.24/" -e "/user/s/localhost/172.31.82.55/" -e "/cart/s/localhost/172.31.89.15/" /etc/nginx/default.d/roboshop.conf
status $?


echo "Start the service for ${COMPONENT} component"
systemctl restart nginx
systemctl enable nginx
status $?
echo "Fontend installation completed successfully"

    # location /api/catalogue/ { proxy_pass http://172.31.84.24:8080/; }

    # location /api/user/ { proxy_pass http://172.31.84.24:8080/; }

    # location /api/cart/ { proxy_pass http://localhost:8080/; }

    # location /api/shipping/ { proxy_pass http://localhost:8080/; }

    # location /api/payment/ { proxy_pass http://localhost:8080/; }





# cd /usr/share/nginx/html
# rm -rf *
# unzip /tmp/${COMPONENT}.zip
# mv ${COMPONENT}-main/* .
# mv static/* .
# rm -rf ${COMPONENT}-main README.md
# mv localhost.conf /etc/nginx/default.d/roboshop.conf
# systemctl enable nginx
# systemctl start nginx