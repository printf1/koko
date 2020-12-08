package v1

import (
	"github.com/gin-gonic/gin"
	"go-web/model"
	"go-web/utils/errmsg"
	"net/http"
	"strconv"
)

//用户发起重置请求
func ResetPassword(c *gin.Context) {
	//获取用户认证信息
	user, _ := strconv.Atoi(c.Query("username"))
	Tel_Number, _ := strconv.Atoi(c.Query("tel"))
	model.RedisInit()
	code := model.MessageCodeVertified()
	//redis存储code同时调用短信服务发送code
	model.MessageCodeSave(code, string(user))
	a := model.MessageCodeSend(code, string(Tel_Number))
	if a != errmsg.SUCCESS {
		a = errmsg.ERROR
	}
	c.JSON(http.StatusOK, gin.H{
		"status":  a,
		"data":    user,
		"massage": errmsg.GetErr(a),
	})
}

//接收用户输入code以及name
func MessageReceiveCode(c *gin.Context) {
	ReceiveCode, _ := strconv.Atoi(c.Query("receiveCode"))
	UserName, _ := strconv.Atoi(c.Query("username"))
	//调用redis判断是否过期
	info := model.MessageCodeCheck(string(ReceiveCode), string(UserName))
	if info == errmsg.SUCCESS {
		info = errmsg.SUCCESS
		model.EditUser(string(UserName))
	} else if info == errmsg.ERR_TOKEN_WRONG {
		info = errmsg.ERR_TOKEN_WRONG
	} else {
		info = errmsg.ERR_TOKEN_RUNTIME
	}
	c.JSON(http.StatusOK, gin.H{
		"status":  info,
		"data":    user,
		"massage": errmsg.GetErr(info),
	})
}
