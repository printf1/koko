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
	return code
}

func MessageCodeSend(code, TelePhoneNumber string) int {
	a := AliMessageSend(code, TelePhoneNumber)
	if a != errmsg.SUCCESS {
		return errmsg.ERROR
	}
	return a
}

func GetUserTelePhoneNUmber(user string) string {
	var users User
	c := GetDB()
	c.Select("telephone").Where("username = ?", user).Limit(1).Find(&users)
	return users.TelePhoneNumber
}
