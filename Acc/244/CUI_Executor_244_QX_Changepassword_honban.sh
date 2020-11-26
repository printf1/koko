#! /bin/bash
uname -n
HOME=`pwd`
LOG_DIR="/home/log"
. ${HOME}/BATCH_COMMON_FUNC.sh
u=${HOME}/244_userlist.cfg
if [ ! -e $u ]
then
    echo "File $u doesn't exist!"
    outlog "File $u doesn't exist!"
    exit
fi
temp=`sed -e '/^$/d'  $u | sed '/^#.*\ | ^$/d' $u`
if [ `sed -e '/^$/d'  $u | sed '/^#.*\ | ^$/d' $u |wc -l` -eq 0 ]
then
    echo "File $u is empty!"
    outlog "File $u is empty!"
    exit
fi
cat $u | grep -v "^#" | grep -v "^$" \
 | while read user  
do
if [ $? -eq 0 ]
then
 i=`cat /etc/shadow | cut -d':' -f1 | grep -wc "$user"`
 if [ $i -eq 0 ]
 then
   echo "$user doesn't exist"
   outlog "$user doesn't exist"
   exit
 fi

 echo _"$user"_ | passwd --stdin $user
 if [ $? -eq 0 ]
 then
 echo "change password for $user successful"
 outlog "change password for $user successful"
 fi
else
 echo "permission denied"
 outlog "permission denied"
 exit 1
fi
done
