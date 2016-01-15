#!/bin/sh

### This script will reset password for multiple users
### users file should have two entries like below
### e.g. abcd yoyoyo
### Here 'abcd' is the username and 'yoyoyo' is the password

	#echo $password|passwd $username --stdin

for username in `cat users | awk '{print $1}'`
	do
	echo "username" $username
	password=`cat users | awk '{print $2}'`
	echo "password" $password
done
