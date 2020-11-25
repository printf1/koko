package model

import (
	"fmt"
	"github.com/aliyun/alibaba-cloud-sdk-go/sdk"
)

func Send(code, tel_number string) {
	sdk.NewClient()
	fmt.Println(code, tel_number)

}
