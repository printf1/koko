package model

import (
	"fmt"
	"github.com/jinzhu/gorm"
	"go-web/utils/errmsg"
)

type Message_obj struct {
	gorm.Model
	RequestID string `gorm: "type: varchar(50); not null" json:"requestid"`
	Message   string `gorm: "type: varchar(100); not null" json:"message"`
	BizID     string `gorm: "type: varchar(30); not null" json:"bizid"`
	Code      string `gorm: "type: varchar(4); not null" json:"code"`
	Phone     string `gorm: "type: varchar(11); not null" json:"phone"`
}

func MessageObjectSave(requestid, message, bizid, code, phone string) interface{} {
	c := GetDB()
	var mess Message_obj
	mess.Code = code
	mess.Phone = phone
	mess.BizID = bizid
	mess.RequestID = requestid
	mess.Message = message
	err := c.Create(&mess).Error
	if err != nil {
		fmt.Println(err)
		return errmsg.ALIYUN_MESSAGE_ERROR_SEND
	}
	return nil
}
