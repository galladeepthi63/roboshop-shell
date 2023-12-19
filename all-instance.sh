#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-0161bbc0ff4c0e791
INSTANCES=("mongodb" "redis" "mysql" "cart" "rabbitmq" "catalogue")
ZONE_ID=Z089758214EN5STGRKQNW
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
    --change-batch "
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            "Name"              : "$i.$DOMAIN_NAME"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "$IP_ADDRESS"
            }]
        }
        }]
    } "

done






