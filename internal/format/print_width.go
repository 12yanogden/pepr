package format

import (
	"os"
	"strconv"

	"github.com/12yanogden/pepr/internal/file"
	"golang.org/x/term"
)

func print_width() (int, error) {
	termFd := int(os.Stdout.Fd())
	env, err := file.Env("../../.env")

	if err != nil {
		return -1, err
	}

	if term.IsTerminal(termFd) {
		maxWidth, err := strconv.Atoi(env["MAX_TERM_WIDTH"])

		if err != nil {
			return -1, err
		}

		terminalWidth, _, err := term.GetSize(termFd)

		if err != nil {
			return -1, err
		}

		return min(terminalWidth, maxWidth), nil
	}

	width, err := strconv.Atoi(env["LOG_WIDTH"])

	if err != nil {
		return -1, err
	}

	return width, nil
}
