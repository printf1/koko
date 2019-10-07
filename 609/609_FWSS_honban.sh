#! /bin/sh
uname -n
x=1
m=`date -d "$(date +%Y-%m-%d) next month" +%Y-%m-%d`
user=`whoami`
u=./609_userlist.cfg
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

cat $u | grep -v "^#" | grep -v "^$" \
 | while read tuser password
do
echo "$x"
x=`expr $x + 1`
a=$tuser
b=$password
if [ -z "$b" ]
  then
    echo "password is empty"
    exit
 fi

i=`cat /etc/shadow | cut -d':' -f1 | grep -wc "$a"`
 if [ $i -eq 0 ]
 then
   echo "$a"
   echo "${a} doesn't exist"
   exit
 fi
#chage -E $m -W 7 $a
echo "$m"
usermod -e $m $a
 if [ $? -eq 1 ]
   then
    echo "Failed to change date"
    exit
 fi

echo "$b" | passwd --stdin $a
 if [ $? -eq 0 ]
   then
     echo "Change password for $a successful"
 fi
done

