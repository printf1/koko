#/bin/sh
function outlog
{

    # ログ名が設定されていない場合呼ばれているシェルをログ名に使用
    if [ ! "${log_name}" ]; then
        shname=`basename ${0}`
        log_name=`echo ${shname} | sed "s/.sh//g"``date "+%Y%m%d%H%M%S"`
    fi

    shname=`basename ${0}`

    # ログが存在しない場合作成し権限を変更
    if [ ! -f ${LOG_DIR}/${log_name}.log ]; then
        touch ${LOG_DIR}/${log_name}.log
        chmod 777 ${LOG_DIR}/${log_name}.log
    fi

    logdate=`date "+%Y-%m-%d %H:%M:%S"`
    
    PARM_CNT=$#
    if [ ! $PARM_CNT -eq 1 ]
    then
    	echo ${logdate} "E" ${shname}  "ログ出力エラー、ログパラメータ数が2ではない" >> ${LOG_DIR}/${log_name}.log
    	return 1
    fi
    
    
    log_msg=$1
    
    # 引数の1個目から取得するために初期値を2としている
    
    logmsg="${logdate} ${shname} ${log_msg}"
    echo ${logmsg} >> ${LOG_DIR}/${log_name}.log
    
    return 0
}
