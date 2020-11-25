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
mhostname=${1}                                                        # ファイル退避先サーバのホス>ト名
thostname=${2}                                                        # ファイル退避元のホスト名
msrc=${3}                                                             # 先ファイル名(フルパス)
tsrc=${4}                                                             # 元ファイル名(フルパス)
tmode=${5}                                                            # 転送モード(binary or ascii) 
area=${6}                                                             # 申請領域
number=${7}                                                           # 申請番号
mowner=${8}                                                           # 先ファイル所有ユーザ
jobid=${9}
jobtoken=${10}
zip=${11}                                                             # 圧縮命令


i=`cat ftp_huka | grep -wc "$thostname"`

if [ $i -eq 0 ];then
   echo "aaaaaaaaaa"
   source ./putstart.sh ${mhostname} ${thostname} ${msrc} ${tsrc} ${tmode} ${area} ${number} ${mowner} ${jobid} ${jobtoken} ${zip}
   
else
   echo "bbbbbbbbbb"
   source ./putstart_ftphuka.sh ${thostname} ${msrc} ${tsrc} ${tmode} ${area} ${number} ${mowner} ${jobid} ${jobtoken} ${zip}
   
fi
