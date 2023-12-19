#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-0161bbc0ff4c0e791
INSTANCES=("mongodb" "redis" "mysql" "cart" "rabbitmq" "catalogue")

for i in "${INSTANCES[@]}"
    do 
        if [ $i == "mongodb"] || [ $i == "redis"] || [ $i == "mysql"]
        then 
            INSTANCE_TYPE="t3.small"
        else
            INSTANCE_TYPE="t2.micro"
        fi
    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-03265a0778a880afb  --instance-type $INSTANCE_TYPE  --security-group-ids sg-0161bbc0ff4c0e791 )
    echo "$i: $IP_ADDRESS
    

