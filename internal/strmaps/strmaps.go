package strmaps

import (
	"fmt"
	"slices"
)

// Return true if the string maps given are equal, else false. O(nlogn)
func Equals(m1 map[string]string, m2 map[string]string) bool {
	// Confirm equal lengths
	if len(m1) != len(m2) {
		return false
	}

	// Get sorted values for each map, O(nlogn)
	keys1 := SortedKeys(m1)
	keys2 := SortedKeys(m2)

	// Compare keys for equality, O(n)
	for i := 0; i < len(keys1); i++ {
		if keys1[i] != keys2[i] {
			return false
		}
	}

	// Get sorted values for each map, O(nlogn)
	values1 := SortedValues(m1)
	values2 := SortedValues(m2)

	// Compare values for equality, O(n)
	for i := 0; i < len(values1); i++ {
		if values1[i] != values2[i] {
			return false
		}
	}

	return true
}

// Return keys of the string map given
func Keys(m map[string]string) []string {
	var keys []string

	for key := range m {
		keys = append(keys, key)
	}

	return keys
}

// Return a sorted array of keys from the string map given
func SortedKeys(m map[string]string) []string {
	keys := Keys(m)

	slices.Sort(keys)

	return keys
}

// Return values of the string map given
func Values(m map[string]string) []string {
	var values []string

	for _, value := range m {
		values = append(values, value)
	}

	return values
}

// Return a sorted array of values from the string map given
func SortedValues(m map[string]string) []string {
	values := Values(m)

	slices.Sort(values)

	return values
}

// Return a string representation of a string map
func ToString(m map[string]string) string {
	out := ""

	for key, value := range m {
		out += key + ": " + value + "\n"
	}

	return out
}

// Print a string representation of a string map
func Print(m map[string]string) {
	fmt.Printf("%s", ToString(m))
}