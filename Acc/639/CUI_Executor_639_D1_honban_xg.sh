#! /bin/sh
uname -n
user=`whoami`
HOME=`pwd`
LOG_DIR=`pwd`
. ${HOME}/BATCH_COMMON_FUNC.sh
u=${HOME}/639_xg_userlist.cfg


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

for line in $temp
do
mt=`cat /etc/shadow | grep -wc "$line"`
if [ $mt -ge 0 ]
then
 i=`cat /etc/shadow | cut -d':' -f1 | grep -wc "$line"`
 if [ $i -eq 0 ]
 then
   echo "$line doesn't exist"
   outlog "$line doesn't exist"
   exit
 fi

passwd -l $line
  if [ $? -eq 0 ];then 
     echo "作業は正常終了にしました"
	 outlog "作業は正常終了にしました"
　fi

fi
done