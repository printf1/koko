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

func MessageCodeSend(code, Tel_Number string) int {
	a := AliMessageSend(code, Tel_Number)
	if a != errmsg.SUCCESS {
		return errmsg.ERROR
	}
	return a
}
