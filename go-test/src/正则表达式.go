package main

import (
	"regexp"
	"fmt"
	"encoding/json"
)

func main()  {

	koko := `
            <div>koko</div>
            <div>
             hihi
             高辉
             帅桑
             哈哈哈哈
            </div>
            <div>
             啦啦啦啦啦
             略略略
             嘿嘿嘿
            </div>
            <div>哦豁，或咯把戏</div>
            `
	//reg := regexp.MustCompile(`a.c`)
	reg := regexp.MustCompile(`<div>(?s:(.*?))</div>`)
	if reg == nil {
		fmt.Println("o_o:err")
		return
	}
	a := reg.FindAllString(koko, -1)
	fmt.Printf("a=%s", a)
	fmt.Println("---------------------------------------------")
	type it struct {
		Company string `json:"company"`
		Subject []string `json:"subject"`
		Isok bool `json:",string"`
		Price float64 `json:",string"`
	}
    s := it{"Chiju", []string{"Go", "C", "Python"}, true, 32.66}

    o, err := json.MarshalIndent(s, "", " ")
    if err != nil {
    	fmt.Println("err: ", err)
    	return
	}
	fmt.Println("\no: ", string(o))
    fmt.Println("---------------------------------------------")
    r := make(map[string]interface{},4)
     r["Company"] = "Chiju"
     r["Subject"] = []string{"Go", "C", "Python"}
     r["Isok"] = true
     r["Price"] = 32.66

     k, err := json.MarshalIndent(r, "", " ")
     if err != nil {
     	return
	 }
     fmt.Println("k: ", string(k))
	fmt.Println("---------------------------------------------")
     y := `{
        "Company": "Chiju",
        "Subject": [
           "Go",
           "C",
           "Python"
        ],
        "Isok": "true",
        "Price": "32.66"
     }`
	var tmp it
     er := json.Unmarshal([]byte(y), &tmp)
     if er != nil {
     	//fmt.Println("err: ", err)
     	return
	 }
     fmt.Printf("tmp: %+v", tmp)
	fmt.Println("\n---------------------------------------------")
     ma := make(map[string]interface{},4)
     eor := json.Unmarshal([]byte(y), &ma)
     if eor != nil {
     	return
	 }
	 fmt.Printf("ma: %+v", ma)
     //类型断言取value

}
