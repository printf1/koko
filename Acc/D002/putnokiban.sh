#!/bin/bash
###################################################################################################
# IF NAME          :  ファイル退避自動化（基盤以外）
# CONTENTS         :  ワークサーバに格納されたファイルを指定サーバに退避する
# CREATE DATE      :  2019/07/23
# CREATED BY       :  高　輝
# LASTUPDATE DATE  :
# LASTUPDATED BY   :
# 使用方法         :
# 戻り値           :  0 or 2
###################################################################################################
# パラメータ
src=${1}                                                     # 退避先ファイルの格納場所
muser=${2}                                                   # 退避先サーバ ユーザID
mip=${3}                                                     # 退避先サーバ IP
mpasswd=${4}                                                 # 退避先サーバ パスワード
dst=${5}                                                     # 退避元ファイルの格納場所
filename=${6}                                                # 退避先ファイル名
tuser=${7}                                                   # 退避元server ユーザID
tip=${8}                                                     # 退避元server IPアドレス
tpasswd=${9}                                                 # 退避元server パスワード
number=${10}                                                 # 作業依頼番号
tfilename=${11}                                              # 退避元ファイルフ名
tmode=${12}                                                  # FTP転送モード
mowner=${13}                                                 # 退避先ファイルの所有ユーザ


echo "$number putnokiban.sh Start！【`date '+%Y-%m-%d %H:%M:%S'`】" >> log_comment
#ステータス定義
STATUS101=101                                                # 退避元ファイルが存在するコード
STATUS666=666                                                # sshログイン成功コード

uname -n 
pwd 
ls -l 

/usr/bin/expect <<EOF
    set timeout 5
    spawn ssh $tuser@$tip
    #expect "yes/no:"
    #send "yes\r"
    expect "password:"
    send "$tpasswd\r"
    expect "#"
    send "echo {$STATUS666}\r"

    expect "#"
    send "ls -l $dst/$tfilename\r"
    expect "#"
    send "mkdir -p /workhome/home/ort/itcc_common/work/koko/yyyy_$number\r"
    expect "#"
    send "cd /workhome/home/ort/itcc_common/work/koko/yyyy_$number\r"

    expect "#"
    send "ls -l\r"
    expect "#"
    send "cp -ip $dst/$tfilename $filename\r"
    expect "#"
    send "zip $filename.zip $filename\r"
    expect "#"
    send "ls -l $filename.zip\r"
    expect "#"
    send "ftp $mip\r"
    expect "name:"
    send "$muser\r"
    expect "password:"
    send "$mpasswd\r"
    expect "ftp>"
    send "cd $src\r"
    expect "ftp>"
    send "$tmode\r"
    expect "ftp>"
    send "put $filename.zip\r"
    expect "ftp>"
    send "bye\r"
    expect "#"
    send "cd /workhome/home/ort/itcc_common/work/koko\r"
    expect "#"
    send "ls -ld yyyy_$number\r"
    expect "#"
    send "rm -irf yyyy_$number\r"
    expect "#"
    send "exit\r"
EOF
chown $mowner $src/$filename.zip                 #退避されたファイルの所有情報を変更する
echo "$number putnokiban.sh End！【`date '+%Y-%m-%d %H:%M:%S'`】" >> log_comment
y=102                                                        #正常終了の戻り値を設定する
