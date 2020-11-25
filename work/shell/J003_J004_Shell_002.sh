c #!/bin/sh
#$1: 環境名（eg:本番環境 or 本番環境以外)
#$2:　領域（eg:LO ロジなど）
#$3: 連番(1,2,3,...)
#$4: 処理予測時間
#$5: JP1作成FLAG(0:新規,0以外:再利用)
#$6: JP1コマンドパス
#$7: jobId
#$8: job_token
#$9: ticketNumber
#$10: token-success
#$11: token-failed
#  sh -x J003_Shell_002.sh 本番環境 "LO ロジ" 1 00:01 0 ORT/ATR/test1 jobId-01 job_token-01  ticketNumber-01 token-success-01 token-failed-01
echo "sig_1" >> /workhome/itcc/work/logs/J.log
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
if [ ! -f ${_exec_ksh} ]
then
    echo "環境設定ファイルが存在しません"
    sh ${SHELL_DIR}/curl_atr.sh $7 $8 'false' "failed"
    exit 1
fi
. ${_exec_ksh}
echo $1 $2 $3 >> /workhome/itcc/work/logs/J.log
if [ ! -f ${SHELL_DIR}/BATCH_COMMON_FUNC.sh ]
then
	echo "共通関数ファイルが存在しません"
        sh ${SHELL_DIR}/curl_atr.sh $7 $8 'false' "failed"
	exit 1
fi
. ${SHELL_DIR}/BATCH_COMMON_FUNC.sh
echo "sig_2" >> /workhome/itcc/work/logs/J.log
#実行ファイルの名前を取得します。
myname=`basename $0`
#debugモード,DEBUG="ON"　OR　DEBUG=""
#export DEBUG="ON"

mornitorname=`echo ${myname%.*}|awk -F '_' -v OFS='_' '{$NF="";print $0}'`001.sh
#開始ログ
outlog_func I "${myname} is start"

#/H本番実行環境/EBS/ロジ/RECO/2019-07-31#001
#①環境：作業依頼の申請対象環境から判別可能
#②領域カテゴリ＆③領域(システム)
#④RECO：固定値
#⑤RECO名：作業依頼の作業日
#パラメータの数をチェックします。
if [ $# != 11 ]
then
	#echo "Argument is not input correctly."
	#echo "Usage：$0 <SQL file(path\filename)> <job_id> <job_token> <s_token> <f_token> <applyEnv>  <applynumber>"
	outlog_func E "Argument is not input correctly."
	outlog_func E "Usage：$0 <環境名> <領域> <連番> <処理予測時間> <JP1FLAG> <JP1DATE> <jobId> <job_token> <ticketNumber> <token-success> <token-failed>"
        #python ${PYTHON_PATH}/end_asynchronous_job.py $7 $8 $11 "Usage：$0 <環境名> <領域> <連番> <処理予測時間> <JP1FLAG> <JP1DATE> <jobId> <job_token> <ticketNumber> <token-success> <token-failed>"
    sh ${SHELL_DIR}/curl_atr.sh $7 $8 'false' "failed"
    exit 1
fi
echo "sig_3" >> /workhome/itcc/work/logs/J.log
#実行パス
v_path_log_prefix='/opt/jp1ajs2/bin/ajsshow -F AJSROOT2 -f "%C %E %J" -E '

#環境名の取得
v_env_path=
v_env=$1
if [ x"$v_env" = x"${HON_VAL}" ]; then
	v_env_path="${PATH_ENV_VAL_1}"
else
	v_env_path="${PATH_ENV_VAL_2}"
fi

#領域パスとサーバの取得
v_domain=$2
v_server=
v_server=`cat ${HOME}/ini/path_list.conf | sed '/^$/d' | grep "${v_env_path},.*${v_domain}" | head -1 | cut -d ',' -f2`
if [ ! "$v_server" ]; then
	outlog_func E "can not found domain server domain=${v_domain}"
	#python ${PYTHON_PATH}/end_asynchronous_job.py $7 $8 $11 "can not found domain server domain=${v_domain}"
        sh ${SHELL_DIR}/curl_atr.sh $7 $8 'false' "failed"
	exit 1
fi
v_server_ip=${v_server}${IP_SUFFIX}
echo "sig_4" >> /workhome/itcc/work/logs/J.log
v_domain_path=
v_domain_path_1=`cat ${HOME}/ini/path_list.conf | sed '/^$/d' | grep "${v_env_path},.*${v_domain}" | head -1 | cut -d ',' -f3`
if [ ! "$v_domain_path_1" ]; then
	outlog_func E "can not found domain path domain=${v_domain}"
	#python ${PYTHON_PATH}/end_asynchronous_job.py $7 $8 $11 "can not found domain path domain=${v_domain}"
	sh ${SHELL_DIR}/curl_atr.sh $7 $8 'false' "failed"
        exit 1
fi  
v_domain_path=$v_domain_path_1/`echo ${v_domain}|awk '{print $2}'`

#RECOパスの取得
v_reco_path=${PATH_RECO_VAL}
echo "sig_5" >> /workhome/itcc/work/logs/J.log
#日付の取得
v_date_path=$6

#番号の取得
r_number="$3"
if [ ! "$r_number" ]; then
	outlog_func E "number is null"
    #python ${PYTHON_PATH}/end_asynchronous_job.py $7 $8 $11 "number is null"
    sh ${SHELL_DIR}/curl_atr.sh $7 $8 'false' "failed"
    exit 1
fi
v_number_path=`printf "%03d\n" ${r_number}`

echo "sig_6" >> /workhome/itcc/work/logs/J.log
#jp1 cmdの作成
if [ $5 -eq 0 ]; then
	cmd_jp1_log=${v_path_log_prefix}/${v_env_path}/${v_domain_path}/${v_reco_path}/${v_date_path}#${v_number_path}
else
	cmd_jp1_log=${v_path_log_prefix}/${6}
fi
#cmd_jp1_log=${v_path_log_prefix}/'ORT/ATR/test1'

outlog_func I "jp1_log cmd is ${cmd_jp1_log}"

#Start time of shell execution
startTime=`date '+%Y-%m-%d %H:%M:%S'`

#Seconds of Start time
startTimeSecs=`date -d "$startTime" +%s`

hr=`echo $4 | awk -F ':' '{print $1}'`
mm=`echo $4 | awk -F ':' '{print $2}'`

#Seconds of 「処理予測時間」
limitEndTimeSecs=$((startTimeSecs+hr*60*60+mm*60))
echo "sig_7" >> /workhome/itcc/work/logs/J.log
currentTime=`date '+%Y-%m-%d %H:%M:%S'`
#Seconds of current time
currentTimeSecs=`date -d "$currentTime" +%s`

sleep 5
outlog_func I "mornitor is start"
pid=
while [[ "$currentTimeSecs" -le "$limitEndTimeSecs" ]]
do
	result=`sshpass -p ${ROOT_PASSWD} ssh root@${v_server_ip} ${cmd_jp1_log}`
	#result=`eval ${cmd_jp1_log}`
	flag=`echo ${result} | cut -d' ' -f1`
	pid=`ps -ef |grep -e "${mornitorname}.*${7}"|grep -v grep|head -1|awk '{print $2}'`
	if [ x${flag} = x"${RUNNING_VAL}" -a "${pid}" ]; then
		sleep 10
		currentTime=`date '+%Y-%m-%d %H:%M:%S'`
		#Seconds of current time
		currentTimeSecs=`date -d "$currentTime" +%s`
	else
		outlog_func I "jp1 is end"
		#${PYTHON_PATH}/end_asynchronous_job.py $7 $8 $10 "jp1 is end"
                sh ${SHELL_DIR}/curl_atr.sh $7 $8 'true' "success"
		outlog_func I "${myname} is end"
		exit 0
	fi	
done
echo "sig_8" >> /workhome/itcc/work/logs/J.log
pid=`ps -ef | grep -e "${mornitorname}.*${7}"|grep -v grep|head -1|awk '{print $2}'`
result=`sshpass -p ${ROOT_PASSWD} ssh root@${v_server_ip} ${cmd_jp1_log}`
#result=`eval ${cmd_jp1_log}`
flag=`echo ${result} | cut -d' ' -f1`
if [ x${flag} = x"${RUNNING_VAL}" -a "${pid}" ]; then
       echo "sig_9" >> /workhome/itcc/work/logs/J.log
	outlog_func I "jp1 is over time"
	echo `date "+%Y-%m-%d %H:%M:%S"` ${cmd_jp1_log} "長時間走行が発生しました" >> ${LOG_DIR}/J003_J004_WARN.log
	#python ${PYTHON_PATH}/end_asynchronous_job.py $7 $8 $11 "jp1 is over time"
	# mail cmd
        ${SHELL_DIR}/curl_atr.sh $7 $8 'false' "failed"
	outlog_func I "${myname} is end"
	exit 1
else
       echo "sig_10" >> /workhome/itcc/work/logs/J.log
	outlog_func I "jp1 is end"
	#python s${PYTHON_PATH}/end_asynchronous_job.py $7 $8 $10 "jp1 is end"
 	outlog_func I "${myname} is end"
        ${SHELL_DIR}/curl_atr.sh $7 $8 'true' "success"
	exit 0
fi
