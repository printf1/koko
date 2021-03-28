package main

import (
	"fmt"
	"github.com/spf13/cobra"
)

var try = &cobra.Command{
	Use: "try",
	Short: "my name is koko",
	Long: "my age is 18 years old",
	Run: func(try *cobra.Command, args []string) {
		fmt.Println("my name is koko, age 18")
	},
}

