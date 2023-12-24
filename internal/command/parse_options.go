package command

import (
	"os"
	"regexp"
)

type Rule struct {
	Def  string
	Desc string
}

type Input struct {
	Rule		*Rule
	Tokens 		[]string	// type => value
	Optional	bool
	Value		string
	ArrayValue		[]string

}

const (
	IS_OPTION = iota
	KEY
	BOOLEAN_VALUE
	STRING_VALUE
	ARRAY_VALUE
	IS_OPTIONAL
	DEFAULT_BOOLEAN
	DEFAULT_STRING
	DEFAULT_ARRAY
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