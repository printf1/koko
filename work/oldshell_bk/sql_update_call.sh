#!/bin/sh
OP_USER="op5000"
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
if [ ! -f ${_exec_ksh} ]
then
    echo "環境設定ファイルが存在しません"
    exit 1
fi
. ${_exec_ksh}
SHDIR="${OLD_SHELL_PATH}"

sudo -u $OP_USER sh ${SHDIR}/sql_update_pre.sh $1 $2 $3 $4
