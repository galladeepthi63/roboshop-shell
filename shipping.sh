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

    dnf install maven -y &>> $LOGFILE
    VALIDATE $? "install the maven "

    id roboshop
    if [ $? -ne 0 ]
    then 
        useradd  roboshop
        VALIDATE $? "added the roboshop" 
    else
        echo -e "roboshop user already exist  $Y SKIPPING $N"
    fi

    mkdir -p /app

    curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
    VALIDATE $? "Downloading the shipping application "

    cd /app
    unzip /tmp/shipping.zip &>> $LOGFILE
    VALIDATE $? "unzip the shipping application "

    cd /app

    mvn clean package &>> $LOGFILE
    VALIDATE $? " install depenceis "

    mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
    VALIDATE $? "renameing the jar "

    cp /home/centos/roboshop-shell/shipping.service  /etc/systemd/system/shipping.service &>> $LOGFILE
    VALIDATE $? "copying the shipping service"

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "reload the shipping server"

    systemctl start shipping &>> $LOGFILE
    VALIDATE $? " start the shipping "

    dnf install mysql -y &>> $LOGFILE
    VALIDATE $? " install the mysql "

    mysql -h 172.31.17.159 -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
    VALIDATE $? " access the mysql server "

    systemctl restart shipping &>> $LOGFILE
    VALIDATE $? " restart the shipping"

