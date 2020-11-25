package model

import (
	"fmt"
	"math/rand"
	"time"
)

func Vertified_Code() string {
	rand.Seed(time.Now().UnixNano())
	code := fmt.Sprintf("%06v", rand.Intn(1000000))
	return code
}

func Send_Code(code, tel_number string) {
	Send(code, tel_number)
}
