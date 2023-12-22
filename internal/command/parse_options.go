package command

import (
	"os"
	"regexp"
)

type Rule struct {
	Key  string
	Desc string
}

type Option struct {
	key   string
	value interface{} // string or []string
	desc  string
}

const (
	ARG	= iota
	OPTIONAL_ARG
	ARG_WITH_DEFAULT
	OPTION
	OPTION_WITH_VALUE
)

func ParseOptions(rules []string) ([]Option, error) {
	args := os.Args[1:]
	options := []Option{}

	for _, arg := range args {
		isOption, err := isOption(arg)

		if err != nil {
			return options, err
		}

		if !isOption {
			for _, rule := range rules {
				if isOption(rule.Key) {

				}
			}
		}
	}

	
}

func isOption(arg string) (bool, error) {
	isOption, err := regexp.MatchString("--[a-zA-Z0-9=\?\*]+", arg)

	if err != nil {
		return false, err
	}

	return isOption, nil
}

/**
Argument
mail:send {user}

Optional argument
mail:send {user?}

Optional argument with default value
mail:send {user=foo}

Option
mail:send {--queue}

Option with value
mail:send {--queue=}

Option with default value
mail:send {--queue=default}

Option alias
mail:send {--Q|queue}

Array
mail:send {user*}

Optional array
mail:send {user?*}

Option array
mail:send {--id=*}' (mail:send --id=1 --id=2)

Input Descriptions
mail:send {user : The ID of the user}
*/
