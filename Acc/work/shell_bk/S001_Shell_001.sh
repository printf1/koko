#!/bin/bash
#$1:jobId
#$2:ticketNumber
#$3:token-success
#$4:token-failed
#$6:[①対象サーバ名],[②作業実行日(YYMMDD)]/[②X-POINTの番号(3桁以上)_SQLファイル],
#   [③DBインスタンス名/③DBユーザ名],[④問い合わせ結果格納ユーザ名],
#   [⑤問い合わせ結果格納先ファイルフルパス( /ファイル名 を含まない)],[⑥圧縮オプション],[⑦申請領域]
#$5:job_token

par=`echo ${@:6}`
echo "sig_1" >> /workhome/itcc/work/logs/param_test.log
chmod 777 /workhome/itcc/work/logs/param_test.log
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
if [ ! -f ${_exec_ksh} ]
then
  echo "環境設定ファイルが存在しません"
  sh $SHELL_DIR/curl_atr.sh $1 $5 "failed" 'false'
  exit 1
fi
. ${_exec_ksh}

if [ ! -f ${SHELL_DIR}/BATCH_COMMON_FUNC.sh ]
then
  echo "共通関数ファイルが存在しません"
  sh $SHELL_DIR/curl_atr.sh $1 $5 "failed" 'false'
  exit 1
fi
. ${SHELL_DIR}/BATCH_COMMON_FUNC.sh

#実行ファイルの名前を取得します。
myname=`basename $0`

#開始ログ
outlog_func I "${myname} is start"

echo "参数个数"$# >> /workhome/itcc/work/logs/param_test.log
#パラメータの数をチェックします。
echo $1 >> /workhome/itcc/work/logs/param_test.log
echo $2 >> /workhome/itcc/work/logs/param_test.log
echo $3 >> /workhome/itcc/work/logs/param_test.log
echo $4 >> /workhome/itcc/work/logs/param_test.log
echo $5 >> /workhome/itcc/work/logs/param_test.log
echo $par >> /workhome/itcc/work/logs/param_test.log
echo "第六个"$6 >> /workhome/itcc/work/logs/param_test.log
echo "第七个"$7 >> /workhome/itcc/work/logs/param_test.log
if [ $# -le 6 ]
then
  outlog_func E "Argument is not input correctly."
  outlog_func E "Usage：$0 <jobId> <ticketNumber> <token-success> <token-failed> <info> <job_token>"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "Usage：$0 <jobId> <ticketNumber> <token-success> <token-failed> <info> <job_token>"
  sh $SHELL_DIR/curl_atr.sh $1 $5 "failed" 'false'
  exit 2
fi

#申請領域を取得し、それより、環境の文字コードを設定します。
OLD_IFS="$IFS"
IFS="," 
arr=($par)
IFS="$OLD_IFS"

#申請領域がEP又はEP海外の場合
langset_func ${arr[6]}

#outlog_func I "環境変数 LANG="$LANG
#outlog_func I "環境変数 NLS_LANG="$NLS_LANG

#ユーザリストを取得します。
u=${USERS_LIST_PATH}/users.list
#ファイルが存在しない場合、エラーメセッジを出力し終了します。
if [ ! -e $u ]
then
  outlog_func E "File $u doesn't exist!"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "File $u doesn't exist!"
  sh $SHELL_DIR/curl_atr.sh $1 $5 "failed" 'false'
  exit 2
fi

#ファイルに何もない場合、エラーメセッジを出力し終了します。
temp=`sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u`
if [ `sed -e '/^$/d'  $u | sed '/^#.*\|^$/d' $u |wc -l` -eq 0 ]
then
  outlog_func E "File $u is empty!"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "File $u is empty!"
  sh $SHELL_DIR/curl_atr.sh $1 $5 "Failed" 'false'
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

#抽出処理を実行します。
outlog_func I "db select start."
#${arr[1]}:[②作業実行日(YYMMDD)]/[②X-POINTの番号(3桁以上)_SQLファイル]
sql_log_name_1=${TEMP_PATH}/sql_select_`echo ${arr[1]} | cut -d '/' -f2 | cut -d '_' -f1`_1.log
sql_log_name_2=${TEMP_PATH}/sql_select_`echo ${arr[1]} | cut -d '/' -f2 | cut -d '_' -f1`_2.log
if [! -f $sql_log_name_1 ];then
  touch $sql_log_name_1 chmod 777 $sql_log_name_1
fi
if [! -f $sql_log_name_2 ];then
  touch $sql_log_name_2 chmod 777 $sql_log_name_2
fi
#cp -r /workhome/itcc/work/old_shell ${OLD_SHELL}
echo ${idleuser}"old_trans"${OLD_SHELL} >> /workhome/itcc/work/logs/old_shell.log
echo $OLD_SHELL_CALL_PATH >> /workhome/itcc/work/logs/old_shell.log
chmod 777 /workhome/itcc/work/logs/old_shell.log
#run sql_select.sh by current idle user and input execution result into log file.
#sudo -u op9801 sh ${OLD_SHELL_PATH}/sql_select.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]} > ${sql_log_name_1}
echo ${idleuser} > /workhome/itcc/work/logs/param_test.log
echo ${OLD_SHELL_PATH} >> /workhome/itcc/work/logs/param_test.log
echo ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]} >> /workhome/itcc/work/logs/param_test.log
echo ${sql_log_name_1} >> /workhome/itcc/work/logs/param_test.log
#sudo -u $idleuser sh ${OLD_SHELL_PATH}/sql_select.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${idleuser} ${arr[5]} > ${sql_log_name_1} 2>&1
#cp -r /workhome/itcc/work/old_shell $OLD_SHELL_CALL_PATH/${$idleuser}
/usr/bin/expect <<EOF
   spawn ssh ${idleuser}@143.94.48.157
    expect "#"
    send "cp /worohome/itcc/work/old_shell/sql_select.sh /workhome/home/workusers/${idleuser}\n"
    expect "#"
    send "sh ${OLD_SHELL_PATH}/${$idleuser}/sql.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]} > ${sql_log_name_1}"
    expect eof
EOF 
#echo `whoami` > /workhome/itcc/work/logs/user_test.log
#ssh -t -t $idleuser@143.94.48.157 >> /workhome/itcc/work/logs/user_test.log 2>&1 
#echo `whoami` >> /workhome/itcc/work/logs/user_test.log
#sh ${OLD_SHELL_CALL_PATH}/${$idleuser}/sql_select.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]} > ${sql_log_name_1} 2>&1

err=$?
echo $err >> /workhome/itcc/work/logs/old_shell.log
if [ $err -ne 0 ];then
  echo "error_call_sql" >> /workhome/itcc/work/logs/old_shell.log
  sh $SHELL_DIR/curl_atr.sh $1 $5 "failed" 'false'
  exit
fi
echo "sig_7" >> /workhome/itcc/work/logs/param_test.log
outlog_func I "sql_log_name_1=${sql_log_name_1}" 
outlog_func I "sql_log_name_2=${sql_log_name_2}"

#出力ファイルlog
db_select_log_analiz ${sql_log_name_1} ${sql_log_name_2} ${arr[4]}
result=$?
echo $result
echo "sig_8" >> /workhome/itcc/work/logs/param_test.log
#実行結果より、ATRに送信します。
if [ $result -eq 0 ];then  
  #No errors.
  echo "sig_9" >> /workhome/itcc/work/logs/param_test.log
  echo "sql_select.sh executed successfully!"
  outlog_func I "sql_select.sh executed successfully!"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3 "sql select executed successfully!"
  sh $SHELL_DIR/curl_atr.sh $1 $5 "success" 'true'
  outlog_func I "${myname} is end"
  exit 0  
else
  echo "sig_10" >> /workhome/itcc/work/logs/param_test.log
  #errors occur.
  echo "Error occurs, while running sql_select.sh!"
  outlog_func E "Error occurs, while running sql_select.sh!"
  if [ $result = 1 ];then
   #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "`cat ${sql_log_name_1}`"
   sh $SHELL_DIR/curl_atr.sh $1 $5 "failed" 'false'
  else
   #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "`cat ${sql_log_name_2}`"
   sh $SHELL_DIR/curl_atr.sh $1 $5 "failed" 'false'
  fi
  outlog_func I "${myname} is end"
  exit 1
fi