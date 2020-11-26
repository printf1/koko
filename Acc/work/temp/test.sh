#!/bin/bash
#logfile=sql_update_03_1.log
#tempfile=sql_update_03_1.log
tempfile="simple.log"
#iconv -f UTF-8 -t UTF-8 ${logfile} -o ${tempfile}
#re=`cat ${tempfile} |awk '{printf "%s%0a" , $0}'`
#re=${re//" "/"%20"}
#rm ${tempfile}
#echo $re

#log1=`get_log_str sql_update_03_1.log`
#echo $log1
urlencode() {
  local LANG="ja-JP.UTF-8"
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

urldecode(){
  u="${1//+/ }"
  echo -e "${u//%/\\x}"
}
#urlencode "111 22 ;'$;"

#logfile=sql_select_7719_2.log
tempfile="test.log"
#iconv -f SJIS -t UTF-8 ${logfile} -o ${tempfile}
te=`cat ${tempfile}`
re=`echo $te`
echo $re
ce=`urlencode "$re"`
echo "$ce"
