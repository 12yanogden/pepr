package main

import (
	"github.com/12yanogden/pepr/internal/command"
)

func main() {
	rules := []command.Rule{
		{
			Def:  "msg",
			Desc: "The condition for which there is a status",
		},
		{
			Def:  "status",
			Desc: "The status of the condition given",
		},
	}

	options := command.ParseOptions(rules)
}
