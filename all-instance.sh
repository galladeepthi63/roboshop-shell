#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-0161bbc0ff4c0e791
INSTANCES=("mongodb" "catalogue" "web" "redis" "user" "mysql" "cart" "rabbitmq" "shipping" "payment" "dispatch")
ZONE_ID=Z01134191WS8YPNB3E9T1
DOMAIN_NAME="ramakrishna.cloud"

for i in "${INSTANCES[@]}"
    do 
        if [ $i == "mongodb" ] || [ $i == "redis" ] || [ $i == "mysql" ]
        then 
            INSTANCE_TYPE="t3.small"
        else
            INSTANCE_TYPE="t2.micro"
        fi



        IP_ADDRESS=$(aws ec2 run-instances --image-id ami-03265a0778a880afb  --instance-type $INSTANCE_TYPE  --security-group-ids sg-0161bbc0ff4c0e791 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
        echo "$i: $IP_ADDRESS"

        #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    } '

done






