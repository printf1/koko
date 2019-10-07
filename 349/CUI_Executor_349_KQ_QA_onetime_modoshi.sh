#!/bin/bash
uname -n
user=`whoami`
HOME=`pwd`
LOG_DIR=`pwd`
. ${HOME}/BATCH_COMMON_FUNC.sh
u=${HOME}/349_userlist.cfg



if [ "$user" != "root" ]
then
  echo "Current user: $user isn't root."
  outlog "Current user: $user isn't root."
  exit 2
fi


if [ ! -e $u ]
then
    echo "File $u doesn't exist!"
	outlog "File $u doesn't exist!"
    exit
fi


temp=`sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u`
if [ `sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u |wc -l` -eq 0 ]
then
    echo "File $u is empty!"
	outlog "File $u is empty!"
    exit
fi

cat $u | while read user password
do
a=$user
b=$password
if [ -z "$b" ]
  then 
    echo "password is empty"
	outlog "password is empty"
	exit
fi 	
 
i=`cat /etc/shadow | cut -d':' -f1 | grep -wc "$a"`
 if [ $i -eq 0 ]
 then
   echo "$a doesn't exist"
   outlog "$a doesn't exist"
   exit
 fi
 
echo "$b" | passwd --stdin $a
 if [ $? -eq 0 ]
   then
     echo "Change password for $a successful"
	 outlog "Change password for $a successful"
 fi
 done