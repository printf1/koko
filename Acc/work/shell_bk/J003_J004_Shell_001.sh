#!/bin/sh
#$1: 環境名（eg:本番環境 or 本番環境以外)
#$2:　領域（eg:LO ロジなど）
#$3: 連番(1,2,3,...)
#$4: JP1作成FLAG(0:新規,0以外:再利用)
#$5: JP1コマンドパス
#$6: jobId
#$7: job_token
#$8: ticketNumber
#$9: token-success
#$10: token-failed
#sh -x  J003_Shell_001.sh 本番環境 "LO ロジ" 1 0 ORT/ATR/test1 jobId-01 job_token-01  ticketNumber-01 token-success-01 token-failed-01
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
if [ $# != 10 ]
then
	#echo "Argument is not input correctly."
	#echo "Usage：$0 <SQL file(path\filename)> <job_id> <job_token> <s_token> <f_token> <applyEnv>  <applynumber>"
	outlog_func E "Argument is not input correctly."
	outlog_func E "Usage：$0 <環境名> <領域> <連番> <JP1FLAG> <JP1DATE> <jobId> <job_token> <ticketNumber> <token-success> <token-failed>"
    #${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "Usage：$0 <環境名> <領域> <連番> <JP1FLAG> <JP1DATE> <jobId> <job_token> <ticketNumber> <token-success> <token-failed>" ""
    python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "$|$Usage：$0 <環境名> <領域> <連番> <JP1FLAG> <JP1DATE> <jobId> <job_token> <ticketNumber> <token-success> <token-failed>"
    exit 1
fi

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

#領域パスとサーバの取得
#H本番実行環境,eujph00w,EBS,LO ロジ
v_domain=$2
v_server=
v_server=`cat ${HOME}/ini/path_list.conf | sed '/^$/d' | grep "${v_env_path},.*${v_domain}" | head -1 | cut -d ',' -f2`
if [ ! "$v_server" ]; then
	outlog_func E "can not found domain server domain=${v_domain}"
	#${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "can not found domain server domain=${v_domain}" ""
    python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "$|$can not found domain server domain=${v_domain}"
	exit 1
fi
#eujph00w.ydc.fujixerox.co.jp
#eujpq00w.ydc.fujixerox.co.jp
v_server_ip=${v_server}${IP_SUFFIX}

v_domain_path=
v_domain_path_1=`cat ${HOME}/ini/path_list.conf | sed '/^$/d' | grep "${v_env_path},.*${v_domain}" | head -1 | cut -d ',' -f3`
if [ ! "$v_domain_path_1" ]; then
	outlog_func E "can not found domain path domain=${v_domain}"
	#${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "can not found domain path domain=${v_domain}" ""
    python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "$|$can not found domain path domain=${v_domain}"
	exit 1
fi
#EBS/ロジ
v_domain_path=$v_domain_path_1/`echo ${v_domain}|awk '{print $2}'`

#RECOパスの取得
#RECO
v_reco_path=${PATH_RECO_VAL}

#日付の取得
v_date_path=`date "+%Y-%m-%d"`

#番号の取得
r_number="$3"
if [ ! "$r_number" ]; then
	outlog_func E "number is null"
	#${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "number is null" ""
    python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "$|$number is null"
	exit 1
fi
v_number_path=`printf "%03d\n" ${r_number}`


#jp1 cmdの作成
if [ $4 -eq 0 ]; then
	cmd_jp1=${v_path_prefix}/${v_env_path}/${v_domain_path}/${v_reco_path}/${v_date_path}#${v_number_path}
	cmd_jp1_log=${v_path_log_prefix}/${v_env_path}/${v_domain_path}/${v_reco_path}/${v_date_path}#${v_number_path}
else
	cmd_jp1=${v_path_prefix}/${5}
	cmd_jp1_log=${v_path_prefix}/${5}
fi
#cmd_jp1=${v_path_prefix}/'ORT/ATR/test'
#cmd_jp1_log=${v_path_log_prefix}/'ORT/ATR/test'

outlog_func I "jp1 cmd is ${cmd_jp1}"
outlog_func I "jp1_log cmd is ${cmd_jp1_log}"

result=`sshpass -p ${ROOT_PASSWD} ssh root@${v_server_ip} ${cmd_jp1} 2>&1`
#result=`${cmd_jp1} 2>&1`
flag=`echo ${result} | cut -d' ' -f1`
if [ -z "$flag" ]; then
	outlog_func I "${cmd_jp1} executed successfully!"
    #${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $9 "${cmd_jp1} executed successfully!"　"$result"
    python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $9 "${cmd_jp1}$|$コメント内容に下記情報を記載${start_time}~`date '+%Y/%m/%d %H:%M:%S'` 作業は ${result} しました."
	outlog_func I "${myname} is end"
else
	outlog_func E "${cmd_jp1_log} executed failed!"
    #${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "${cmd_jp1} executed failed!" "$result"
    python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "${cmd_jp1}$|$コメント内容に下記情報を記載${start_time}~`date '+%Y/%m/%d %H:%M:%S'` 作業は ${result} しました."
	outlog_func I "${myname} is end"
	exit 2
fi

result=`sshpass -p ${ROOT_PASSWD} ssh root@${v_server_ip} ${cmd_jp1_log}`
#result=`eval ${cmd_jp1_log}`
flag=`echo ${result} | cut -d' ' -f1`
end_time=`date '+%Y/%m/%d %H:%M:%S'`
if [ x"${flag}" = x"${SUCCESS_END_VAL}" ]; then
	outlog_func I "${cmd_jp1_log} executed successfully!"
    #${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $9 "${cmd_jp1_log} executed successfully! $result start_time:${start_time}" "end_time:${end_time}"
    python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $9 "${cmd_jp1_log}$|$コメント内容に下記情報を記載${start_time}~`date '+%Y/%m/%d %H:%M:%S'` 作業は ${result} しました."    
	outlog_func I "${myname} is end"
	exit 0
else
	outlog_func E "${cmd_jp1_log} executed failed!"
    #${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "${cmd_jp1_log} executed failed!" "$result"
    python ${PYTHON_PATH}/end_asynchronous_job_j003_j004.py $6 $7 $10 "${cmd_jp1_log}$|$コメント内容に下記情報を記載${start_time}~`date '+%Y/%m/%d %H:%M:%S'` 作業は ${result} しました."
	outlog_func I "${myname} is end"
	exit 1
fi
