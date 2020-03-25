#!/bin/bash
#$1:jobId
#$2:ticketNumber
#$3:token-success
#$4:token-failed
#$5:処理予測時間 (HH:MM)
#$6:job_token
#$7:applynumber 申請番号
#$8:申請領域
pra=`echo ${@:8}`
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
if [ ! -f ${_exec_ksh} ]
then
  echo "環境設定ファイルが存在しません"
  sh $SHELL_DIR/curl_atr.sh $1 $6 'false' "環境設定ファイルが存在しません"
  outlog_func I "環境設定ファイルが存在しません"
  exit 1
fi
. ${_exec_ksh}

if [ ! -f ${SHELL_DIR}/BATCH_COMMON_FUNC.sh ]
then
  echo "共通関数ファイルが存在しません"
  sh $SHELL_DIR/curl_atr.sh $1 $6 'false' "共通関数ファイルが存在しません"
  outlog_func I "共通関数ファイルが存在しません"
  exit 1
fi
. ${SHELL_DIR}/BATCH_COMMON_FUNC.sh

myname=`basename $0`

outlog_func I "${myname} is start."

#debug param
debug_file='/workhome/itcc/work/logs/monitor_debug.log'
echo "paramenter count:$#" > ${debug_file}
echo "$1" >> ${debug_file}
echo "$2" >> ${debug_file}
echo "$3" >> ${debug_file}
echo "$4" >> ${debug_file}
echo "$5" >> ${debug_file}
echo "$6" >> ${debug_file}
echo "$7" >> ${debug_file}
echo "$8" >> ${debug_file}
#debug end

#パラメータの数をチェックします。
if [ $# -lt 8 ]
then
  outlog_func E "Argument is not input correctly."
  outlog_func E "Usage：$0 <jobId> <ticketNumber> <token-success> <token-failed> <処理予測時間> <job_token> <申請番号> <申請領域>"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "Usage：$0 <jobId> <ticketNumber> <token-success> <token-failed> <処理予測時間> <job_token> <申請番号> <申請領域>"
  sh $SHELL_DIR/curl_atr.sh $1 $6 'false' "Argument is not input correctly."
  exit 2
fi

#申請領域がEP又はEP海外の場合
langset_func $pra

#outlog_func I "環境変数 LANG="$LANG
#outlog_func I "環境変数 NLS_LANG="$NLS_LANG


#処理予測時間＋１０分まで　１０分
add_time=10

u=${USERS_LIST_PATH}/users.list

if [ ! -e $u ]
then
  outlog_func E "File $u doesn't exist!"
  #${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "File $u doesn't exist!"
  sh $SHELL_DIR/curl_atr.sh $1 $6 'false' "File $u doesn't exist!"
  exit 2
fi

temp=`sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u`
if [ `sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u |wc -l` -eq 0 ]
then
  outlog_func E "File $u is empty!"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "File $u is empty!"
  sh $SHELL_DIR/curl_atr.sh $1 $6 'false' "File $u is empty!"
  exit 2
fi

sleep 10
monitoring_log_file1=${TEMP_PATH}/sql_select_${7}_1.log
echo "monitoring_log_file1:${monitoring_log_file1}" >> ${debug_file}
pid=""
while true
do
  if [ -e ${monitoring_log_file1} ]; then
    pid=`ps -ef |grep -e "S001_Shell_001\.sh.*${2}"|head -1|awk '{print $2}'`
    echo "monitoring pid:${pid}" >> ${debug_file}
    tmp=`cat ${monitoring_log_file1} | grep -w 'Process No. is ' | awk -F 'Process No. is ' '{print $2}'`
    if [ -n "$tmp" -a  -n "$pid" ]; then
       sel_pre_pid2=${tmp:1:${#tmp}-3}
       echo "sel_pre_pid2:${sel_pre_pid2}" >> ${debug_file}
       #1. find out sel_pre_pid2:process of sql_select_pre.sh   {pid} :process of S001_Shell_001.sh
       outlog_func D "process of sql_select_pre.sh:${sel_pre_pid2}     process of S001_Shell_001.sh:$pid" 
       break
    else
       #tmpが空、log1が出てきたが、プロセルがまだ　Process No. is　に到達しない
       #shell_001がまだ走っているかを確認
       pid_c=`ps -ef |grep -e "S001_Shell_001\.sh.*${2}"| grep -v grep |awk '{print $2}'`
       echo "pic_c:${pid_c}" >> ${debug_file}
       if [ -n "${pid_c}" ]; then
        #S001_Shell_001.shがまだ走って,終了しない　正常続け
        outlog_func D "process of S001_Shell_001.sh:${pid_c}" 
        outlog_func D "wait 30s, and recheck process of S001_Shell_001.sh."
        sleep 10
       else
        #S001_Shell_001.shが異常終了. log1が出てきたが、プロセルがまだ　Process No. is　に到達しない
        #sql_select.sh,S001_Shell_001.sh running ends, doesn't exist any more.
        outlog_func E "S001_Shell_001.sh error occurs, process of S001_Shell_001.sh doesn't exist any more."
        #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3 "process execute success"
        sh $SHELL_DIR/curl_atr.sh $1 $6 'false' "S001_Shell_001.sh error occurs"
        outlog_func I "${myname} is end."
        exit 0
       fi
    fi
  else
    #log1がまだ新規作成しない場合、shell_001がアイドルユーザを見つけ続ける時 loop
    echo "moniter file not exist sleep 10s" >> ${debug_file} 
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

while [[ $currentTimeSecs -le $limitEndTimeSecs ]]
do
  #while it doesn't reach the time of 「処理予測時間＋１０分まで」
  #process of sql_select_pre.sh    pidではない
  selectPSCnt=`ps -eo user,pid,comm,lstart| grep -cw ${sel_pre_pid2}`
  if [ $selectPSCnt -eq 0 ] ; then
    #process of S001_Shell_001.sh doesn't exist any more.
    outlog_func I "process of S001_Shell_001'sql_select_pre.sh doesn't exist any more."
    outlog_func I "${sel_pre_pid2} is over."
    #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3 "process execute success"
    sh $SHELL_DIR/curl_atr.sh $1 $6 'true' "Successful"
    outlog_func I "${myname} is end."
    exit 0
  else
    #wait 60s, and recheck process of S001_Shell_001.sh
    outlog_func D "wait 60s, and recheck process of S001_Shell_001.sh every 1minute."
    sleep 60
    currentTime=`date '+%Y-%m-%d %H:%M:%S'`
    #Seconds of current time
    currentTimeSecs=`date -d "$currentTime" +%s`	 
  fi
done

##process of sql_select_pre.sh is still running, after time reach 「処理予測時間＋１０分まで」.
##  To do:
##1.find out an idle user
outlog_func I "get idleuser start."
idleuser=""
while [ "$idleuser" == "" ]
do
  for line in $temp
  do
    #check running process belong to current user($line)
    existCount=`ps -eo user | grep -cw $line`
    if [ $existCount -eq 0 ]; then    
      #find out an idle user
      idleuser=$line
      echo "Find out an idle user: $idleuser"
      outlog_func D "Find out an idle user: $idleuser"
      break
    fi
  done
  
  #no idle user is available.
  if [ "$idleuser" == "" ];then
    echo "No idle user now!"
    outlog_func D "No idle user now!"
    #wait    
    sleep 60
  else
    break
  fi
done

##2.kill process of the {pid} 
pid_rs=`ps -ef |grep -e "S001_Shell_001\.sh.*${2}"| grep -v grep |awk '{print $2}'`
if [ -n "${pid_rs}" ]; then 
  #execRst=`sudo -u $idleuser sh ${OLD_SHELL_PATH}/sql_kill_process.sh ${pid_rs}`
  execRst=`su - $idleuser ${OLD_SHELL_PATH}/sql_kill_process.sh ${pid_rs}`
  #kill -9 ${pid_rs}
   
  if [ $? -eq 0 ]; then
    outlog_func I "${pid_rs} is killed"
    #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3 "$execRst"
    sh $SHELL_DIR/curl_atr.sh $1 $6 'false' "process_killed"
  else
    outlog_func E "${pid_rs} is killed error"
    #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "$execRst"
    sh $SHELL_DIR/curl_atr.sh $1 $6 'false' "process_killed_error"
  fi

else
  #process of S001_Shell_001.sh doesn't exist any more.
  outlog_func I "process of S001_Shell_001.sh doesn't exist any more."
  outlog_func I "Although the timeout,process of S001_Shell_001.sh is over."
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3 "process execute success"
  sh $SHELL_DIR/curl_atr.sh $1 $6 'true' "Successful"
  outlog_func I "${myname} is end."
  exit 0
fi

sleep 10
outlog_func I "${myname} is end."
exit 0
