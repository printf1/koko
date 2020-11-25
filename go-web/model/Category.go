package model

import (
	"github.com/jinzhu/gorm"
)

type Category struct {
	gorm.Model
	CName string `gorm: "type: varchar(20); not null" json: "cname"`
}
