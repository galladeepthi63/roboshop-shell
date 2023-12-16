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

    curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
    VALIDATE $? "downloading the erlang "

    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
    VALIDATE $? " Downloading the rabbitmq script"

    dnf install rabbitmq-server -y &>> $LOGFILE
    VALIDATE $? "install rabbitmq server"

    systemctl enable rabbitmq-server &>> $LOGFILE
    VALIDATE $? "enable rabbitmq server"

    systemctl start rabbitmq-server  &>> $LOGFILE
    VALIDATE $? "start rabbitmq server "

    rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
    VALIDATE $? "create the user"

    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
    VALIDATE $? "setting permission"
