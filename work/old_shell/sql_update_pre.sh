#!/bin/sh
#--sql update pre shell--
echo "SQL_updata_pre.sh Start" >> /workhome/itcc/work/logs/S2.log
echo "Process No. is '$$'." >> /workhome/itcc/work/logs/S2.log
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
if [ ! -f ${_exec_ksh} ]
then
    echo "環境設定ファイルが存在しません"
    exit 1
fi
. ${_exec_ksh}
SHDIR="${OLD_SHELL_PATH}"
ENVFILE="/workhome/home/cdcadmin/sh/.sql_env.txt"
SQLHDIR="/workhome/home/ort/hon_sql"
SQLQDIR="/workhome/home/ort/qa_sql"
OPUSER="op5000"

SERVER=${1}
INSTANCE=${3}

#function get DB string
#getDBString(){
#    awk -F, -v server=${SERVER} -v instance=${INSTANCE} ' !/^#/ {
#        if ( $1 == server && $2 == instance ) {
#            print $3;
#            exit;
#        }
#    }' ${ENVFILE}
#}

#function get NLS_LANG
#getNLS_LANG(){
#    awk -F, -v server=${SERVER} -v instance=${INSTANCE} ' !/^#/ {
#        if ( $1 == server && $2 == instance ) {
#            print $4;
#            exit;
#        }
#    }' ${ENVFILE}
#}

#function get Honban or QA
#getHonQa(){
#    awk -F, -v server=${SERVER} -v instance=${INSTANCE} ' !/^#/ {
#        if ( $1 == server && $2 == instance ) {
#            print $5;
#            exit;
#        }
#    }' ${ENVFILE}
#}

#get DB string
DB_STRING=`cat /workhome/home/cdcadmin/sh/.sql_env.txt | grep $1 | awk -F',' '{print $3}'`
echo "db_string="${DB_STRING} >> /workhome/itcc/work/logs/S2.log
if [ $DB_STRING = "error" ]; then
 echo "error:host name or DB instance" 2>&1
 exit 1
fi

#get NLS_LANG
NLS_LANG=`cat /workhome/home/cdcadmin/sh/.sql_env.txt | grep $1 | awk -F',' '{print $4}'`
echo "nls_lang="$NLS_LANG >> /workhome/itcc/work/logs/S2.log
if [ $NLS_LANG = "error" ]; then
 echo "error:host name or DB instance" 2>&1
 exit 1
fi

echo "par1="$1 >> /workhome/itcc/work/logs/S2.log
echo "par2="$2 >> /workhome/itcc/work/logs/S2.log
echo "par3="$3 >> /workhome/itcc/work/logs/S2.log
echo "par4="$4 >> /workhome/itcc/work/logs/S2.log
#get Honban or QA
HON_QA=`cat /workhome/home/cdcadmin/sh/.sql_env.txt | grep $1 | awk -F',' '{print $5}'`
echo "hon_qa="${HON_QA} >> /workhome/itcc/work/logs/S2.log
if [ "${HON_QA}" = "" ]; then
 #echo ${HON_QA} >> /workhome/itcc/work/logs/S2.log
 echo "error:host name or DB instance" >> /workhome/itcc/work/logs/S2.log 2>&1
 exit 1
fi

SQLDIR=${SQLQDIR}
if [ "${HON_QA}" = "H" ]; then
  SQLDIR=${SQLHDIR}
  echo "sqldir="${SQLDIR} >> /workhome/itcc/work/logs/S2.log
fi

#sql file check
if [ ! -f ${SQLDIR}/$2 ]; then
  echo "error:SQL file not exists" >> /workhome/itcc/work/logs/S2.log 2>&1
  echo "SQLfile:"${SQLDIR}/$2 >> /workhome/itcc/work/logs/S2.log
  exit 1
fi

echo "opuser:$OPUSER" >> /workhome/itcc/work/logs/S2.log
echo "shdir:${SHDIR}" >> /workhome/itcc/work/logs/S2.log
echo "sqldir:${SQLDIR}/$2" >> /workhome/itcc/work/logs/S2.log
#call sql_update_exe.sh
#${SHDIR}/sql_update_exe ${SQLDIR}/$2 "${DB_STRING} as sysdba" ${NLS_LANG} $4
#${SHDIR}/sql_update_exe ${SQLDIR}/$2 ${DB_STRING} ${NLS_LANG} $4
sudo -u $OPUSER sh -c "sh ${SHDIR}/sql_update_exe ${SQLDIR}/$2 ${DB_STRING} ${NLS_LANG} $4" 
errno=$?
echo "exit sql_update_exe:${errno}" >> /workhome/itcc/work/logs/S2.log


