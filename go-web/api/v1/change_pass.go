package v1

import (
	"github.com/gin-gonic/gin"
	"go-web/model"
	"go-web/utils/errmsg"
	"net/http"
	"strconv"
)

//用户发起重置请求
func ResetPass(c *gin.Context) {
	user, _ := strconv.Atoi(c.Query("username"))
	tel_Number, _ := strconv.Atoi(c.Query("tel"))
	model.RedisInit()
	code := model.Vertified_Code()
	//redis存储code同时调用短信服务发送code
	model.Codesave(code, string(user))
	model.Send_Code(code, string(tel_Number))
}

func Receive_Code(c *gin.Context) {
	receiveCode, _ := strconv.Atoi(c.Query("receiveCode"))
	//调用redis判断是否过期
	info := model.Check_Code(string(receiveCode))
	//if info == errmsg.ERR_TOKEN_RUNTIME {
	//	info = errmsg.ERR_TOKEN_RUNTIME
	//}
	//if info == errmsg.REVISE_SUCCESS {
	//	info = errmsg.REVISE_SUCCESS
	//}
	c.JSON(http.StatusOK, gin.H{
		"status":  info,
		"data":    user,
		"massage": errmsg.GetErr(info),
	})
}
