package model

import (
	"fmt"
	"go-web/utils/errmsg"
	"math/rand"
	"time"
)

func MessageCodeVertified() string {
	rand.Seed(time.Now().UnixNano())
	code := fmt.Sprintf("%06v", rand.Intn(1000000))
	fmt.Printf("验证码为: %s\n", code)
	return code
}

func MessageCodeSend(code, TelePhoneNumber string) int {

	a, b, c, d, e := AliMessageSend(code, TelePhoneNumber)
	//开始存储短信返回值
	if a != errmsg.SUCCESS {
		x := MessageObjectSave(b, c, d, e, TelePhoneNumber)
		if x != nil {
			return errmsg.ALIYUN_MESSAGE_ERROR_SEND
		}
		return errmsg.ERROR
	}
	x := MessageObjectSave(b, c, d, e, TelePhoneNumber)
	if x != nil {
		return errmsg.ALIYUN_MESSAGE_ERROR_SEND
	}
	return a
}

func GetUserTelePhoneNumber(user string) string {
	var users User
	c := GetDB()
	c.Select("phone").Where("username = ?", user).Limit(1).Find(&users)
	return users.Phone
}
