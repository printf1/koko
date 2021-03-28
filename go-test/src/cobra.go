package main

import (
	"github.com/spf13/cobra"
	"fmt"
	"os"
)

var rootCmd = &cobra.Command {
	Use: "xxx",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("hello, cobra")
	},
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}