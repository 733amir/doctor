package main

import (
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"sync"
)

func pathsWalker(paths []string) <-chan string {
	if c.Log {
		fmt.Println("Walker gotta walk!")
	}

	wg := sync.WaitGroup{}
	wg.Add(len(paths))
	files := make(chan string)
	for _, p := range paths {
		go func(p string) {
			defer wg.Done()
			pathWalker(p, files)
		}(p)
	}

	go func() {
		wg.Wait()
		close(files)
	}()

	return files
}

func pathWalker(path string, files chan<- string) {
	if c.Log {
		fmt.Printf("Walking: %v\n", path)
	}

	if _, err := os.Stat(path); err != nil {
		log.Printf("err: %v", err)
	}

	err := filepath.WalkDir(
		path,
		func(path string, d fs.DirEntry, err error) error {
			if err != nil {
				return err
			}

			n := d.Name()
			if Contains(c.Ignores, n) {
				fmt.Printf("Walking: ignored %v\n", n)
				return filepath.SkipDir
			}

			if i, err := d.Info(); err != nil {
				return err
			} else if i.IsDir() {
				return nil
			}

			// TODO need more flexibility here.
			if len(n) < 4 || n[len(n)-4:] != ".php" {
				return nil
			}

			files <- path
			return nil
		},
	)
	if err != nil {
		log.Printf("err: %v", err)
	}
}
