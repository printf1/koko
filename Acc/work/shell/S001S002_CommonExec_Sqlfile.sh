#!/bin/bash
#ワークサーバにて問い合わせ結果格納SQLファイル(フルパス)を確認する。
#SQLファイル伝送 
#SQLファイル名の変更：申請番号_SQLファイル
#SQLファイルの権限が6-6-4に変更する
#$1:SQL file(path\filename) SQLファイル(ワークサーバフルパス)
#$2:job_id
#$3:job_token
#$4:s_token
#$5:f_token
#$6:applyEnv 申請対象環境(本番/QA)
#$7:applynumber 申請番号
#$8:operation_day(yymmdd) 作業日
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
if [ ! -f ${_exec_ksh} ]
then
    echo "環境設定ファイルが存在しません"
      sh $SHELL_DIR/curl_atr.sh $2 $3 'false' "failed"
    outlog_func I "環境設定ファイルが存在しません"
    exit 1
fi
. ${_exec_ksh}
source $_exec_ksh
if [ ! -f ${SHELL_DIR}/BATCH_COMMON_FUNC.sh ]
then
    echo "共通関数ファイルが存在しません"
      sh $SHELL_DIR/curl_atr.sh $2 $3 'false' "Failed"
    outlog_func I "共通関数ファイルが存在しません"
    exit 1
fi
. ${SHELL_DIR}/BATCH_COMMON_FUNC.sh


#parameter check
if [ $# != 8 ]
then
    outlog_func E "Argument is not input correctly."
    outlog_func E "Usage：$0 <SQL file(path\filename)> <job_id> <job_token> <s_token> <f_token> <applyEnv> <applynumber> <operation_day(yymmdd)>"
    #python ${PYTHON_PATH}/end_asynchronous_job.py $2 $3 $5 "Usage：$0 <SQL file(path\filename)> <job_id> <job_token> <s_token> <f_token> <applyEnv> <applynumber> <operation_day(yymmdd)>"
      sh $SHELL_DIR/curl_atr.sh $2 $3 'true' "success"
	outlog_func I "正常終了: date '+%Y-%m-%d %H:%M:%S'"
	exit 1
fi
if [ ! -e $1 ]
then
    outlog_func E "SQL file $1 doesn't exist!"
    #python ${PYTHON_PATH}/end_asynchronous_job.py $2 $3 $5 "SQL file $1 doesn't exist!"
      sh $SHELL_DIR/curl_atr.sh $2 $3 'false' "Failed"
    outlog_func I "SQL file $1 doesn't exist!"
	exit 1
fi

#hon_path="/workhome/home/ort/hon_sql/"${dt_path}/
#qa_path="/workhome/home/ort/qa_sql/"${dt_path}/

dt_path=$8  #yymmdd
hon_path=${HON_PATH_FREFIX}/${dt_path}/
qa_path=${QA_PATH_FREFIX}/${dt_path}/
sqlFileN=$7"_"`basename $1`
echo $dt_path $hon_path $qa_path $sqlFileN > /workhome/itcc/home/logs/S2.log
outlog_func I "sql file is $sqlFileN"


#SQL file transfer ,rename SQLfile'name and modify SQLfile'permissions
if [ "$6" == "${HONBAN}" ]; then
    if [ ! -d $hon_path ]; then
      mkdir -p $hon_path
      if [ $? -ne 0 ]; then
        outlog_func E "Failed to create folder ${hon_path}."
        sleep 10
        #python ${PYTHON_PATH}/end_asynchronous_job.py $2 $3 $5 "Failed to create folder ${hon_path}."
          sh $SHELL_DIR/curl_atr.sh $2 $3 'false' "Failed"
		exit 1
      fi
    fi
    cp $1 $hon_path$sqlFileN
    if [ $? -eq 0 ]; then
      outlog_func I "Under the $6 environment,SQL file transfer was successful!"
      chmod 664 $hon_path$sqlFileN
      sleep 10
      #python ${PYTHON_PATH}/end_asynchronous_job.py $2 $3 $4 "Under the $6 environment,SQL file transfer was successful!"
        sh $SHELL_DIR/curl_atr.sh $2 $3 'true' "success"
	  exit 0
    else
      outlog_func E "Under the $6 environment,SQL file transfer failed."
      sleep 10
      #python ${PYTHON_PATH}/end_asynchronous_job.py $2 $3 $5 "Under the $6 environment,SQL file transfer failed."
        sh $SHELL_DIR/curl_atr.sh $2 $3 'false' "failed"
	  exit 1
    fi	
elif [ "$6" == "${QA}" ]; then
    if [ ! -d $qa_path ]; then
      mkdir -p $qa_path
      if [ $? -ne 0 ]; then
        outlog_func E "Failed to create folder ${qa_path}."
        sleep 10
        #python ${PYTHON_PATH}/end_asynchronous_job.py $2 $3 $5 "Failed to create folder ${qa_path}."
          sh $SHELL_DIR/curl_atr.sh $2 $3 'false' "failed"
		exit 1
      fi
    fi
    cp $1 $qa_path$sqlFileN
    if [ $? -eq 0 ]; then  
      chmod 664 $qa_path$sqlFileN
      sleep 10
      #python ${PYTHON_PATH}/end_asynchronous_job.py $2 $3 $4 "Under the $6 environment,SQL file transfer was successful!"
        sh $SHELL_DIR/curl_atr.sh $2 $3 'true' "success"
      outlog_func I "Under the $6 environment,SQL file transfeer was successful!"	 
       exit 0
    else
      outlog_func E "Under the $6 environment,SQL file transfer failed."
      sleep 10
      #python ${PYTHON_PATH}/end_asynchronous_job.py $2 $3 $5 "Under the $6 environment,SQL file transfer failed."
        sh $SHELL_DIR/curl_atr.sh $2 $3 'false' "failed"
	  exit 1
    fi
fi
