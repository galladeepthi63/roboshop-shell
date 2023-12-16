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

    dnf module disable mysql -y &>> $LOGFILE
    VALIDATE $? "disable mysql"

    cp /home/centos/roboshop-shell/mysql.repo  /etc/yum.repos.d/mysql.repo &>> $LOGFILE
    VALIDATE $? "copying the mysql repo"

    dnf install mysql-community-server -y &>> $LOGFILE
    VALIDATE $? "install the mysql server"

    systemctl enable mysqld &>> $LOGFILE
    VALIDATE $? "enable mysql"

    systemctl start mysqld &>> $LOGFILE
    VALIDATE $? "start mysql"

    mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
    VALIDATE $? "Setting  MySQL root password"