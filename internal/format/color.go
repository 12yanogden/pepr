package format

import (
	"os"
	"runtime"

	"golang.org/x/term"
)

var RESET = "\033[0m"
var RED = "\033[31m"
var GREEN = "\033[32m"
var YELLOW = "\033[33m"
var BLUE = "\033[34m"
var PURPLE = "\033[35m"
var CYAN = "\033[36m"
var GRAY = "\033[37m"
var WHITE = "\033[97m"

// Return true if colors should be used, else false
func isColorable() bool {
	return runtime.GOOS != "windows" && term.IsTerminal(int(os.Stdout.Fd()))
}

// Colorize the message given to red
func Red(msg string) string {
	if isColorable() {
		msg = RED + msg + RESET
	}

	return msg
}
