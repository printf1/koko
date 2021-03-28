package main

import "fmt"

func printer(b bool) {
	switch b {
	case true:
		fmt.Printf("🎄")
	case false:
		fmt.Printf(" ")
	}
}

func main() {
	fmt.Println()
	var flag bool = false
	for i := 0; i < 13; i++ {
		for j := 0; j < 20; j++ {
			if i < 10 {
				switch {
				case j-i > 10:
					flag = false
				case i+j > 9:
					flag = true
				default:
					flag = false
				}
				printer(flag)
				if j == 19 {
					fmt.Printf("\n")
				}
			} else {
				switch {
				case j-i > 0:
					flag = false
				case i+j > 19:
					flag = true
				default:
					flag = false
				}
				printer(flag)
				if j == 19 {
					fmt.Printf("\n")
				}
			}
		}
	}
	fmt.Println("      ~圣诞快乐~ \n")
}
