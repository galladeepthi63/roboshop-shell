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

    dnf install python36 gcc python3-devel -y
    VALIDATE $? " install python "

     id roboshop
    if [ $? -ne 0 ]
    then 
        useradd  roboshop
        VALIDATE $? "added the roboshop" 
    else
        echo -e "roboshop user already exist  $Y SKIPPING $N"
    fi

    mkdir -p /app
    VALIDATE $? "creating the app directory"

    curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
    VALIDATE $? "Download the payment application"

    cd /app 
    unzip /tmp/payment.zip &>> $LOGFILE
    VALIDATE $? " unzip payment application "

    cd /app 
    pip3.6 install -r requirements.txt &>> $LOGFILE
    VALIDATE $? "Download the dependencies"

    cp /home/centos/roboshop-shell/payment.service  /etc/systemd/system/payment.service &>> $LOGFILE
    VALIDATE $? "Copying the payment "

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? " reload the payment"

    systemctl enable payment &>> $LOGFILE
    VALIDATE $? "Enable payment"

    systemctl start payment &>> $LOGFILE
    VALIDATE $? "Start payment "

     