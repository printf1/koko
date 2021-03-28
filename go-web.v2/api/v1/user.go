package v1

import (
	"fmt"
	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"go-web/model"
	"go-web/utils/errmsg"
	"net/http"
	"strconv"
	//"github.com/golang/crypto/scrypt"
)

var user model.User

//添加用户
func UserAdd(c *gin.Context) {
	err := c.ShouldBindJSON(&user)
	if err != nil {
		fmt.Println(err)
		return
	}
	code := model.CheckUser(user.Username)
	if code == errmsg.SUCCESS {
		code = model.AddUser(&user)
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  code,
		"data":    user,
		"massage": errmsg.GetErr(code),
	})
}

//查询多个用户

//查询用户
func UserQuery(c *gin.Context) {
	pageSize, _ := strconv.Atoi(c.Query("pagesize"))
	pageNum, _ := strconv.Atoi(c.Query("pagenum"))
	if pageSize == 0 {
		//不做分页
		pageSize = -1
	}
	if pageNum == 0 {
		pageNum = -1
	}
	code, data := model.GetUsers(pageSize, pageNum)

	c.JSON(http.StatusOK, gin.H{
		"status":  code,
		"data":    data,
		"massage": errmsg.GetErr(code),
	})
}

//编辑用户
func UserEdit(c *gin.Context) {
	user, _ := strconv.Atoi(c.Query("username"))
	role, _ := strconv.Atoi(c.Query("role"))
	code := model.CheckUser(string(user))
	if code == errmsg.SUCCESS {
		code = model.EditUser(string(user), string(role))
	}
	c.JSON(http.StatusOK, gin.H{
		"status":  code,
		"data":    user,
		"massage": errmsg.GetErr(code),
	})
}

//删除用户
func UserDel(c *gin.Context) {
	user, _ := strconv.Atoi(c.Query("username"))
	code := model.CheckUser(string(user))
	if code == errmsg.SUCCESS {
		code = model.DelUser(string(user))
	}
	c.JSON(http.StatusOK, gin.H{
		"status":  code,
		"data":    user,
		"massage": errmsg.GetErr(code),
	})
}
