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

    dnf install golang -y &>> $LOGFILE
    VALIDATE $? "installing golang"

     id roboshop
    if [ $? -ne 0 ]
    then 
        useradd  roboshop
        VALIDATE $? "added the roboshop" 
    else
        echo -e "roboshop user already exist  $Y SKIPPING $N"
    fi

    mkdir -p /app &>> $LOGFILE
    VALIDATE $? "Createing directory"

    curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE
    VALIDATE $? "Downloading the dispatch application"

    cd /app 
    unzip /tmp/dispatch.zip &>> $LOGFILE
    VALIDATE $? " Unzip dispatch application "

    cd /app
    go mod init dispatch &>> $LOGFILE
    VALIDATE $? "init dispatch"

    go get &>> $LOGFILE
    VALIDATE $? "go dispatch"

    go build &>> $LOGFILE
    VALIDATE $? "build dispatch"

    cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE
    VALIDATE $? "Copying the dispatch "

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "Reload the dispatch "

    systemctl enable dispatch &>> $LOGFILE
    VALIDATE $? "enable dispatch"

    systemctl start dispatch &>> $LOGFILE
    VALIDATE $? "start dispatch"
    
