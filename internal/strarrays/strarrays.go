package strarrays

import (
	"slices"
	"strings"
)

func ToString(a []string) string {
	out := "[\n    "

	out += strings.Join(a, "\n    ")

	out += "\n]\n"

	return out
}

func ToArray(s string) []string {
	// Remove brackets
	s = strings.TrimLeft(s, "[\n    ")
	s = strings.TrimRight(s, "\n]")

	// Convert to array and return
	return strings.Split(s, "\n    ")
}

func Equals(a1, a2 []string) bool {
	return slices.Equal(a1, a2)
}
