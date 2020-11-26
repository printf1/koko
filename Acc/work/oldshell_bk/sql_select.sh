#!/bin/sh
#--sql select shell--
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
if [ ! -f ${_exec_ksh} ]
then
    echo "環境設定ファイルが存在しません"
    exit 1
fi
. ${_exec_ksh}
SHDIR="${OLD_SHELL_PATH}"


#sql_select.sh starting check
#CECKSTR=`ps -af | grep -c ${LOGNAME}.*[s]ql_select`
#if [ ${CECKSTR} -gt 1 ]; then
#  echo "error:sql_select.sh is already running." 1>&2
#  exit 1
#fi

#parameter check
if [ $# -eq 6 ]; then
  if [ $6 != "-z" ]; then
    echo "error:No.6 parameter is not -z" 2>&1
    exit 1
  fi
elif [ $# -lt 5 ]; then
  echo "error:parameter less" 2>&1
  exit 1
elif [ $# -gt 6 ]; then
  echo "error:parameter more" 2>&1
  exit 1
fi

#chmod 711 $SHDIR/sql_select_call.sh
sh $SHDIR/sql_select_call.sh $1 $2 $3 $4 $5 $6
#chmod 111 $SHDIR/sql_select_call.sh
