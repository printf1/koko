package main

import (
	"fmt"
	"reflect"
)

/*
var (
	i,mth,j,da,k,l,m,n int
)
func main() {
	var a [5]int
	fmt.Println("\na=", a)
	b := [5]int{1, 2, 3, 4}
	for i, mth := range b {
		fmt.Printf("\nmth[%d]=%d", i, mth)
	}

	c:=[5]int{0: 3, 1: 4, 3: 5}
	for j, da := range c {
		fmt.Printf("\nmth[%d]=%d", j, da)

	}

	//var h [4][5]int
	d := [4][5]int{
		{1, 2, 3, 4, 5},
		{6, 7, 9, 10},
		{11,  15},
		{16, 17, 20},
	}
	//for k,l,m := range d{
		//fmt.Printf("mth[%d][%d]=%d",k,l,m)
	//}
	fmt.Printf("\n")
	for k=0 ; k<4; k++ {

		for l=0 ; l<5 ; l++ {
		//fmt.printf("d[%d][%d]=", d[k][l])
        fmt.Printf("d[%d][%d]=%d,",k,l, d[k][l])
		}
		fmt.Printf("\n")
	}

	rand.Seed(time.Now().UnixNano())
	for n=1; n<6; n++ {
		fmt.Printf("\n随机数[%d]：%d",n,rand.Intn(100))
	}





}
*/

func main() {
	var b uint8
	b = 255
	a := "stringab"
	fmt.Println(reflect.TypeOf(a))
	for _, v := range a {
		fmt.Println(reflect.TypeOf(v))
		fmt.Println(string(v), b)
	}
}
