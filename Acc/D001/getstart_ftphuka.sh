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
thostname=$1                                                              # ファイルセット先のホスト名
msrc=$2                                                                   # 元ファイル名(フルパス)
tsrc=$3                                                                   # 先ファイル名(フルパス)
owner=$4                                                                  # 先ファイル所有ユーザfilegroup=$6                                                              
premission=$5                                                             # 先ファイルパーミッション
tmode=$6                                                                  # 転送モード(binary or ascii)
area=$7                                                                   # 申請領域
number=$8                                                                 # 申請番号
jobid=$9
jobtoken=$10
status=$11

# ファイル名及び格納場所
src=${msrc%/*}                                                            # ファイルセット元ファイルの格納>場所
echo "$src"
filename=${msrc##*/}                                                      # ファイルセット元ファイル名
echo "$filename"
dst=${tsrc%/*}                                                            # ファイルセット先ファイルの格納>場所
echo "$dst"
tfilename=${tsrc##*/}                                                     # ファイルセット先ファイル名
echo "$tfilename"


STATUS101=101                                                             # セット元ファイルが存在するコード
STATUS666={666}                                                           # sshログイン成功コード
STATUS220=220                                                             # 接続成功コード
STATUS230=230                                                             # ログイン成功コード
STATUS226=226                                                             # FTP転送正常終了コード
STATUSTIMEOUT=タイムアウト                                                # SSH又はFTP処理がタイムアウトするコード


#STIME=`date '+%Y%m%d\ %H%M%S'`
#echo "$STIME"

# ログファイル作成
touch log_$number 
touch log_comment

# ホスト情報を読み取る
tip=`cat serverlist | grep "$thostname" | awk -F' ' '{print $2}'`                 # 対象serverユーザID
tuser=`cat serverlist | grep "$thostname" | awk -F' ' '{print $3}'`                # 対象server IP
tpasswd=`cat serverlist | grep "$thostname" | awk -F' ' '{print $4}'`              # 対象serverパースワード
trootpwd=`cat serverlist | grep "$thostname" | awk -F' ' '{print $5}'`             # 対象root パースワード



# 先サーバが基盤サーバであるか
i=`cat hostnamelist | grep -wc "$thostname"`
if [ $i -gt 0 ]; then
    #ファイルセット先サーバが基盤サーバである場合、getkiban.shをCallする
    
	source ./getkiban_ftphuka.sh ${src} ${dst} ${filename} ${tuser} ${tip} ${tpasswd} ${number} ${owner} ${premission} ${tfilename} ${trootpwd} ${tmode} > log_$number 2>&1
else
    #ファイルセット先サーバが基盤サーバである場合、getnokiban.shをCallする
    
    source ./getnokiban_ftphuka.sh ${src} ${dst} ${filename} ${tuser} ${tip} ${tpasswd} ${number} ${owner} ${premission} ${tfilename} ${tmode} > log_$number 2>&1
fi

#ファイルセット作業の実施結果をチェックする
if [ `cat log_$number | grep -wc "$STATUSTIMEOUT"` -ne 0 ];then
    echo "ファイルセット処理がタイムアウトしました。"
    ${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} タイムアウト log_comment
    exit 
elif [ `cat log_$number | grep -wc "$STATUS101"` -ne 0 ];then
    echo "セット元ファイルが存在しません。"
    ${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} セット元ファイルが存在しません log_comment
    exit 
elif [ `cat log_$number | grep -wc "$STATUS220"` -eq 0 ];then
    echo "ワークサーバへのFTP接続ができませんでした。"   
    ${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} FTP接続ができませんでした log_comment
    exit
elif [ `cat log_$number | grep -wc "$STATUS230"` -eq 0 ];then
    echo "ワークサーバへのFTP登録ができませんでした。"    
    ${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} FTP登録ができませんでした log_comment
    exit 
elif [ `cat log_$number | grep -wc "$STATUS226"` -eq 0 ];then
    echo "ファイル伝送失敗。"
    ${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} ファイル伝送失敗 log_comment
    exit
elif [ `cat log_$number | grep -wc "$STATUS666"` -lt 2 ];then
    echo "セット先サーバへのSSH接続ができませんでした。"
    ${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} SSH接続ができませんでした log_comment
    exit 
else
    echo "伝送成功"
    ${PYTHON_PATH}/end_asynchronous_job.py ${jobid} ${jobtoken} 正常終了 log_comment
fi

#ATRのAPIをCALLする
###################################
###################################

#ログファイルを指定フォルダーへ移動した後に、該当フォルダより削除する
if [ $y -eq 102 ];then
  x=101
 # mv log_$number log2
 # mv log_comment log_c
 # rm -f log_$number log_comment
fi
