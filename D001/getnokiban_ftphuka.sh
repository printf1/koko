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
dst=${2}                                 # ファイルセット先ファイルの格納場所
filename=${3}                            # ファイルセット元ファイル名
tuser=${4}                               # 対象server ユーザID
tip=${5}                                 # 対象server IPアドレス
tpasswd=${6}                             # 対象server パスワード
number=${7}                              # 作業依頼番号
owner=${8}                               # 対象ファイルの所有ユーザ
premission=${9}                          # 先ファイルパーミッション
tfilename=${10}                          # ファイルセット先ファイル名
tmode=${11}                              # 転送モード(binary or ascii)
#SDATE          = `date '+%Y%m%d'`

echo "$number getnokiban_ftphuka.sh Start！【`date '+%Y-%m-%d %H:%M:%S'`】" >> log_comment
#ステータス定義
STATUS101=101                            # セット元ファイルが存在するコード
STATUS666=666                            # sshログイン成功コード

uname -n 
pwd 
ls -l 

#元ファイルが存在するかを判断する
if [ ! -f $src/$filename ];then
    echo "$filename doesn't exist"
    echo $STATUS101
else
   /usr/bin/expect <<EOF
    set timeout 8
 #ファイルセット作業を実施する
    spawn ftp $tip
    #expect "yes/no:"
    #send "yes\r"
    expect "Name:"
    send "$tuser\r"
    expect "password:"
    send "$tpasswd\r"
    expect "#"
   
 #ファイルセット先サーバに一時フォルダを作成する
    #expect "ftp>"
    #send "su -\r"
    #expect "password:" 
    #send "$trootpwd\r" 
    expect "ftp>"
    send "mkdir /workhome/home/ort/itcc_common/work/koko/yyyy_$number\r"
    expect "ftp>"
    send "cd /workhome/home/ort/itcc_common/work/koko/yyyy_$number\r"
 #元ファイルの格納場所へ移動する
    expect "ftp>"
    send "lcd $src\r"
  #元ファイルを取得する 
    expect "ftp>"
    send "$tmode\r"
    expect "ftp>"
    send "put $filename\r"
    expect "ftp>"
    send "bye\r"
    expect eof



#セット先フォルダにファイルを移動する
 spawn ssh $tuser@$tip
    expect "password:"
    send "$tpasswd\r"
    #expect "#"
    #send "su -\r"
    expect "#"
    send "echo {666}\r"
    #expect "password:"
    #send "$trootpwd\r"
    expect "#"
    send "cp /workhome/home/ort/itcc_common/work/koko/yyyy_$number/$filename $dst/$tfilename\r"
 
 #取得されたファイルのオーナー変更
    expect "#"
    send "cd $dst\r"
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
    send "cd /workhome/home/ort/itcc_common/work/koko\r"
    expect "#"
    send "ls -ld yyyy_$number\r"
    expect "#"
    send "rm -irf yyyy_$number\r"
    expect "#"
    send "exit\r"
    expect eof
EOF
y=102                                       #正常終了の戻り値を設定する
echo "$number getnokiban_ftphuka.sh End！【`date '+%Y-%m-%d %H:%M:%S'`】" >> log_comment
fi
