package model

import "go-web/utils/errmsg"

func Codesave(code, username string) {
	RedisInit().Set(username, code)

}

func Check_Code(receivecode string) int {
	//判断redis是否存在code
	data := RedisInit().Get(receivecode)
	if data == nil {
		return errmsg.ERR_TOKEN_RUNTIME
	}
	return errmsg.REVISE_SUCCESS
}
