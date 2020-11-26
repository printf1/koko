#!/bin/bash
#$1:jobId
#$2:ticketNumber
#$3:token-success
#$4:token-failed
#$6:[①対象サーバ名],[②作業実行日(YYMMDD)]/[②X-POINTの番号(3桁以上)_SQLファイル],
#   [③DBインスタンス名/③DBユーザ名],[④問い合わせ結果格納ユーザ名],
#   [⑤問い合わせ結果格納先ファイルフルパス( /ファイル名 を含まない)],[⑥圧縮オプション],[⑦申請領域]
#$5:job_token

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
echo $# >> /workhome/itcc/work/logs/param_test.log
echo $2 >> /workhome/itcc/work/logs/param_test.log
echo $3 >> /workhome/itcc/work/logs/param_test.log
echo $4 >> /workhome/itcc/work/logs/param_test.log
echo $5 >> /workhome/itcc/work/logs/param_test.log
echo $par >> /workhome/itcc/work/logs/param_test.log
echo "第六个"$6 >> /workhome/itcc/work/logs/param_test.log
echo "第七个"$7 >> /workhome/itcc/work/logs/param_test.log



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

#run sql_select.sh by current idle user and input execution result into log file.
idleuser=${arr[0]}
echo ${idleuser} > /workhome/itcc/work/logs/param_test.log
echo ${OLD_SHELL_PATH} >> /workhome/itcc/work/logs/param_test.log
echo ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]} >> /workhome/itcc/work/logs/param_test.log
echo ${sql_log_name_1} >> /workhome/itcc/work/logs/param_test.log
#sudo -u $idleuser sh ${OLD_SHELL_PATH}/sql_select.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${idleuser} ${arr[5]} > ${sql_log_name_1} 2>&1

#echo `whoami` >> /workhome/itcc/work/logs/user_test.log
sh ${OLD_SHELL_CALL_PATH}/${$idleuser}/sql_select.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]} > ${sql_log_name_1} 2>&1
err=$?
echo $err >> /workhome/itcc/work/logs/old_shell.log
if [ $err -ne 0 ];then
  echo "error_call_sql" >> /workhome/itcc/work/logs/old_shell.log
  sh $SHELL_DIR/curl_atr.sh $1 $5 "failed" 'false'
  exit 1
fi

outlog_func I "sql_log_name_1=${sql_log_name_1}" 
outlog_func I "sql_log_name_2=${sql_log_name_2}"

#出力ファイルlog
db_select_log_analiz ${sql_log_name_1} ${sql_log_name_2} ${arr[4]}
result=$?
echo $result

#実行結果より、ATRに送信します。
if [ $result -eq 0 ];then  
  #No errors.
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
