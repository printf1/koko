package main

import (
	"fmt"
	"github.com/aliyun/alibaba-cloud-sdk-go/services/dysmsapi"
)

func main() {
	client, err := dysmsapi.NewClientWithAccessKey("cn-shanghai", "LTAI4G2A6BmxqNvSj13ZjVv1", "uxjlllip3MglxCbu6HxsIIMsYvWdtL")
	request := dysmsapi.CreateSendSmsRequest()
	request.Scheme = "https"
	//request.ConnectTimeout = 5
	//request.ConnectTimeout = 10
	request.PhoneNumbers = "18717952384"
	request.Domain = "dysmsapi.aliyuncs.com"
	request.SignName = "koko商城"
	//request.TemplateCode = "SMS_207496346" //模板编码
	//request.TemplateParam = "{\"code\":\"" + "654321" + "\"}"
	response, err := client.SendSms(request)
	if err != nil {
		fmt.Print(err.Error())
	}
	fmt.Printf("response is %#v\n", response)
}
