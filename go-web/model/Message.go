package model

import (
	"fmt"
	"github.com/aliyun/alibaba-cloud-sdk-go/services/dysmsapi"
	"go-web/utils"
	"go-web/utils/errmsg"
)

func AliMessageSend(Code, TelePhoneNumber string) int {
	_client, err := dysmsapi.NewClientWithAccessKey(
		fmt.Sprintf("%s", utils.RegionID),
		fmt.Sprintf("%s", utils.AccessKeyID),
		fmt.Sprintf("%s", utils.AccessKeySecret),
	)
	if err != nil {
		return errmsg.ALIYUN_MESSAGE_ERROR_SEND
	}
	request := dysmsapi.CreateSendSmsRequest()
	request.Scheme = "https"
	request.PhoneNumbers = TelePhoneNumber
	request.SignName = "您正在执行忘记密码的操作，您的验证码是。该验证码120秒内有效，请不要把验证码泄露给其他人！"
	request.TemplateCode = "SMS_19586XXXX" //模板编码
	request.TemplateParam = "{\"code\":\"" + Code + "\"}"
	response, err1 := _client.SendSms(request)
	if err1 != nil {
		return errmsg.ALIYUN_MESSAGE_ERROR_SEND
	}
	if response.Code == "isv.BUSINESS_LIMIT_CONTROL" {
		return errmsg.BUSINESS_LIMIT_CONTROL
	}
	fmt.Println(Code, TelePhoneNumber)
	return errmsg.SUCCESS
}
