#!/bin/bash
###################################################################################################
# IF NAME          :  ファイルセット自動化
# CONTENTS         :  ワークサーバに格納されたファイルを指定サーバにセットする
# CREATE DATE      :  2019/11/08
# CREATED BY       :  高　輝
# LASTUPDATE DATE  :
# LASTUPDATED BY   :
# 使用方法         :
# 戻り値           :  0 or 2
###################################################################################################
#ATR参数
mhostname=$1                                                              # ファイルセット元サーバのホスト>名
thostname=$2                                                              # ファイルセット先のホスト名
msrc=$3                                                                   # 元ファイル名(フルパス)
tsrc=$4                                                                   # 先ファイル名(フルパス)
owner=$5                                                                  # 先ファイル所有ユーザ
premission=$6                                                             # 先ファイルパーミッション
tmode=$7                                                                  # 転送モード(binary or ascii)
area=$8                                                                   # 申請領域
number=$9                                                                 # 申請番号
jobid=$10
jobtoken=$11



i=`cat ftp_huka_server | grep -wc "$thostname"`

if [ $i -eq 0 ];then
   source ./getstart.sh ${mhostname} ${thostname} ${msrc} ${tsrc} ${owner} ${premission} ${tmode} ${area} ${number} ${jobid} ${jobtoken}
   
else
   echo "aaaaaaaaaaaaaaaaaa"
   source ./getstart_ftphuka.sh ${thostname} ${msrc} ${tsrc} ${owner} ${premission} ${tmode} ${area} ${number} ${jobid} ${jobtoken}
   
fi

