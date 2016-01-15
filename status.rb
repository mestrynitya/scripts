# This script will do a call to mentioned URL. Will fetch the response and see whether it is success or not.
# Based on the response it gives OK or CRITIAL status (no WARNING)

#The XML which I was calling was written by some other developer. It was written for our internal setup where it tells us the total number of servers we have and if there is any need to deploy a new server. I wrote this script to call xml and get the status and response. Based on the response it decides the criticality of the number of servers needed. This XML would return two responses.
#1. Whether the API status succeeded or not
#2. Upon it's execution it returns the data based on what API status was

### Author : Nitesh Mestry

#!/bin/env ruby

require 'uri'
require 'net/http'
require 'rubygems'
require 'json'
require 'xmlsimple'

url = URI('https://yoyoyoy/yoyoyoy/yoyo.xml')
response1 = Net::HTTP.get(url)
response2 = XmlSimple.xml_in response1
final_status = response2["status"]

empty_status = response1.empty?
if	empty_status == true
# Exit if status is empty
	puts "API returned blank output"
	exit 1

elsif	empty_status == false
#Primary two conditions will be checked whether the API run or not
        #estatus = final_status[0].casecmp("SUCCESS")
        #check if the status is seccess
	if final_status[0].downcase == "success"
		print "API status : #{final_status[0]} "
		final_data = response2["data"]
                #check if returned data is success or failure
		if final_data[0].downcase == "success"
			print response2['data']
			exit 0
		else
			print " : But failed to get the data"
			print response2['data']
			exit 2
		end
        #check if the status is failure
	elsif final_status[0].downcase == "failure"
		print "API failed to execute: "
		puts response2['message']
		puts response2['errorCode']
		exit 2
	end

end
