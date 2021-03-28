package model

type Article struct {
	Catagory Catagory
	Title string `sql:"type: varchar(100);not null" json:"title"`
	Cid int `sql:"type: int;not null" json:"cid"`
	Descr string `sql:"type: varchar(200)" json:"descr"`
	Content string `sql:"type: longtext" json:"content"`
	Img string `sql:"type: varchar(100)" json:"img"`
}
