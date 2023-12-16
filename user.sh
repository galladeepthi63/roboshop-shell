#!/bin/bash
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
    
    dnf module disable nodejs -y &>> $LOGFILE

    VALIDATE $? "disable to nodejs"

    dnf module enable nodejs:18 -y &>> $LOGFILE

    VALIDATE $? "enable the nodejs 18"

    dnf install nodejs -y &>> $LOGFILE

    VALIDATE $? "install the node js"

      id roboshop
    if [ $? -ne 0 ]
    then 
        useradd  roboshop
        VALIDATE $? "added the roboshop" 
    else
        echo -e "roboshop user already exist  $Y SKIPPING $N"
    fi

    mkdir -p /app &>> $LOGFILE
     VALIDATE $? "creating the app directory"

     curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

     VALIDATE $? "download the user application"
    cd /app 
    unzip /tmp/user.zip  &>> $LOGFILE

    VALIDATE $? "Unzip the user application"

    cd /app 
    npm install  &>> $LOGFILE
    VALIDATE $? "install the npm"

    cp /home/centos/roboshop-shell/user.service  /etc/systemd/system/user.service &>> $LOGFILE
    VALIDATE $? "copying the user services"

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "reload the daemon"

    systemctl enable user &>> $LOGFILE
    VALIDATE $? "enable the user"

    systemctl start user &>> $LOGFILE
    VALIDATE $? "start user "

    cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
    VALIDATE $? "copying the mongo repo"

    dnf install mongodb-org-shell -y &>> $LOGFILE
    VALIDATE $? "install the mongodb"
    
    mongo --host 172.31.34.59 </app/schema/user.js &>> $LOGFILE
    VALIDATE $? "access the ip address "