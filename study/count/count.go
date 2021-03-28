package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strings"
)

func main() {
	buf, err := ioutil.ReadFile("en")
	if err != nil {
		log.Fatal(err)
	}
	statisticTimes := make(map[string]int)
	wordsLength := strings.Fields(string(buf))

	for counts, word := range wordsLength {
		//判断key是否存在，这个word是字符串，这个counts是统计的word的次数。
		word, ok := statisticTimes[word]
		if ok {
			word = word
			statisticTimes[wordsLength[counts]] = statisticTimes[wordsLength[counts]] + 1
		} else {
			statisticTimes[wordsLength[counts]] = 1
		}
	}
	for word, counts := range statisticTimes {
		fmt.Println(word, counts)
	}
}
