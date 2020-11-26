#!/bin/sh
#--sql select pre shell--
echo "Process No. is '$$'."
echo "SQL-select-pre-start" >> /workhome/itcc/work/logs/param_test.log
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

LANGNAME=`env |grep "LANG=ja_JP" |cut -c 6-`
CHNGLANG=

#function get DB string
getDBString(){
    awk -F, -v svr=${SERVER} -v ins=${INSTANCE} ' !/^#/ {
        if ( $1 == svr && $2 == ins ) {
            print $3;
            exit;
        }
    }' ${ENVFILE}
}
#function get NLS_LANG
getNLS_LANG(){
    awk -F, -v svr=${SERVER} -v ins=${INSTANCE} ' !/^#/ {
        if ( $1 == svr && $2 == ins ) {
            print $4;
            exit;
        }
    }' ${ENVFILE}
}
#function get Honban or QA
getHonQa(){
    awk -F, -v svr=${SERVER} -v ins=${INSTANCE} ' !/^#/ {
        if ( $1 == svr && $2 == ins ) {
            print $5;
            exit;
        }
    }' ${ENVFILE}
}

#user check
if [ "`id $4`" = "" ]; then
  echo "error:user not exists" 2>&1
  exit 1
fi
#get DB string
DB_STRING=`getDBString $1 $3`
echo "DB_STR:${DB_STRING}" >> /workhome/itcc/work/logs/param_test.log
if [ "${DB_STRING}" = "" ]; then
 echo "error:host name or DB instance" 2>&1
 exit 1
fi
#get NLS_LANG
NLS_LANG=`getNLS_LANG $1 $3`
if [ "${NLS_LANG}" = "" ]; then
 echo "error:host name or DB instance" 2>&1
 exit 1
fi
#get Honban or QA
HON_QA=`getHonQa $1 $3`
if [ "${HON_QA}" = "" ]; then
 echo "error:host name or DB instance" 2>&1
 exit 1
fi

SQLDIR=${SQLQDIR}
if [ "${HON_QA}" = "H" ]; then
  SQLDIR=${SQLHDIR}
fi
echo "sqlfile:"${SQLDIR}/$2 >> /workhome/itcc/work/logs/param_test.log
#sql file check
if [ ! -f ${SQLDIR}/$2 ]; then
  echo "error:SQL file not exists" 2>&1
  exit 1
fi

#directory check
if [ ! -d $5 ]; then
  echo "error:directory not exists" 2>&1
  exit 1
fi

#home directory file delete
#for i in `ls`
#do
#  if [ ! -d $i ]; then
#   # sudo /bin/rm $i
#   echo $i >> /workhome/itcc/work/logs/old_del_test.log
#  fi
#done

if [ "${LANGNAME}" = "ja_JP.sjis" ]; then
  CHNGLANG="-s"
elif [ "${LANGNAME}" = "ja_JP.eucjp" ]; then
  CHNGLANG="-e"
else
  CHNGLANG="-w"
fi

#call sql_select_exe
#${SHDIR}/sql_select_exe ${SQLDIR}/$2 ${DB_STRING} ${NLS_LANG}

#OUTLOGDIR=`echo $2|tr -d '/'`_`date '+%Y%m%d%H%M%S'`.log

#${2}:[②作業実行日]/[②X-POINTの番号_SQLファイル]
sql_log_name_2=sql_select_`echo  ${2} | cut -d '/' -f4 | cut -d '_' -f1`_2.log
OUTLOGDIR=${TEMP_PATH}/${sql_log_name_2}
sudo -u $OPUSER sh -c "sh ${SHDIR}/sql_select_exe ${SQLDIR}/$2 ${DB_STRING} ${NLS_LANG} > ${OUTLOGDIR}"
echo '--------------------------------------------------'
nkf ${CHNGLANG} ${OUTLOGDIR} | grep '^ORA\-[0123456789][0123456789][0123456789][0123456789][0123456789]'
echo '--------------------------------------------------'

#if [ "$6" = "-z" ]; then
#    for i in `ls`
#    do
#      echo "-Z file" >> /workhome/itcc/work/logs/param_test.log
#      if [ ! -d $i ]; then
#        if [ ! -f $5/$i.zip ]; then
#          sudo /usr/bin/zip $i.zip $i
#          sudo /bin/chown $4 $i.zip
#          sudo /bin/mv $i.zip $5
#          sudo /bin/rm $i
#          ls -l $5/$i.zip
#        else
#          echo "error:$i.zip exists in $5" 2>&1
#          sudo /bin/rm $i
#        fi
#      fi
#    done
#else
#    for i in `ls`
#    do
#      echo "Not -Z file" >> /workhome/itcc/work/logs/param_test.log
#      if [ ! -d $i ]; then
#        if [ ! -f $5/$i ]; then
#          sudo /bin/chown $4 $i
#          sudo /bin/mv -i $i $5
#          ls -l $5/$i
#        else
#          echo "error:$i exists in $5" 2>&1
#          sudo /bin/rm $i
#        fi
#      fi
#    done
#fi

