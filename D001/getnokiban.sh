#!/bin/bash
###################################################################################################
# IF NAME          :  ファイルセット自動化（基盤以外）
# CONTENTS         :  ワークサーバに格納されたファイルを指定サーバにセットする
# CREATE DATE      :  2019/07/23
# CREATED BY       :  高　輝
# LASTUPDATE DATE  :
# LASTUPDATED BY   :
# 使用方法         :
# 戻り値           :  0 or 2
###################################################################################################
# パラメータ
src=${1}                                 # ファイルセット元ファイルの格納場所
muser=${2}                               # work server ユーザID
mip=${3}                                 # work server IP
dst=${4}                                 # ファイルセット先ファイルの格納場所
mpasswd=${5}                             # work server パスワード
filename=${6}                            # ファイルセット元ファイル名
tuser=${7}                               # 対象server ユーザID
tip=${8}                                 # 対象server IPアドレス
tpasswd=${9}                             # 対象server パスワード
number=${10}                             # 作業依頼番号
owner=${11}                              # 対象ファイルの所有ユーザ
premission=${12}                         # 先ファイルパーミッション
tfilename=${13}                          # ファイルセット先ファイル名
tmode=${14}                              # 転送モード(binary or ascii)
#SDATE          = `date '+%Y%m%d'`

echo "$number getnokiban.sh Start！【`date '+%Y-%m-%d %H:%M:%S'`】" >> log_comment
#ステータス定義
STATUS101=101                            # セット元ファイルが存在するコード
STATUS666=666                            # sshログイン成功コード
#uname -n 
#pwd
#ls -l 
#元ファイルが存在するかを判断する

if [ ! -f $src/$filename ];then
    echo "$filename doesn't exist"
    echo $STATUS101
    
else
    /usr/bin/expect <<EOF
    set timeout 8
 #ワークサーバからファイルセット先サーバへSSHする
    spawn ssh $tuser@$tip
    #expect "yes/no:"
    #send "yes\r"
    expect "password:"
    send "$tpasswd\r"
    expect "#"
    send "echo {$STATUS666}\r"
 #ファイルセット先サーバに一時フォルダを作成する
    expect "#"
    send "mkdir -p /workhome/home/ort/itcc_common/work/koko/yyyy_$number\r"
    expect "#"
    send "cd /workhome/home/ort/itcc_common/work/koko/yyyy_$number\r"

 #ファイルセット作業を実施する
    
 #ファイルセット先サーバからワークサーバへFTPする
    expect "#"
    send "ftp $mip\r"
    expect "name:"
    send "$muser\r"
    expect "password:"
    send "$mpasswd\r"
    
 #元ファイルの格納場所へ移動する
    expect "ftp>"
    send "cd $src\r"
 
 #元ファイルを取得する 
    expect "ftp>"
    send "$tmode\r"
    expect "ftp>"
    send "get $filename\r"
    expect "ftp>"
    send "bye\r"

 #セット先フォルダにファイルを移動する
    expect "#"
    send "cp $filename $dst/$tfilename\r"
 
 #取得されたファイルのオーナー変更
    expect "#"
    send "chown $owner $tfilename\r"
 
 #取得されたファイルのパーミッション変更
    expect "#"
    send "chmod $premission $tfilename\r"
    expect "#"
    send "ls -l\r"
    expect "#"
    send "ls -l $dst/$tfilename\r"
    expect "#"
    send "cd /workhome/home/ort/itcc_common/work/koko/\r"
    expect "#"
    send "ls -ld yyyy_$number\r"
    expect "#"
    send "rm -irf yyyy_$number\r"
    expect "#"
    send "exit\r"
    expect eof
EOF
y=102                                       #正常終了の戻り値を設定する
echo "$number getnokiban.sh End！【`date '+%Y-%m-%d %H:%M:%S'`】" >> log_comment
fi
