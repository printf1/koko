#/bin/sh
function outlog_func
{

  #ログ名が設定されていない場合呼ばれているシェルをログ名に使用
  if [ ! "${log_name}" ]; then
    shname=`basename ${0}`
    log_name=`echo ${shname} | sed "s/.sh//g"`
  fi

  shname=`basename ${0}`

  #ログが存在しない場合作成し権限を変更
  if [ ! -f ${LOG_DIR}/${log_name}.log ]; then
    touch ${LOG_DIR}/${log_name}.log
    chmod 777 ${LOG_DIR}/${log_name}.log
  fi

  PARM_CNT=$#

  logdate=`date "+%Y-%m-%d %H:%M:%S"`

  if [ ! $PARM_CNT -eq 2 ]
  then
    echo ${logdate} "E" ${shname}  "ログ出力エラー、ログパラメータ数が2ではない" >> ${LOG_DIR}/${log_name}.log
    return 1
  fi
  
  errorlevel=$1
  
  log_msg=$2
  
  #引数の2個目から取得するために初期値を2としている
  
  logmsg="${logdate} ${errorlevel} ${shname} ${log_msg}"
  if [ ${errorlevel} = "D" ]; then
    if [ x${DEBUG} = x"ON" ]; then 
      echo ${logmsg} >> ${LOG_DIR}/${log_name}.log
    fi
  else
    echo ${logmsg} >> ${LOG_DIR}/${log_name}.log
  fi

  return 0
}

#申請領域がEP又はEP海外の場合、環境変数「LANG」と「NLS_LANG」を特定値に設定する
function langset_func
{
  if [ "$1" == "${EP}"  -o  "$1" == "${EPABROAD}" ]
  then
    export LANG='ja_JP.UTF-8'
    export NLS_LANG='JAPANESE_JAPAN.AL32UTF8'
  fi
}

#get contents from log file of sql_select.sh   ログファイルにエラー内容の分析
function db_select_log_analiz
{
  outlog_func D "db_select_log_analiz is start."

  log_file_1=$1
  log_file_2=$2
  path_dir=$3
  #errMsg1="error:sql_select.sh is already running." #sql_select.shの中にコメントアウトされた。
  errMsg1="error:No.6 parameter is not -z"
  errMsg2="error:parameter less"
  errMsg3="error:parameter more"
  errMsg4="error:user not exists"
  errMsg5="error:host name or DB instance"
  errMsg6="error:SQL file not exists"
  errMsg7="error:directory not exists" 
  errMsg8="exists in ${path_dir}" #自動化後、格納先ディレクトリに既に存在する場合に出力される同名のファイル名が不可能でしょう。 error:[出力ファイル名] in [格納先ディレクトリ名]
  errMsg9="ORA-*" #oracle error

  errOccur=0
  #find out whether there's any error message of errMsg1~errMsg9 in log file 
  errCount=`cat ${log_file_1} | grep -cE "${errMsg1}|${errMsg2}|${errMsg3}|${errMsg4}|${errMsg5}|${errMsg6}|${errMsg7}|${errMsg8}"`
  #echo "DB処理前、チェックエラーの数量統計："${errCount}
  outlog_func D  "DB処理前、チェックエラーの数量統計："${errCount}
  if [ $errCount -gt 0 ];then
    #errors occur.
    outlog_func E "db_select_log_analiz check error happen. errOccur=1"
    errOccur=1  
  else
    correctMsgCount=`cat ${log_file_2} | grep -cE "${errMsg9}"`
    #echo "DB処理中、エラーの数量統計："${correctMsgCount}
    outlog_func D  "DB処理中、エラーの数量統計："${correctMsgCount}
    if [ $correctMsgCount -gt 0 ];then
      #errors occur.
      outlog_func E "db_select_log_analiz check error happen. errOccur=2"
      errOccur=2 
    fi
  fi	
  outlog_func D "db_select_log_analiz is end."

  return $errOccur
}

function db_log_analiz
{
  outlog_func D "db_log_analiz is start."
  log_file_1=$1
  log_file_2=$2
  update_count=$3
  update_pattern=$4
  errMsg1="error:parameter less"
  errMsg2="error:parameter more"
  errMsg3="error:host name or DB instance"
  errMsg4="error:SQL file not exists"
  errMsg5="error:4th parameter is not '-r','-commit','-rc'"
  errMsg6="ORA-*"
  correctMsg1="${update_count}行が更新されました"
  correctMsg2="${update_count}行が削除されました"
  correctMsg3="ロールバックが完了しました"
  correctMsg4="コミットが完了しました"
  correctMsg5="${update_count} row updated"
  correctMsg6="${update_count} row deleted"
  correctMsg7="Rollback complete"
  correctMsg8="Commit complete"
  errOccur=0
  #find out whether there's any error message of errMsg1~errMsg11 in log file of sql_update.sh
  errCount=`cat ${log_file_1} | grep -cE "${errMsg1}|${errMsg2}|${errMsg3}|${errMsg4}|${errMsg5}|${errMsg6}"`
  if [ $errCount -gt 0 ];then
    #errors occur.
    outlog_func E "db_log_analiz check error happen. errOccur=1"
    errOccur=1  
  else
    if [ "${update_pattern}" = "-r" ];then	  
  	#Rollback:-rで起動する場合、ログに下記のキーワードがHitしなかったら、エラーと判断
  	correctMsgCount=`cat ${log_file_2} | grep -cE "${correctMsg1}|${correctMsg2}|${correctMsg3}|${correctMsg5}|${correctMsg6}|${correctMsg7}"`
  	correctMsgCount_1=`cat ${log_file_2} | grep -cE "${errMsg6}"`
  	if [ $correctMsgCount -eq 0 ] || [ ! $correctMsgCount_1 -eq 0 ];then
  	  #errors occur.
  	  outlog_func E "db_log_analiz check error happen. errOccur=2"
  	  errOccur=2
  	fi
    elif [ "${update_pattern}" = "-commit" ];then   
  	#Rollback:-cで起動する場合、ログに下記のキーワードがHitしなかったら、エラーと判断
  	correctMsgCount=`cat ${log_file_2} | grep -cE "${correctMsg4}|${correctMsg8}"`
  	correctMsgCount_1=`cat ${log_file_2} | grep -cE "${errMsg6}"`
  	echo ${correctMsgCount}
  	if [ $correctMsgCount -eq 0 ] || [ ! $correctMsgCount_1 -eq 0 ];then
  	  #errors occur.
  	  outlog_func E "db_log_analiz check error happen. errOccur=3"
  	  errOccur=2
  	fi
    fi
  fi	
  outlog_func D "db_log_analiz is end."
  return $errOccur
}

urlencode() {
  local LANG=C
  local length="${#1}"
  i=0
  while :
  do
  [ $length -gt $i ]&&{
  local c="${1:$i:1}"
  case $c in
  [a-zA-Z0-9.~_-]) printf "$c" ;;
  *) printf '%%%02X' "'$c" ;;
  esac
  }||break
  let i++
  done
}
