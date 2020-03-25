#!/bin/sh
#$1: 環境名（eg:本番環境 or 本番環境以外)
#$2: 連番(1,2,3,...)
#$3: JP1作成FLAG(0:新規,0以外:再利用)
#$4: JP1コマンドパス
#$5: jobId
#$6: job_token
#$7: ticketNumber
#$8: token-success
#$9: token-failed
#$10:　領域（eg:LO ロジなど）
#sh -x  J003_Shell_001.sh 本番環境 "LO ロジ" 1 0 ORT/ATR/test1 jobId-01 job_token-01  ticketNumber-01 token-success-01 token-failed-01
par=`echo ${echo:10}`
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
echo "sig_1" > /workhome/itcc/work/logs/J.log
if [ ! -f ${_exec_ksh} ]
then
    echo "環境設定ファイルが存在しません"
    sh ${SHELL_DIR}/curl_atr.sh $5 $6 'false' "failed"
    exit 1
fi
. ${_exec_ksh}
echo $1 $2 $3 >> /workhome/itcc/work/logs/J.log
if [ ! -f ${SHELL_DIR}/BATCH_COMMON_FUNC.sh ]
then
	echo "共通関数ファイルが存在しません"
        sh ${SHELL_DIR}/curl_atr.sh $5 $6 'false' "failed"
	exit 1
fi
. ${SHELL_DIR}/BATCH_COMMON_FUNC.sh

#実行ファイルの名前を取得します。
myname=`basename $0`
#debugモード,DEBUG="ON"　OR　DEBUG=""
#export DEBUG="ON"

#開始ログ
outlog_func I "${myname} is start"
start_time=`date '+%Y/%m/%d %H:%M:%S'`
#/H本番実行環境/EBS/ロジ/RECO/2019-07-31#001
#①環境：作業依頼の申請対象環境から判別可能
#②領域カテゴリ＆③領域(システム)
#④RECO：固定値
#⑤RECO名：作業依頼の作業日
#パラメータの数をチェックします。
if [ $# -lt 10 ]
then
	#echo "Argument is not input correctly."
	#echo "Usage：$0 <SQL file(path\filename)> <job_id> <job_token> <s_token> <f_token> <applyEnv>  <applynumber>"
	outlog_func E "Argument is not input correctly."
	outlog_func E "Usage：$0 <環境名> <領域> <連番> <JP1FLAG> <JP1DATE> <jobId> <job_token> <ticketNumber> <token-success> <token-failed>"
    #${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "Usage：$0 <環境名> <領域> <連番> <JP1FLAG> <JP1DATE> <jobId> <job_token> <ticketNumber> <token-success> <token-failed>" ""
    #python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "$|$Usage：$0 <環境名> <領域> <連番> <JP1FLAG> <JP1DATE> <jobId> <job_token> <ticketNumber> <token-success> <token-failed>"
    sh ${SHELL_DIR}/curl_atr.sh $5 $6 'false' "failed"
    exit 1
fi
echo "sig_2" >> /workhome/itcc/work/logs/J.log
#実行パス
v_path_prefix="/opt/jp1ajs2/bin/ajsentry -F AJSROOT2 -n -w "
v_path_log_prefix='/opt/jp1ajs2/bin/ajsshow -F AJSROOT2 -f "%C %E %J" -E '

#環境名の取得
#HON_VAL=本番環境;PATH_ENV_VAL_1=H本番実行環境;PATH_ENV_VAL_2=K開発検証実行環境
v_env_path=
v_env=$1
if [ x"$v_env" = x"${HON_VAL}" ]; then
	v_env_path="${PATH_ENV_VAL_1}"
else
	v_env_path="${PATH_ENV_VAL_2}"
fi
echo "sig_3" >> /workhome/itcc/work/logs/J.log
#領域パスとサーバの取得
#H本番実行環境,eujph00w,EBS,LO ロジ
v_domain=${par}
echo "v_domain="${v_domain} >> /workhome/itcc/work/logs/J.log
v_server=
v_server=`cat ${HOME}/ini/path_list.conf | sed '/^$/d' | grep "${v_env_path},.*${v_domain}" | head -1 | cut -d ',' -f2`
echo ${v_server} >> /workhome/itcc/work/logs/J.log
if [ ! "$v_server" ]; then
	outlog_func E "can not found domain server domain=${v_domain}"
	#${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "can not found domain server domain=${v_domain}" ""
        #python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "$|$can not found domain server domain=${v_domain}"
        sh ${SHELL_DIR}/curl_atr.sh $5 $6 'false' "failed"
	exit 1
fi
#eujph00w.ydc.fujixerox.co.jp
#eujpq00w.ydc.fujixerox.co.jp
v_server_ip=${v_server}${IP_SUFFIX}
echo "v_server_ip="${v_server_ip} >> /workhome/itcc/work/logs/J.log
echo "sig_4" >> /workhome/itcc/work/logs/J.log
v_domain_path=
v_domain_path_1=`cat ${HOME}/ini/path_list.conf | sed '/^$/d' | grep "${v_env_path},.*${v_domain}" | head -1 | cut -d ',' -f3`
echo "v_domain_path_1="“${v_domain_path_1} >> /workhome/itcc/work/logs/J.log
if [ ! "$v_domain_path_1" ]; then
	outlog_func E "can not found domain path domain=${v_domain}"
	#${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "can not found domain path domain=${v_domain}" ""
        #python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "$|$can not found domain path domain=${v_domain}"
        sh ${SHELL_DIR}/curl_atr.sh $5 $6 'false' "failed"
	exit 1
fi
#EBS/ロジ
v_domain_path=$v_domain_path_1/`echo ${v_domain}|awk '{print $2}'`
echo "v_domain_path="${v_domain_path} >> /workhome/itcc/work/logs/J.log
echo "sig_5" >> /workhome/itcc/work/logs/J.log
#RECOパスの取得
#RECO
v_reco_path=${PATH_RECO_VAL}
echo "v_reco_path="${v_reco_path} >> /workhome/itcc/work/logs/J.log
#日付の取得
v_date_path=`date "+%Y-%m-%d"`
echo "v_date_path="$v_date_path >> /workhome/itcc/work/logs/J.log
#番号の取得
r_number="$2"
if [ $r_number == "null" ]; then
	outlog_func E "number is null"
	#${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "number is null" ""
        #python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "$|$number is null"
        sh ${SHELL_DIR}/curl_atr.sh $5 $6 'false' "failed"
	exit 1
fi
v_number_path=`printf "%03d\n" ${r_number}`
echo "v_number_path="${v_number_path} >> /workhome/itcc/work/logs/J.log
echo "sig_6" >> /workhome/itcc/work/logs/J.log
evho "v_number_path="${v_number_path} >> /workhome/itcc/work/logs/J.log
#jp1 cmdの作成
if [ $3 -eq 0 ]; then
       echo "sig_7" >> /workhome/itcc/work/logs/J.log
	cmd_jp1=${v_path_prefix}/${v_env_path}/${v_domain_path}${v_reco_path}/${v_date_path}#${v_number_path}
	cmd_jp1_log=${v_path_log_prefix}/${v_env_path}/${v_domain_path}${v_reco_path}/${v_date_path}#${v_number_path}
else
       echo "sig_8" >> /workhome/itcc/work/logs/J.log
	cmd_jp1=${v_path_prefix}/${4}
	cmd_jp1_log=${v_path_prefix}/${4}
fi

echo "cmd_jp1="${cmd_jp1} >> /workhome/itcc/work/logs/J.log
echo "cmd_jp1_log="${cmd_jp1_log} >> /workhome/itcc/work/logs/J.log

#cmd_jp1=${v_path_prefix}/'ORT/ATR/test'
#cmd_jp1_log=${v_path_log_prefix}/'ORT/ATR/test'

outlog_func I "jp1 cmd is ${cmd_jp1}"
outlog_func I "jp1_log cmd is ${cmd_jp1_log}"
echo "password:${ROOT_PASSWD}" >> /workhome/itcc/work/logs/J.log
#result=`sshpass -p ${ROOT_PASSWD} ssh root@${v_server_ip} ${cmd_jp1} 2>&1`
#result=`sh ${SHELL_DIR}/call_expect.sh ${ROOT_PASSWD} ${v_server_ip} ${cmd_jp1} 2>&1`
result=`sh ${SHELL_DIR}/call_expect.sh ${ROOT_PASSWD} ${v_server_ip} 2>&1`
#usr/bin/expect <<EOF
#   set timeout 8
#   spawn ssh root@${v_server_ip} 
#   expect "password:"
#   send "${ROOT_PASSWD}\n"
#   expect "#"
#   send "${cmd_jp1}\n"
#   expect "#"
#   send "exit\n"
#   expect eof
#EOF
echo "result="${result} >> /workhome/itcc/work/logs/J.log
#result=`${cmd_jp1} 2>&1`
flag=`echo ${result} | cut -d' ' -f1`
if [ -z "$flag" ]; then
       echo "sig_9" >> /workhome/itcc/work/logs/J.log
	outlog_func I "${cmd_jp1} executed successfully!"
    #${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $9 "${cmd_jp1} executed successfully!"　"$result"
    #python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $9 "${cmd_jp1}$|$コメント内容に下記情報を記載${start_time}~`date '+%Y/%m/%d %H:%M:%S'` 作業は ${result} しました."
	outlog_func I "${myname} is end"
else
       echo "sig_10" >> /workhome/itcc/work/logs/J.log
	outlog_func E "${cmd_jp1_log} executed failed!"
    #${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "${cmd_jp1} executed failed!" "$result"
    #python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "${cmd_jp1}$|$コメント内容に下記情報を記載${start_time}~`date '+%Y/%m/%d %H:%M:%S'` 作業は ${result} しました."
	outlog_func I "${myname} is end"
        ${SHELL_DIR}/curl_atr.sh $5 $6 'false' "failed"
	exit 2
fi

#result=`sshpass -p ${ROOT_PASSWD} ssh root@${v_server_ip} ${cmd_jp1_log}`
#result=`sh ${SHELL_DIR}/call_expect.sh ${ROOT_PASSWD} ${v_server_ip} ${cmd_jp1_log} 2>&1`
result=`sh ${SHELL_DIR}/call_expect.sh ${ROOT_PASSWD} ${v_server_ip} 2>&1`
echo "result:"$result >> /workhome/itcc/work/logs/J.log
#result=`eval ${cmd_jp1_log}`
flag=`echo ${result} | cut -d' ' -f1`
end_time=`date '+%Y/%m/%d %H:%M:%S'`
if [ x"${flag}" = x"${SUCCESS_END_VAL}" ]; then
       echo "sig_11" >> /workhome/itcc/work/logs/J.log
	outlog_func I "${cmd_jp1_log} executed successfully!"
    #${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $9 "${cmd_jp1_log} executed successfully! $result start_time:${start_time}" "end_time:${end_time}"
    #python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $9 "${cmd_jp1_log}$|$コメント内容に下記情報を記載${start_time}~`date '+%Y/%m/%d %H:%M:%S'` 作業は ${result} しました."    
	outlog_func I "${myname} is end"
        sh ${SHELL_DIR}/curl_atr.sh $5 $6 'true' "success"
	exit 0
else
       echo "sig_12" >> /workhome/itcc/work/logs/J.log
	outlog_func E "${cmd_jp1_log} executed failed!"
    #${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "${cmd_jp1_log} executed failed!" "$result"
    #python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $5 $6 $10 "${cmd_jp1_log}$|$コメント内容に下記情報を記載${start_time}~`date '+%Y/%m/%d %H:%M:%S'` 作業は ${result} しました."
	outlog_func I "${myname} is end"
        sh ${SHELL_DIR}/curl_atr.sh $5 $6 'false' "failed"
	exit 1
fi
