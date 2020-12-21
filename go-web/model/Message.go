package model

import (
	"fmt"
	"github.com/aliyun/alibaba-cloud-sdk-go/services/dysmsapi"
	"go-web/utils"
	"go-web/utils/errmsg"
)

func AliMessageSend(Code, TelePhoneNumber string) (int, string, string, string, string) {
	_client, err := dysmsapi.NewClientWithAccessKey(
		fmt.Sprintf("%s", utils.RegionID),
		fmt.Sprintf("%s", utils.AccessKeyID),
		fmt.Sprintf("%s", utils.AccessKeySecret),
	)
	if err != nil {
		return errmsg.ALIYUN_MESSAGE_ERROR_SEND, "s", "h", "i", "b"
	}
	request := dysmsapi.CreateSendSmsRequest()
	request.Scheme = "http"
	request.PhoneNumbers = TelePhoneNumber
	request.Domain = "dysmsapi.aliyuncs.com"
	request.SignName = utils.SignName
	request.TemplateCode = utils.TemplateCode //模板编码
	request.TemplateParam = "{\"code\":\"" + Code + "\"}"
	response, err1 := _client.SendSms(request)
	if err1 != nil {
		fmt.Println(err1)
		return errmsg.ALIYUN_MESSAGE_ERROR_SEND, response.RequestId, response.Message, response.BizId, response.Code
	}
	if response.Code != "OK" {
		return errmsg.BUSINESS_LIMIT_CONTROL, response.RequestId, response.Message, response.BizId, response.Code
	}
	return errmsg.SUCCESS, response.RequestId, response.Message, response.BizId, response.Code
}
