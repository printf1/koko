#!/bin/sh
job_id=$1
job_token=$2
status=$3
log=$4
a=$5
log_status=`echo "&log="${log}'$|$'${a:-None}'$|$'${status}`
#echo "===================" >> /workhome/itcc/work/logs/sta.log
#echo ${job_id} >> /workhome/itcc/work/logs/sta.log
#echo $status >> /workhome/itcc/work/logs/sta.log
#echo $log_status >> /workhome/itcc/work/logs/sta.log
#echo "===================" >> /workhome/itcc/work/logs/sta.log
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
source ${_exec_ksh}
if [ $http_env = "QA" ];then
  curl_dic=`curl -H "Content-Type: application/json"  -X POST  -d '{"username": "$curl_user", "password": "$curl_QA_pass"}' "$curl_HB_url"`
  curl_token=`echo ${curl_dic} | awk -F':' '{print $2}' | awk -F',' '{print $1}'`
  curl -H 'Content-Type: application/json, "apiToken": $curl_token' -X GET "$curl_http_get$log_status"   

else
  curl_dic=`curl -H "Content-Type: application/json"  -X POST  -d '{"username": "$curl_user", "password": "$curl_HB_pass"}' "$curl_HB_url"`
  curl_token=`echo ${curl_dic} | awk -F':' '{print $2}' | awk -F',' '{print $1}'`
  curl -H "Content-Type: application/json, "apiToken": $curl_token"  -X GET "$curl_http_get$log_status" 

fi
