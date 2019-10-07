#!/bin/bash
uname -n
mm=`date +%m%d`
user=`whoami`
u=./252_honban_userlist.cfg


if [ "$user" != "root" ]
then
  echo "Current user: $user isn't root."
  exit 2
fi


if [ ! -e $u ]
then
    echo "File $u doesn't exist!"
    exit
fi
temp=`sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u`
if [ `sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u |wc -l` -eq 0 ]
then
    echo "File $u is empty!"
    exit
fi

for line in $temp
do
mt=`cat /etc/shadow | grep -wc "$line"`
if [ $mt -ge 0 ]
then
 i=`cat /etc/shadow | cut -d':' -f1 | grep -wc "$line"`
 if [ $i -eq 0 ]
 then
   echo "$line doesn't exist"
   exit
 fi
 t=`echo "$line" | rev`
 echo Cc"$t""$mm"! | passwd --stdin $line
  if [ $? -eq 0 ]
   then
     echo "Change password for $line successful"
  fi
fi
done
