#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
MONGODB_HOST= 172.31.34.122

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

    dnf module disable nodejs -y &>> $LOGFILE
    VALIDATE $? " disable the nodejs"

    dnf module enable nodejs:18 -y &>> $LOGFILE
    VALIDATE $? " enable nodejs:18 "

    dnf install nodejs -y  &>> $LOGFILE
    VALIDATE $? " install the nodejs "

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

    curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
    VALIDATE $? "download  the catalogue application"

    cd /app 
    unzip /tmp/catalogue.zip &>> $LOGFILE
    VALIDATE $? "unzip the catalogue"

    npm install &>> $LOGFILE
    VALIDATE $? "Installing the npm"

    #cp C:/Users/v-ragalla/daws/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
    cp /home/centos//roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
    VALIDATE $? "copying the catalogue service"

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "reload the daemon"

    systemctl enable catalogue &>> $LOGFILE
    VALIDATE $? "enable catalogue"

    systemctl start catalogue &>> $LOGFILE
    VALIDATE $? "start the catalogue"

    #cp C:/Users/v-ragalla/daws/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
    cp /home/centos//roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
    VALIDATE $? "copying the mongodb repo "

    dnf install mongodb-org-shell -y &>> $LOGFILE
    VALIDATE $? "install the mongodb client"

    mongo --host $MONGODB_HOST </app/schema/catalogue.js
    VALIDATE $? "Loading catalouge data into MongoDB"
