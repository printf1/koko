#!/bin/sh
#--sql update pre shell--
echo "Process No. is '$$'."
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
getDBString(){
    awk -F, -v server=${SERVER} -v instance=${INSTANCE} ' !/^#/ {
        if ( $1 == server && $2 == instance ) {
            print $3;
            exit;
        }
    }' ${ENVFILE}
}

#function get NLS_LANG
getNLS_LANG(){
    awk -F, -v server=${SERVER} -v instance=${INSTANCE} ' !/^#/ {
        if ( $1 == server && $2 == instance ) {
            print $4;
            exit;
        }
    }' ${ENVFILE}
}

#function get Honban or QA
getHonQa(){
    awk -F, -v server=${SERVER} -v instance=${INSTANCE} ' !/^#/ {
        if ( $1 == server && $2 == instance ) {
            print $5;
            exit;
        }
    }' ${ENVFILE}
}

#get DB string
DB_STRING=`getDBString $1 $3`
if [ $DB_STRING = "error" ]; then
 echo "error:host name or DB instance" 2>&1
 exit 1
fi

#get NLS_LANG
NLS_LANG=`getNLS_LANG $1 $3`
if [ $NLS_LANG = "error" ]; then
 echo "error:host name or DB instance" 2>&1
 exit 1
fi

#get Honban or QA
HON_QA=`getHonQa $1 $3`
if [ "${HON_QA}" = "" ]; then
 echo "error:host name or DB instance"  2>&1
 exit 1
fi

SQLDIR=${SQLQDIR}
if [ "${HON_QA}" = "H" ]; then
  SQLDIR=${SQLHDIR}
fi

#sql file check
if [ ! -f ${SQLDIR}/$2 ]; then
  echo "error:SQL file not exists" 2>&1
  exit 1
fi

#call sql_update_exe.sh
#${SHDIR}/sql_update_exe ${SQLDIR}/$2 "${DB_STRING} as sysdba" ${NLS_LANG} $4
#${SHDIR}/sql_update_exe ${SQLDIR}/$2 ${DB_STRING} ${NLS_LANG} $4
sudo -u $OPUSER sh -c "sh ${SHDIR}/sql_update_exe ${SQLDIR}/$2 ${DB_STRING} ${NLS_LANG} $4"
