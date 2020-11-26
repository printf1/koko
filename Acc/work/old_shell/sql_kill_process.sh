#!/bin/sh
#--SQL Kill Process--
_exec_ksh=/workhome/itcc/work/ini/batch_common.conf
if [ ! -f ${_exec_ksh} ]
then
    echo "環境設定ファイルが存在しません"
    exit 1
fi
. ${_exec_ksh}

para=$1
SHDIR="${OLD_SHELL_PATH}"
PROFILE=".Sql_Kill_process_${para}_$$"
PROFILE_AFTER=".Sql_Kill_process_${para}_$$_After"
OP_USER="op5000"
RETURN_CODE=0

DeleteFile(){
  #ファイルの削除
  if [  -e ${PROFILE} ]; then
    rm ${PROFILE}
  fi

  #ファイルの削除
  if [  -e ${PROFILE_AFTER} ]; then
    rm ${PROFILE_AFTER}
  fi
}

# 引数なし
if [ "${para}" == "" ]; then
  echo "SQL抽出/更新処理のpidを引数としてください。"
  exit 1
fi

# 引数指定したプロセスなし、
PROCESS_COUNT=`ps h -ef | sudo -u ${OP_USER} /usr/bin/awk -v pid=${para} '$2==pid {print}' | wc -l` 
if [ ${PROCESS_COUNT} -eq 0 ]; then
  echo "SQL抽出/更新処理はすでに流れ切っています。"
  exit 1
fi

# ① プロセスリスト取得
# 形式： sh,482 /workhome/home/cdcadmin/sh/sql_select_pre.sh eedbh01w 121031/402_monthly_shodan3.sql ...
#          mqsh,499 -c...
#              mqsh,500 /workhome/home/cdcadmin/sh/sql_select_exe...
#                  mqsqlplus,505 -s
# ② SQL抽出・更新に関するプロセスをフィルター
# ③ SQL抽出・更新に関するプロセスのPID取得
# ④ psコマンドより、プロセス詳細を取得する
# 形式： op5000     505   500  0 00:15 pts/53   00:00:00 /opt/oracle/product/11.2.0/client_1/bin/sqlplus -s  
# ⑤ awkより、UID、PID、CMD取得し、一時ファイルに格納する
# 形式：op5000 505 /opt/oracle/product/11.2.0/client_1/bin/sqlplus
pstree -a -p ${para} | sudo -u ${OP_USER} /usr/bin/awk -F ',' '/sqlplus|(sql\_(update|select)((\_call|\_pre)?+(\.sh))|(\_exe))/{print $2}' | sudo -u ${OP_USER} /usr/bin/awk '{print $1}' | while read LINE ; do
  # プロセス詳細(UID PID CMD)をファイルに出力する
  ps h -ef | sudo -u ${OP_USER} /usr/bin/awk -v pid=${LINE} '$2==pid {print $1,$2,$9,$10}' >> ${PROFILE}

done

# 引数で指定したプロセスがSQL抽出/更新処理に関連するものか
if [ ! -s ${PROFILE} ]; then
  echo "引数がSQL抽出/更新処理のものではありません。引数を再度確認してください。"
  DeleteFile
  exit 1
fi

# sqlplusプロセスのPIDを取得する
PID=`cat ${PROFILE} | grep sqlplus | sudo -u ${OP_USER} /usr/bin/awk '{print $2}'` 

# sqlplusプロセスのPIDが取得できるか
if [ "${PID}" == "" ]; then
  echo "sqlplusは存在しません。sqlplus以外の残存プロセスがあります。運用基盤に連絡してください。"
  DeleteFile
  exit 1
else
  while read PLINE;do
    KILL_PID=`echo ${PLINE} | sudo -u ${OP_USER} /usr/bin/awk '{print $2}'`
    # プロセス打ち切りをする
    sudo -u ${OP_USER} $SHDIR/kill_process.sh ${KILL_PID}
    KILL_CODE=$?
    if [ ${KILL_CODE} -ne 0 ]; then
      RETURN_CODE=${KILL_CODE}
    fi
  done < ${PROFILE}
fi

# 打ち切り結果検証
# 打ち切りしたプロセスをリストしてみる
cat ${PROFILE} | sudo -u ${OP_USER} /usr/bin/awk '{print $2}' | while read LINE ; do
  ps h -ef | sudo -u ${OP_USER} /usr/bin/awk -v pid=${LINE} '$2==pid {print $1,$2,$9,$10}' >> ${PROFILE_AFTER}
done

# ファイル存在
if [ -e ${PROFILE_AFTER} ]; then
  # 打ち切り前後のプロセスリストを比較する
  if [ `cat ${PROFILE} ${PROFILE_AFTER} | sort | uniq -d | wc -l` -gt 0 ]; then
    if [ `cat ${PROFILE} ${PROFILE_AFTER} | sort | uniq -d | grep sqlplus | wc -l` -gt 0 ]; then
      echo "SQL抽出/更新処理を打ち切れませんでした。運用基盤に連絡してください。"
      DeleteFile
      exit 1
    else
      echo "sqlplus以外の残存プロセスがあります。運用基盤に連絡してください。"
      DeleteFile
      exit 1
    fi
  fi
fi

if [ ${RETURN_CODE} -ne 0 ]; then
  echo "プロセス打ち切る時にエラーが発生しました。運用基盤に連絡してください。"
  exit 1
fi

echo "SQL抽出/更新処理を打ち切りました。"

DeleteFile
exit 0
