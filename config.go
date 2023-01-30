package main

import (
	"encoding/json"
	"os"
)

type config struct {
	Log     bool
	Ignores []string `json:"ignores"`
}

func loadConfig() (c config) {
	// default values
	c.Ignores = []string{"node_modules"}
	c.Log = false

	f, err := os.Open("config.json")
	if err != nil {
		return c
	}

	_ = json.NewDecoder(f).Decode(&c)
	return c
}

func Contains(a []string, x string) bool {
	for _, n := range a {
		if x == n {
			return true
		}
	}
	return false
}
