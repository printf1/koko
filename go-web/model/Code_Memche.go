package model

import (
	"go-web/utils/errmsg"
	//"reflect"
	"time"
)

func MessageCodeSave(code, username string) int {
	defer PoolGet().Close()
	//if err := RedisInit().Ping(context.Background()).Err(); err != nil {
	//	return errmsg.REDIS_CONNECT_ERROR
	//}
	//err1 := RedisInit().Set(context.Background(), username, code, 120*time.Second).Err()
	_, err1 := PoolGet().Do("set", username, code, "EX", 120*time.Second)
	if err1 != nil {
		return errmsg.REDIS_ERROR_SAVE
	}
	return errmsg.SUCCESS
}

func MessageCodeCheck(code, UserName string) int {
	defer PoolGet().Close()
	//判断redis是否存在code
	//if err := RedisInit().Ping(context.Background()).Err(); err != nil {
	//	return errmsg.REDIS_CONNECT_ERROR
	//}
	//data := RedisInit().Get(context.Background(), UserName)
	//反射获取结构体值
	//typ := reflect.TypeOf(data)
	//val := reflect.ValueOf(data) //获取reflect.typeof类型
	//ReceiveDataLength := val.NumField()
	//ReturnValue := val.Field(ReceiveDataLength - 1)
	data, _ := PoolGet().Do("get", UserName)
	if data == nil {
		return errmsg.ERR_TOKEN_RUNTIME
	} else if code != data {
		return errmsg.ERR_TOKEN_WRONG
	}
	return errmsg.SUCCESS
}
