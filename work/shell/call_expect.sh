#!/bin/sh
ROOT_PASSWD=$1
v_server_ip=$2
cmd_jp1=$3
/usr/bin/expect <<EOF
   set timeout 8
   spawn ssh root@${v_server_ip}
   expect "(yes/no)?"
   send "yes\n"
   expect "password:"
   send "${ROOT_PASSWD}\n"
   
   expect "#" 
   send "exit\n" 
   expect eof
EOF
