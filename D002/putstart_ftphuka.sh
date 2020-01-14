#!/bin/bash
###################################################################################################
# IF NAME          :  ファイルセット自動化
# CONTENTS         :  ワークサーバに格納されたファイルを指定サーバにセットする
# CREATE DATE      :  2019/07/23
# CREATED BY       :  高　輝
# LASTUPDATE DATE  :
# LASTUPDATED BY   :
# 使用方法         :
# 戻り値           :  0 or 2
###################################################################################################
#ATR参数
b=$#
thostname=${1}                                                        # ファイル退避元のホスト名
msrc=${2}                                                             # 先ファイル名(フルパス)
tsrc=${3}                                                             # 元ファイル名(フルパス)
tmode=${4}                                                            # 転送モード(binary or ascii) 
area=${5}                                                             # 申請領域
number=${6}                                                           # 申請番号
towner=${7}                                                           # 先ファイル所有ユーザ
jobid=${8}
jobtoken=${9}
zip=${10}                                                             # 圧縮命令

if [ ${b} -eq 10 ];then 
   zip=0
 else 
   zip=1
fi
#ファイル名及び格納場所
src=${msrc%/*}                                                        # ファイル退避先ファイルの格納>場所
filename=${msrc##*/}                                                  # ファイル退避先ファイル名
dst=${tsrc%/*}                                                        # ファイル退避元ファイルの格納>場所
tfilename=${tsrc##*/}                                                 # ファイル退避元ファイル名

#ステータス定義
STATUS101=101                                                         # 退避元ファイルが存在するコード
STATUS666=666                                                         # sshログイン成功コード
STATUS220=220                                                         # 接続成功コード
STATUS230=230                                                         # ログイン成功コード
STATUS226=226                                                         # FTP転送正常終了コード
STATUSTIMEOUT=タイムアウト                                            # SSH又はFTP処理がタイムアウトするコード

#システムタイム
#STIME=`date '+%Y%m%d\ %H%M%S'`
#echo "$STIME"
# ログファイル作成
touch log_$number
touch log_comment

# ホスト情報を読み取る
tip=`cat serverlist | grep "$thostname" | awk -F' ' '{print $2}'`              # 対象serverユーザID
tuser=`cat serverlist | grep "$thostname" | awk -F' ' '{print $3}'`            # 対象server IP
tpasswd=`cat serverlist | grep "$thostname" | awk -F' ' '{print $4}'`          # 対象serverパースワード
trootpwd=`cat serverlist | grep "$thostname" | awk -F' ' '{print $5}'`         # 対象root パースワード


# 先サーバが基盤サーバであるか
i=`cat hostnamelist | grep -wc "$thostname"`
if [ $i -gt 0 ]; then
    if [ ${zip} -eq 0 ];then
	#ファイル退避先サーバが基盤サーバである場合、putkiban.shをCallする
       echo "00000000000000000"
       source ./putkiban_ftphuka.sh ${src} ${dst} ${filename} ${tuser} ${tip} ${tpasswd} ${number} ${tfilename} ${tmode} ${mowner} ${trootpwd} > log_$number 2>&1
    else
       echo "11111111111111111"
       source ./putkiban_unzip_ftphuka.sh ${src} ${dst} ${filename} ${tuser} ${tip} ${tpasswd} ${number} ${tfilename} ${tmode} ${mowner} ${trootpwd} > log_$number 2>&1
    fi
else
    if [ ${zip} -eq 0 ];then
	#ファイル退避先サーバが基盤サーバである場合、putnokiban.shをCallする
       echo "2222222222222222"
       source ./putnokiban_ftphuka.sh ${src} ${dst} ${filename} ${tuser} ${tip} ${tpasswd} ${number} ${tfilename} ${tmode} ${mowner} > log_$number 2>&1
    else
       echo "3333333333333333"
       source ./putnokiban_unzip_ftphuka.sh ${src} ${dst} ${filename} ${tuser} ${tip} ${tpasswd} ${number} ${tfilename} ${tmode} ${mowner} > log_$number 2>&1
    fi
fi

#ファイルセット作業の実施結果をチェックする
if [ `cat log_$number | grep -wc "$STATUSTIMEOUT"` -ne 0 ];then
    echo "ファイル退避処理がタイムアウトしました。"
	${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} タイムアウト log_$number
    exit 
elif [ `cat log_$number | grep -wc "そのようなファイルやディレクトリはありません"` -ne 0 ];then
    echo "退避元ファイルが存在しません。"
	${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} 退避元ファイルが存在しません log_$number
    exit 
elif [ `cat log_$number | grep -wc "$STATUS220"` -eq 0 ];then
    echo "ワークサーバへのFTP接続ができませんでした。"
	${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} FTP接続ができませんでした log_$number
    exit 
elif [ `cat log_$number | grep -wc "$STATUS230"` -eq 0 ];then
    echo "ワークサーバへのFTP登録ができませんでした。"
	${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} FTP登録ができませんでした log_$number
    exit 
elif [ `cat log_$number | grep -wc "$STATUS226"` -eq 0 ];then
    echo "ファイル伝送失敗。"
        ${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} ファイル伝送失敗 log_$number
    exit $STATUS226
elif [ `cat log_$number | grep -wc "$STATUS666"` -lt 2 ];then
    echo "退避先サーバへのSSH接続ができませんでした。"
        ${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} SSH接続ができませんでした log_$number
    exit 
else
    echo "退避成功"
	${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} 正常終了 log_$number
fi

#ATRのAPIをCALLする
###################################
###################################

#ログファイルを指定フォルダーへ移動した後に、該当フォルダより削除する
echo $y >> log_$number 2>&1
if [ $y -eq 102 ];then
  x=101
#  mv log_$number log_2
#  mv log_comment log_c
#  rm -f log_$number log_comment
fi
