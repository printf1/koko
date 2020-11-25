#!/bin/sh
#--sql update shell--
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
if [ ! -f ${_exec_ksh} ]
then
    echo "環境設定ファイルが存在しません"
    exit 1
fi
. ${_exec_ksh}
SHDIR="${OLD_SHELL_PATH}"
echo "SQL_updata.sh Start" >> /workhome/itcc/work/logs/S2.log
#parameter check
if [ $# -lt 3 ]; then
  echo "error:parameter less" 2>&1
  exit 1
elif [ $# -gt 4 ]; then
  echo "error:parameter more" 2>&1
  exit 1
fi

if [ $# -eq 4 ]; then
  if [ "$4" != "-r" -a "$4" != "-commit" -a "$4" != "-rc" ]; then
    echo "error:4th parameter is not '-r','-commit','-rc'" 2>&1
    exit 1
  fi
fi
#chmod 711 $SHDIR/sql_update_call.sh
sh $SHDIR/sql_update_call.sh $1 $2 $3 $4
#chmod 111 $SHDIR/sql_update_call.sh
