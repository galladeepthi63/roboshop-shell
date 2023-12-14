#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

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

    cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
    VALIDATE $? " Replace the mongodb "

    dnf install mongodb-org -y  &>> $LOGFILE
    VALIDATE $? " Installing Mongodb "

    systemctl enable mongod &>> $LOGFILE
    VALIDATE $? "enable the mongodb"

    systemctl start mongod &>> $LOGFILE
    VALIDATE $? "start the mongodb"

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
    VALIDATE $? " remote access to mongodb"

    systemctl restart mongod &>> $LOGFILE
    VALIDATE $? " Restart the mongodb "
    