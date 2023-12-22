package main

import (
	"github.com/12yanogden/pepr/internal/command"
)

func main() {
	rules := []command.Rule{
		{
			Key:  "msg",
			Desc: "The condition for which there is a status",
		},
		{
			Key:  "status",
			Desc: "The status of the condition given",
		},
	}

	options := command.ParseOptions(rules)
}

/**
Args -------------------------------------------------------------------------------------------------
status
status?						// Must be last argument
status=default
status[]
status[]?					// Must be last argument
status[default values]		// Must be last argument, can optionally have '?' at end

Flags ------------------------------------------------------------------------------------------------
Flags: Boolean ---------------------------------------------------------------------------------------
-s							// Single dash flags must be boolean
-s|-S						// Single dash flags must be boolean
--status
-s|--status					// Single dash flags must be boolean
--sts|--status				// Other aliases can have values, other symbols applied at end

Flags: Variable --------------------------------------------------------------------------------------
--status=
--status=default
--status=[]
--status=[default values]

Note: All options are optional
*/

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
