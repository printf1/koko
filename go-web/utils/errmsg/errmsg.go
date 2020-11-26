package errmsg

const (
	SUCCESS        = 200
	REVISE_SUCCESS = 201
	ERROR          = 500
	CHECK_SUCCESS  = 202
	//User相关code(300~499)
	USER_NOT_EXIST       = 300
	PASSWORD_WRONG       = 301
	USER_EXIST           = 302
	ERR_TOKEN_NOT_EXIST  = 303
	ERR_TOKEN_RUNTIME    = 304
	ERR_TOKEN_WRONG      = 305
	ERR_TOKEN_TYPE_WRONG = 306
	MYSQL_CONNECT_FAILED = 307
	REDIS_CONNECT_ERROR  = 308
	REDIS_ERROR_SAVE     = 309
	//Article相关code(501~700)

	//Category相关code(701~900)

)

var codeMsg = map[int]string{
	SUCCESS:              "登录成功，Login Successful",
	ERROR:                "登录失败，Login failed",
	CHECK_SUCCESS:        "验证成功",
	REVISE_SUCCESS:       "密码重置成功",
	MYSQL_CONNECT_FAILED: "mysql连接不可用",
	REDIS_CONNECT_ERROR:  "redis连接不可用",
	USER_NOT_EXIST:       "用户名不存在，请重新输入",
	PASSWORD_WRONG:       "密码错误，请重新输入",
	USER_EXIST:           "用户名已被使用， 请重新输入",
	ERR_TOKEN_NOT_EXIST:  "验证码不存在，请重新输入",
	ERR_TOKEN_RUNTIME:    "验证码已失效，请重新发送验证码",
	ERR_TOKEN_WRONG:      "验证码错误，请重新输入",
	ERR_TOKEN_TYPE_WRONG: "验证码类型错误，请重新输入",
	REDIS_ERROR_SAVE:     "验证码存储失败",
}

func GetErr(code int) string {
	return codeMsg[code]
}
