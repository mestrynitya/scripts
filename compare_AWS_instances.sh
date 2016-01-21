#!/bin/bash

### About this script : 
#When this script is run, it checks which all instances are running
#It sorts them and compares if the desired instance is running or noti
#If it is running then other servers will exit this script with exit code as 1
#The instance which is supposed to run will only give successful exit status as 0.

### Author : Nitesh Mestry
###

### export access and secret keys
AWS_ACCESS_KEY_ID="XXXXXXXXXXXXXXXXXXXX"
AWS_SECRET_KEY="XXXXXXXXXXXXXXXXXXXXX"


### Check for running instance IDs and compare

for a in {1..3}
do
IID[$a]=`comm -1 -2 <(comm -1 -2 <(ec2-describe-tags -aws-access-key $AWS_ACCESS_KEY_ID --aws-secret-key $AWS_SECRET_KEY --filter "resource-type=instance" --filter "key=Name" |grep web|awk '{print $3}'|sort) <(ec2-describe-instances -aws-access-key $AWS_ACCESS_KEY_ID --aws-secret-key $AWS_SECRET_KEY | grep INSTANCE | grep running |awk '{print $2}'|sort) | sort | head -1) <(ec2-metadata | grep instance-id |awk '{print $2}')`

echo ${IID[1]}
echo ${IID[2]}
echo ${IID[3]}


## zzz..z.z.z.z...   sleeping for 5 seconds
sleep 5

done

### above API gives the blank output if the servers are not matched. So exiting with exit code 1

if [[ -z ${IID[1]} ]] || [[ -z ${IID[2]} ]] || [[ -z ${IID[3]} ]]; then
        echo "Server verification failed. Exiting. Some other server is having higher priority than me."
        exit 1;
fi

### Compare the values here and exit with exit code 0
if [ ${IID[1]} = ${IID[2]} ] && [ ${IID[1]} = ${IID[3]} ]; then
                echo "Server has been verified thrice. Returning to the cron script."
                exit 0;
        fi

### code written beyond this line will not get executed
