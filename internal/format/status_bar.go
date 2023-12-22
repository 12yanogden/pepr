package format

func StatusBar(msg string, spacer string, status string) (string, error) {
	statusBox := "[ " + status + " ]"
	fixedWidth := len(msg) + len(statusBox)
	spacerLength := 0
	width, err := print_width()

	if err != nil {
		return "", err
	}

	if width > fixedWidth {
		spacerLength = width - fixedWidth
	}

	spacerCount := spacerLength / len(spacer)
	spacerRemainder := spacerLength % len(spacer)

	for i := 1; i < spacerCount; i++ {
		spacer = spacer + spacer
	}

	spacer = spacer + spacer[:(spacerRemainder-1)]

	return msg + spacer + statusBox, nil
}
