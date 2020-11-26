package model

import (
	"fmt"
	"github.com/aliyun/alibaba-cloud-sdk-go/sdk"
	"go-web/utils/errmsg"
)

func AliMessageSend(Code, Tel_Number string) int {
	sdk.NewClient()
	fmt.Println(Code, Tel_Number)
	return errmsg.SUCCESS
}
