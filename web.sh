#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
#MONGODB_HOST= 172.31.34.122

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
        if [ $1 -ne 0 ]
        then 
            echo -e "$2 ...$R FAILED $N"
        else
            echo -e "$2...$G SUCESS $N"
        fi
    }
    if [ $ID -ne 0 ] 
    then 
        echo "ERROR:: Please run this script with root user "
        exit 1 # you can give other than 0
    else 
        echo "you are root user "
    fi # fi means reverse of if, indicating condition end

    dnf install nginx -y &>> $LOGFILE
    VALIDATE $? "Install Nginx"

    systemctl enable nginx &>> $LOGFILE
    VALIDATE $? "Enable Nginx service"

    systemctl start nginx &>> $LOGFILE
    VALIDATE $? "Start Nginx service"

    rm -rf /usr/share/nginx/html/* &>> $LOGFILE
    VALIDATE $? "remove the web server "

    curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
    VALIDATE $? "Downloading the web application "

    cd /usr/share/nginx/html &>> $LOGFILE
    VALIDATE $? "moving nginx html directory"

    unzip /tmp/web.zip &>> $LOGFILE
    VALIDATE $? "Unzip web application "

    cp /home/centos/roboshop-shell/roboshop.conf  /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
    VALIDATE $? "Copying the roboshop "

    systemctl restart nginx &>> $LOGFILE
    VALIDATE $? "restart nginx server "

