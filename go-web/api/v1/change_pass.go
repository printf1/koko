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
	model.RedisInit()
	user := c.Request.URL.Query().Get("username")
	//fmt.Printf("用户输入为: %s\n", user)
	TelePhoneNumber := model.GetUserTelePhoneNumber(user)
	//fmt.Printf("电话: %s", TelePhoneNumber)
	code := model.MessageCodeVertified()
	//redis存储code同时调用短信服务发送code
	x := model.MessageCodeSave(code, user)
	if x == errmsg.SUCCESS {
		a := model.MessageCodeSend(code, TelePhoneNumber)
		if a != errmsg.SUCCESS {
			x = errmsg.ERROR
		}
	}
	c.JSON(http.StatusOK, gin.H{
		"status":  x,
		"data":    user,
		"massage": errmsg.GetErr(x),
	})
}

//接收用户输入code以及name
func InformationCommit(c *gin.Context) {
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
