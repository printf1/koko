#!/bin/bash
#$1:jobId
#$2:ticketNumber
#$3:token-success
#$4:token-failed
#$5:処理予測時間
#$6:job_token
#$7:applynumber 申請番号
#$8:申請領域
#c_time=`date '+%Y-%m-%d %H:%M:%S'`
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
if [ ! -f ${_exec_ksh} ]
then
  echo "環境設定ファイルが存在しません"
  exit 1
fi
. ${_exec_ksh}

if [ ! -f ${SHELL_DIR}/BATCH_COMMON_FUNC.sh ]
then
  echo "共通関数ファイルが存在しません"
  exit 1
fi
. ${SHELL_DIR}/BATCH_COMMON_FUNC.sh
#SHDIR="/workhome/scripts/cdcadmin"
#SHDIR="${HOME}/cdcadmin"

myname=`basename $0`
outlog_func I "${myname} is start."

#パラメータの数をチェックします。
if [ $# != 8 ]
then
  #echo "Argument is not input correctly."
  #echo "Usage：$0 <SQL file(path\filename)> <job_id> <job_token> <s_token> <f_token> <applyEnv> <applynumber>"
  outlog_func E "Argument is not input correctly."
  outlog_func E "Usage：$0 <jobId> <ticketNumber> <token-success> <token-failed> <処理予測時間> <job_token> <申請番号> <申請領域>"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "Usage：$0 <jobId> <ticketNumber> <token-success> <token-failed> <処理予測時間> <job_token> <申請番号> <申請領域>"
  $SHELL_DIR/curl_atr.sh $1 $6 "Usage：$0 <jobId> <ticketNumber> <token-success> <token-failed> <処理予測時間> <job_token> <申請番号> <申請領域>"
  outlog_func E "正常終了: date '+%Y-%m-%d %H:%M:%S'"
  exit 2
fi

#申請領域がEP又はEP海外の場合
langset_func $8
add_time=10
u=${USERS_LIST_PATH}/users.list

if [ ! -e $u ]
then
  outlog_func E "File $u doesn't exist!"
  #${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "File $u doesn't exist!"
  $SHELL_DIR/curl_atr.sh $1 $6 "File $u doesn't exist!"
  exit 2
fi
temp=`sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u`
if [ `sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u |wc -l` -eq 0 ]
then
  outlog_func E "File $u is empty!"
  #${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "File $u is empty!"
  $SHELL_DIR/curl_atr.sh $1 $6 "File $u is empty!"
  exit 2
fi

sleep 10
#monitoring_log_file1=${TEMP_PATH}/sql_update_${7}_1.log
#while true
#do
# if [ -e ${monitoring_log_file} ]; then
#   pid=`cat ${monitoring_log_file} | grep -w 'Process No. is ' | head -1 | awk -F 'Process No. is ' '{print $2}'`
#   if [ ${pid}="" ]; then
#     sleep 10
#   else
#     break
#   fi
# else
#     sleep 10
# fi
#done

monitoring_log_file1=${TEMP_PATH}/sql_update_${7}_1.log
pid=""
while true
do
  if [ -e ${monitoring_log_file1} ]; then
    tmp=`cat ${monitoring_log_file1} | grep -w 'Process No. is ' | awk -F 'Process No. is ' '{print $2}'`
    pid=`ps -ef |grep -e "S002_Shell_001\.sh.*${2}" | grep -v grep |head -1|awk '{print $2}'`
    #if [ -n "$tmp" ]; then
    if [ -n "$tmp" -a "${pid}" ]; then    
       #1. find out the {pid} from log file 
       #pid=${tmp:1:${#tmp}-3}
       outlog_func I "db process start pid=${pid}"
       break
    else
       #tmpが空、log1が出てきたが、プロセルがまだ　Process No. is　に到達しない
       #shell_001がまだ走っているかを確認
       ps -ef| grep -e "S002_Shell_001\.sh.*${2}" |  grep -v grep
       if [ $? -eq 0 ]; then
         #S002_Shell_001.shがまだ走って,終了しない　正常続け
         sleep 10
       else
         #S002_Shell_001.shが異常終了. log1が出てきたが、プロセルがまだ　Process No. is　に到達しない
         #sql_select.sh,S001_Shell_001.sh running ends, doesn't exist any more.
         #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3 "process execute success"
         $SHELL_DIR/curl_atr.sh $1 $6 "process execute success"
		 outlog_func I "${myname} is end."
         exit 0
       fi
    fi
  else
    #log1がまだ新規作成しない場合、shell_001がアイドルユーザを見つけ続ける時 loop
    sleep 10
  fi
done

#Start time of shell execution
startTime=`date '+%Y-%m-%d %H:%M:%S'`

#Seconds of Start time
startTimeSecs=`date -d "$startTime" +%s`

hr=`echo $5 | awk -F ':' '{print $1}'`
mm=`echo $5 | awk -F ':' '{print $2}'`

#Seconds of 「処理予測時間＋１０分まで」
limitEndTimeSecs=$((startTimeSecs+hr*60*60+mm*60+${add_time}*60))

currentTime=`date '+%Y-%m-%d %H:%M:%S'`
#Seconds of current time
currentTimeSecs=`date -d "$currentTime" +%s`
outlog_func I "monitoring is start"

while [[ "$currentTimeSecs" -le "$limitEndTimeSecs" ]]
do
# while it doesn't reach the time of 「処理予測時間＋１０分まで」
#search the process of S002_Shell_001.sh by keyword : "S002_Shell_001.sh*{ticketNumber}"
  #sh001PSCnt = `ps -eo user,pid,comm,lstart| grep -cw 'S002_Shell_001\.sh.*{$2}'`
  sh001PSCnt=`ps -eo user,pid,comm,lstart| grep -cw ${pid}`
  if [ $sh001PSCnt -eq 0 ]; then  
    #process of S002_Shell_001.sh doesn't exist any more.
    outlog_func I "${pid} is over."
    #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3 "process execute success"
    $SHELL_DIR/curl_atr.sh $1 $6 "process execute success"
	outlog_func E "正常終了: date '+%Y-%m-%d %H:%M:%S'"
	outlog_func I "${myname} is end."
    exit 0
  else    
    #wait 60s, and recheck process of S002_Shell_001.sh
    sleep 60
    currentTime=`date '+%Y-%m-%d %H:%M:%S'`
    #Seconds of current time
    currentTimeSecs=`date -d "$currentTime" +%s`
  fi
done

##process of S002_Shell_001.sh is still running, after time reach 「処理予測時間＋１０分まで」.
##  To do:
##  1. find out the {pid} from log file of S002_Shell_001.sh
#tmp=`cat /tmp/S002_$2.log | grep -w 'Process No. is ' | awk -F 'Process No. is ' '{print $2}'`
#processno=${tmp:1:${#tmp}-3}
#processno=`ps -ef | grep 'S002_Shell_001\.sh.*{$2}' | head -1 | awk '{print $2}'` 
##  2. find out an idle user
idleuser=""
while [ x"$idleuser" = x"" ]
do
  for line in $temp
  do

    #check running process belong to current user($line)
    existCount=`ps -eo user | grep -cw $line`
    if [ $existCount -eq 0 ]; then    
      #find out an idle user, and run sql_select.sh
      idleuser=$line
      outlog_func I "Find out an idle user: $idleuser"
      break
    fi
  done
  
  #no idle user is available.
  if [ x"$idleuser" = x"" ];then
    echo "No idle user now!"    
    #wait 60s
    sleep 60
  else
    break
  fi
done


pid_rs=`ps -ef |grep -e "S002_Shell_001\.sh.*${2}"|grep -v grep|head -1|awk '{print $2}'`
if [ -n "${pid_rs}" ]; then 
  #temp_pid=`ps -ef | grep ${pid_rs} | grep -v grep | awk '{print $2}'`
  #for line in $temp_pid
  #do
  #	execRst=`su - $idleuser ${OLD_SHELL_PATH}/sql_kill_process.sh ${line}`
  #	if [ $? -eq 0 ]; then
  #		outlog_func I "${line} is killed"
  #	else
  #		outlog_func E "${line} is killed error"
  #		${PYTHON_PATH}/S001_Python_update_ticket.py $2 "failed\r"$execRst #$execRst
  #		${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4
  #		outlog_func I "${myname} is end."
  #		exit 1
  #	fi
  #done
  #${PYTHON_PATH}/S001_Python_update_ticket.py $2 "success" #$execRst
  #${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3
  #outlog_func I "${myname} is end."
  #exit 0  
  
  execRst=`su - $idleuser ${OLD_SHELL_PATH}/sql_kill_process.sh ${pid_rs}`
  #kill -9 ${pid_rs}
   
  if [ $? -eq 0 ]; then
    outlog_func I "${pid_rs} is killed"
    #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3 "$execRst"
    $SHELL_DIR/curl_atr.sh $1 $6 "$execRst"
  else
    outlog_func E "${pid_rs} is killed error"
    #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "$execRst"
	$SHELL_DIR/curl_atr.sh $1 $6 "$execRst"
  fi
else
  #process of S001_Shell_001.sh doesn't exist any more.
  outlog_func I "process of S002_Shell_001.sh doesn't exist any more."
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3 "process execute success"
  $SHELL_DIR/curl_atr.sh $1 $6 "process execute success"
  outlog_func I "正常終了: date '+%Y-%m-%d %H:%M:%S'"
  outlog_func I "${myname} is end."
  exit 0
fi
sleep 10
outlog_func I "${myname} is end."
exit 0
