#! /bin/sh
uname -n
user=`whoami`
y=`date +%Y`

if [ "$user" != "root" ]
then
  echo "This script only modifies password for user root!!!"
  echo "Current user: $user isn't root."
  exit 2
fi

echo teMP'!'"$y"# | passwd --stdin ${user}
if [ $? -eq 0 ]
  then
  echo "Change password for ${user} successful"
fi

