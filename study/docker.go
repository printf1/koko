package main
import (
	"fmt"
	"github.com/spf13/cobra"
	"os"
	"strings"
)

func main()  {
	var cmdPull = &cobra.Command{
		Use: "pull [OPTIONS] NAME[:TAG|@DIGEST]",
		Short: "Pull an image or repository from a registry",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println("Pull: " + strings.Join(args, " "))
		},
	}

	var rootCmd = &cobra.Command{Use: "docker"}
	rootCmd.AddCommand(cmdPull)
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
