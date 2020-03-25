#!/bin/bash
#$1:idleuser
#$2:job_id
#$3:job_token
#$4-5:[①対象サーバ名],[②作業実行日(YYMMDD)]/[②X-POINTの番号_SQLファイル],
#$6:[DBインスタンス名/③DBユーザ名]
#$7: -r -commit   

_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
echo "Transfer-start" >> /workhome/itcc/work/logs/S2.log
echo `pwd` >> /workhome/itcc/work/logs/S2.log
if [ ! -f ${_exec_ksh} ]
then
  echo "環境設定ファイルが存在しません"
  sh $SHELL_DIR/curl_atr.sh $2 $3 'false' "環境設定ファイルが存在しません" "想定外のエラーが発生したため、自動化基盤の状況及びデータの確認をお願いします。"
  exit 1
fi
. ${_exec_ksh}

if [ ! -f ${SHELL_DIR}/BATCH_COMMON_FUNC.sh ]
then
  echo "共通関数ファイルが存在しません"
  sh $SHELL_DIR/curl_atr.sh $2 $3 'false' "共通関数ファイルが存在しません" "想定外のエラーが発生したため、自動化基盤の状況及びデータの確認をお願いします。"
  exit 1
fi
. ${SHELL_DIR}/BATCH_COMMON_FUNC.sh

#実行ファイルの名前を取得します。
myname=`basename $0`

#SJIS>>UTF-8  File
simple="/workhome/itcc/work/temp/simple.log"

#開始ログ
outlog_func I "${myname} is start"

echo "参数个数"$# >> /workhome/itcc/work/logs/S2.log
#パラメータの数をチェックします。
echo "1:$1" >> /workhome/itcc/work/logs/S2.log
echo "2:$2" >> /workhome/itcc/work/logs/S2.log
echo "3:$3" >> /workhome/itcc/work/logs/S2.log

#抽出処理を実行します。
outlog_func I "db select start."
#${arr[1]}:[②作業実行日(YYMMDD)]/[②X-POINTの番号(3桁以上)_SQLファイル]
sql_log_name_1=${TEMP_PATH}/sql_update_`echo $5 | cut -d '/' -f2 | cut -d '_' -f1`_1.log
sql_log_name_2=${TEMP_PATH}/sql_update_`echo $5 | cut -d '/' -f2 | cut -d '_' -f1`_2.log
if [ ! -f $sql_log_name_1 ];then
  touch $sql_log_name_1
  chmod 777 $sql_log_name_1
fi
if [ ! -f $sql_log_name_2 ];then
  touch $sql_log_name_2
  chmod 777 $sql_log_name_2
fi
#cp -r /workhome/itcc/work/old_shell ${OLD_SHELL}

#run sql_select.sh by current idle user and input execution result into log file.
idleuser=$1
echo ${idleuser} >> /workhome/itcc/work/logs/S2.log
echo $4 $5 $6 $7 $8 $9 >> /workhome/itcc/work/logs/S2.log
echo ${sql_log_name_1} >> /workhome/itcc/work/logs/S2.log

#sudo -u $idleuser sh ${OLD_SHELL_PATH}/sql_select.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${idleuser} ${arr[5]} > ${sql_log_name_1} 2>&1
cp ${OLD_SHELL_PATH}/sql_update.sh ${OLD_SHELL_CALL_PATH}/${idleuser}/
#echo `whoami` >> /workhome/itcc/work/logs/user_test.log
#sh ${OLD_SHELL_CALL_PATH}/${$idleuser}/sql_select.sh ${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]} > ${sql_log_name_1} 2>&1
sh ${OLD_SHELL_CALL_PATH}/${idleuser}/sql_update.sh $4 $5 $6 $7 > ${sql_log_name_1} 2>&1
err=$?
echo "ErrorNumber in call SQL:$err" >> /workhome/itcc/work/logs/S2.log
#SJIS>>UTF-8 Transfer
iconv -f UTF-8 -t UTF-8 ${sql_log_name_1} -o ${simple}
log_str_01=`cat ${simple} |awk '{printf "%sENTER" , $0}'`
log_str_01=${log_str_01//" "/"SPACE"}
sudo /bin/rm ${simple}
echo "log_string1:$log_str_01" >> /workhome/itcc/work/logs/S2.log

if [ $err -ne 0 ];then
  echo "error_call_sql" >> /workhome/itcc/work/logs/S2.log
  sh $SHELL_DIR/curl_atr.sh $2 $3 'false' ${log_str_01} "想定外のエラーが発生したため、自動化基盤の状況及びデータの確認をお願いします。"
  exit 1
fi

outlog_func I "sql_log_name_1=${sql_log_name_1}"
outlog_func I "sql_log_name_2=${sql_log_name_2}"

#出力ファイルlog
db_select_log_analiz ${sql_log_name_1} ${sql_log_name_2} $6
result=$?
echo $result

iconv -f UTF-8 -t UTF-8 ${sql_log_name_2} -o ${simple}
log_str_02=`cat ${simple} |awk '{printf "%sENTER" , $0}'`
log_str_02=${log_str_02//" "/"SPACE"}
sudo /bin/rm ${simple}
echo "log_string:$log_str_02" >> /workhome/itcc/work/logs/S2.log

if [ $result -eq 0 ];then
  #No errors.
  #cp ${sql_log_name_2} $8/ >> /workhome/itcc/work/logs/S2.log 2>&1
  echo "sql_update.sh executed successfully!"
  outlog_func I "sql_update.sh executed successfully!"
  #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $3 "sql select executed successfully!"
  sh $SHELL_DIR/curl_atr.sh $2 $3 'true' ${log_str_01} 
  outlog_func I "${myname} is end"
  exit 0
else
  #errors occur.
  echo "Error occurs, while running sql_update.sh!"
  outlog_func E "Error occurs, while running sql_update.sh!"
  if [ $result = 1 ];then
   #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "`cat ${sql_log_name_1}`"
   sh $SHELL_DIR/curl_atr.sh $2 $3 'false' ${log_str_02} "想定外のエラーが発生したため、自動化基盤の状況及びデータの確認をお願いします。"
  else
   #python ${PYTHON_PATH}/end_asynchronous_job.py $1 $6 $4 "`cat ${sql_log_name_2}`"
   sh $SHELL_DIR/curl_atr.sh $2 $3 'false' ${log_str_02} "想定外のエラーが発生したため、自動化基盤の状況及びデータの確認をお願いします。"
  fi
  outlog_func I "${myname} is end"
  exit 1
fi

