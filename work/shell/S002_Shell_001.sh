#!/bin/bash
#$1:jobId
#$2:ticketNumber
#$3:token-success
#$4:token-failed
#$6:[①対象サーバ名],[②作業実行日(YYMMDD)]/[②X-POINTの番号_SQLファイル],
#   [③DBインスタンス名/③DBユーザ名],[④コミット/ロールバックオプション]：-r/-rc/-commit
#   [⑤申請領域],[⑥正常時更新件数]
#$5:job_token

#共通ファイルを取り込みます
par=`echo ${@:6}`
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
echo "S002_Start" > /workhome/itcc/work/logs/S2.log
if [ ! -f ${_exec_ksh} ]
then
  echo "環境設定ファイルが存在しません"
  sh $SHELL_DIR/curl_atr.sh $1 $5 'false' "環境設定ファイルが存在しません" "想定外のエラーが発生したため、自動化基盤の状況及びデータの確認をお願いします。"
  exit 1
fi
. ${_exec_ksh}

if [ ! -f ${SHELL_DIR}/BATCH_COMMON_FUNC.sh ]
then
  echo "共通関数ファイルが存在しません"
  sh $SHELL_DIR/curl_atr.sh $1 $5 false "共通関数ファイルが存在しません" "想定外のエラーが発生したため、自動化基盤の状況及びデータの確認をお願いします。"
  exit 1
fi
. ${SHELL_DIR}/BATCH_COMMON_FUNC.sh

#実行ファイルの名前を取得します。
myname=`basename $0`

#開始ログ
outlog_func I "${myname} is start"

#パラメータの数をチェックします。
if [ $# -lt 6 ]
then
  #echo "Argument is not input correctly."
  #echo "Usage：$0 <SQL file(path\filename)> <job_id> <job_token> <s_token> <f_token> <applyEnv> <applynumber>"
  outlog_func E "Argument is not input correctly."
  outlog_func E "Usage：$0 <jobId> <ticketNumber> <token-success> <token-failed> <info> <job_token>"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $5 $4 "Usage：$0 <jobId> <ticketNumber> <token-success> <token-failed> <info> <job_token>"
  sh $SHELL_DIR/curl_atr.sh $1 $5 false "フォーマットエラー" "想定外のエラーが発生したため、自動化基盤の状況及びデータの確認をお願いします。"
  outlog_func I "正常終了: date '+%Y-%m-%d %H:%M:%S'"
  exit 2
fi

#申請領域を取得し、それより、環境の文字コードを設定します。
OLD_IFS="$IFS"
IFS="," 
arr=($par)
IFS="$OLD_IFS"
langset_func ${arr[4]}

#ユーザリストを取得します。
u=${USERS_LIST_PATH}/users.list
#ファイルが存在しない場合、エラーメセッジを出力し終了します。
if [ ! -e $u ]
then
  outlog_func E "File $u doesn't exist!"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $5 $4 "File $u doesn't exist!"
  sh $SHELL_DIR/curl_atr.sh $1 $5 false "ファイル${u}存在ない" "想定外のエラーが発生したため、自動化基盤の状況及びデータの確認をお願いします。"
  exit 2
fi
#ファイルに何もない場合、エラーメセッジを出力し終了します。
temp=`sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u`
if [ `sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u |wc -l` -eq 0 ]
then
  outlog_func E "File $u is empty!"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $5 $4 "File $u is empty!"
  sh $SHELL_DIR/curl_atr.sh $1 $5 false "ファイル${u}空き" "想定外のエラーが発生したため、自動化基盤の状況及びデータの確認をお願いします。"
  exit 2
fi

#利用していないユーザを取得します。
outlog_func I "get idleuser start."
idleuser=""
while [ "$idleuser" == "" ]
do
  for line in $temp
  do
    #check running process belong to current user($line)
    existCount=`ps -eo user | grep -cw $line`
    if [ $existCount == 0 ]; then    
      #find out an idle user, and run sql_update.sh
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
    #wait 60s
    sleep 60
  else
    break
  fi
done

#更新処理を実行します。
outlog_func I "db update start."
#②作業実行日(YYMMDD)]/[②X-POINTの番号_SQLファイル
sql_log_name_1=${TEMP_PATH}/sql_update_`echo ${arr[1]} | cut -d '/' -f2 | cut -d '_' -f1`_1.log
sql_log_name_2=${TEMP_PATH}/sql_update_`echo ${arr[1]} | cut -d '/' -f2 | cut -d '_' -f1`_2.log
outlog_func I "sql_log_name_1=${sql_log_name_1}" 
outlog_func I "sql_log_name_2=${sql_log_name_2}" 

#if [ ! -f $sql_log_name_1 ];then
#  touch $sql_log_name_1
#  chmod 777 $sql_log_name_1
#fi
#if [ ! -f $sql_log_name_2 ];then
#  touch $sql_log_name_2
#  chmod 777 $sql_log_name_2

# -r -rc -commit ""
db_pattern=${arr[3]}
if [ x"${db_pattern}" = x ]; then
  db_pattern="-commit"
fi

if [ ${db_pattern} = "-rc" ]; then
  #sudo -u $idleuser sh ${OLD_SHELL_PATH}/sql_update.sh ${arr[0]} ${arr[1]} ${arr[2]} -r > ${sql_log_name_1}
  #sh ${OLD_SHELL_PATH}/sql_update.sh ${arr[0]} ${arr[1]} ${arr[2]} "-r" > ${sql_log_name_1}
   echo "DB_Pattern -rc" >> /workhome/itcc/work/logs/S2.log
  /usr/bin/expect <<EOF
     set timeout 8
     spawn ssh ${idleuser}@143.94.48.157
     expect "password:"
     send "${idleuser}\n"
     expect "#"
     send "sh /workhome/itcc/work/shell/S002_Shell_Transfer.sh ${idleuser} $1 $5 ${arr[0]} ${arr[1]} ${arr[2]} -r\n"
     expect eof
EOF
  #db_log_analiz ${sql_log_name_1} ${sql_log_name_2} "${arr[4]}" "-r"
  #result=$?
  if [ $result -eq 0 ];then
    echo "DB_Patern -commit" >> /workhome/itcc/work/logs/S2.log
    #sudo -u $idleuser sh ${OLD_SHELL_PATH}/sql_update.sh ${arr[0]} ${arr[1]} ${arr[2]} -commit  > ${sql_log_name_1}
    #sh ${OLD_SHELL_PATH}/sql_update.sh ${arr[0]} ${arr[1]} ${arr[2]} "-commit"  > ${sql_log_name_1}
    /usr/bin/expect <<EOF
     set timeout 8
     spawn ssh ${idleuser}@143.94.48.157
     expect "password:"
     send "${idleuser}\n"
     expect "#"
     send "sh /workhome/itcc/work/shell/S002_Shell_Transfer.sh ${idleuser} $1 $5 ${arr[0]} ${arr[1]} ${arr[2]} -commit\n"
     expect eof
EOF
    #db_log_analiz ${sql_log_name_1} ${sql_log_name_2} "${arr[4]}" "-commit"
    #result=$?
  fi
else
   echo "DB_Pattern -x" >> /workhome/itcc/work/logs/S2.log
  #sudo -u $idleuser sh ${OLD_SHELL_PATH}/sql_update.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} > ${sql_log_name_1}
  #sh ${OLD_SHELL_PATH}/sql_update.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} > ${sql_log_name_1}
  /usr/bin/expect <<EOF
     set timeout 8
     spawn ssh ${idleuser}@143.94.48.157
     expect "password:"
     send "${idleuser}\n"
     expect "#"
     send "sh /workhome/itcc/work/shell/S002_Shell_Transfer.sh ${idleuser} $1 $5 ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]}\n"
     expect eof
EOF
  #db_log_analiz ${sql_log_name_1} ${sql_log_name_2} "${arr[4]}" ${db_pattern}
  #result=$?
fi 

#実行結果より、ATRに送信します。
#if [ $result = 0 ];then
#  #No errors.
#  echo "sql_update.sh executed successfully!"
#  outlog_func I "sql update executed successfully!"
#  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $5 $3 "sql update executed successfully!"
#  sh $SHELL_DIR/curl_atr.sh $1 $5 true success
#  outlog_func I "${myname} is end"
#  exit 0
#else
#  #errors occur.
#  outlog_func E "Error occurs, while running sql_update.sh!"
#  if [ $result = 1 ];then
#    #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $5 $4 "`cat ${sql_log_name_1}`"
#    #sh $SHELL_DIR/curl_atr.sh $1 $5 false "`cat ${sql_log_name_1}`"
#    sh $SHELL_DIR/curl_atr.sh $1 $5 false failed
#  else
#    #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $5 $4 "`cat ${sql_log_name_2}`"
#    #sh $SHELL_DIR/curl_atr.sh $1 $5 false "`cat ${sql_log_name_2}`"
##    sh $SHELL_DIR/curl_atr.sh $1 $5 false failed
#  fi
#  outlog_func I "${myname} is end"
#  exit 1
#fi
