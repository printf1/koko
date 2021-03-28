package main

import "fmt"

func main() {
	a := []int{1, 8, 6, 10, 3, 5, 19, 59, 28}
	for i := 0; i < len(a)-1; i++ {
		for j := 0; j < len(a)-i-1; j++ {
			if a[j] > a[j+1] {
				a[j], a[j+1] = a[j+1], a[j]
			}
		}
	}
	fmt.Println(a)
}
