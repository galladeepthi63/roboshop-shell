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
dnf module disable nodejs -y
VALIDATE $? "disable the nodejs"

dnf module enable nodejs:18 -y
VALIDATE $? "enable the nodejs"

dnf install nodejs -y
VALIDATE $? "install the nodejs"

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

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip
VALIDATE $? "Download the cart application"

cd /app 
unzip /tmp/cart.zip
VALIDATE $? "unzip the cart application"

cd /app 
npm install 
VALIDATE $? "Download the depences"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service
VALIDATE $? "copying the car service"

systemctl daemon-reload
VALIDATE $? "reload the daemon"

systemctl enable cart 
VALIDATE $? "Enable cart"

systemctl start cart
VALIDATE $? "Start "start the cart servie"