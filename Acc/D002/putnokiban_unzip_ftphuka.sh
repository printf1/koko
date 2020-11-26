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
dst=${2}                                                     # 退避元ファイルの格納場所
filename=${3}                                                # 退避先ファイル名
tuser=${4}                                                   # 退避元server ユーザID
tip=${5}                                                     # 退避元server IPアドレス
tpasswd=${6}                                                 # 退避元server パスワード
number=${7}                                                  # 作業依頼番号
tfilename=${8}                                               # 退避元ファイルフ名
tmode=${9}                                                   # FTP転送モード
mowner=${10}                                                 # 退避先ファイルの所有ユーザ

echo "$number putnokiban.sh Start！【`date '+%Y-%m-%d %H:%M:%S'`】" >> log_comment
#ステータス定義
STATUS101=101                                                # 退避元ファイルが存在するコード
STATUS666=666                                                # sshログイン成功コード

uname -n
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
    send "ls -l $filename\r"
    expect "#"
    send "exit\r"	
    
	spawn ftp $tip
    expect "name:"
    send "$tuser\r"
    expect "password:"
    send "$tpasswd\r"
    expect "ftp>"
    send "lcd $src\r"
	expect "ftp>"
	send "cd /workhome/home/ort/itcc_common/work/koko/yyyy_$number\r"
    expect "ftp>"
    send "$tmode\r"
    expect "ftp>"
    send "get $filename\r"
    expect "ftp>"
    send "bye\r"
    
	spawn ssh $tuser@$tip
    #expect "yes/no:"
    #send "yes\r"
    expect "password:"
    send "$tpasswd\r"
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
chown $mowner $src/$filename                #退避されたファイルの所有情報を変更する
echo "$number putnokiban.sh End！【`date '+%Y-%m-%d %H:%M:%S'`】"  >> log_comment
y=102                                                        #正常終了の戻り値を設定する
