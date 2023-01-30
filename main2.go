package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"regexp"
	"sync"

	"github.com/733amir/doctor/grouper"
	"github.com/733amir/doctor/linarian"
)

var c = loadConfig()
var doctorRegex = regexp.MustCompile(`/\*+?\s*?@doctor(.*?\n)*?.*?\*/`)
var cleanRegexes = []struct {
	re *regexp.Regexp
	to string
}{
	{
		re: regexp.MustCompile(`/\*+?\s*?@doctor`),
		to: "@doctor",
	},
	{
		re: regexp.MustCompile(`\n\s*?\*[ /]?`),
		to: "\n",
	},
}

func main() {
	if len(os.Args) == 1 {
		fmt.Printf("provide at least one path")
		os.Exit(1)
	}

	files := pathsWalker(os.Args[1:])
	docs := extractDocs(files)
	cleanDocs := cleaners(docs)

	// for doc := range cleanDocs {
	// 	fmt.Printf("%s\n", doc)
	// }
	// return

	i := linarian.New(bufio.NewReader(&docsReader{
		source: cleanDocs,
	}), 2)

	// for {
	// 	l, err := i.ReadLine()
	// 	if err != nil {
	// 		log.Fatalf("%+v", err)
	// 	}

	// 	fmt.Print(l)
	// }

	m, err := grouper.Parse(i)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Print(m)

	fmt.Println(`<script type="module">
			import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@9/dist/mermaid.esm.min.mjs';
		    mermaid.initialize({ startOnLoad: true });

	</script>`)
}

type docsReader struct {
	source chan string
	last   string
}

func (r *docsReader) Read(p []byte) (n int, err error) {
	var ok bool
	for {
		copy(p, []byte(r.last))

		if len(p) < len(r.last) {
			n += len(p)
			r.last = r.last[len(p):]
			break
		} else if len(p) == len(r.last) {
			n += len(p)
			r.last = <-r.source
			r.last, ok = <-r.source
			if !ok {
				return n, io.EOF
			}
			break
		} else if len(p) > len(r.last) {
			n += len(r.last)
			p = p[len(r.last):]
			r.last, ok = <-r.source
			if !ok {
				return n, io.EOF
			}
		}
	}
	return
}

func cleaners(src chan string) (dst chan string) {
	dst = make(chan string)

	wg := sync.WaitGroup{}
	for doc := range src {
		wg.Add(1)
		go func(doc string) {
			defer wg.Done()
			dst <- cleaner(doc)
		}(doc)
	}

	go func() {
		wg.Wait()
		close(dst)
	}()

	return dst
}

func cleaner(doc string) string {
	for i := range cleanRegexes {
		doc = cleanRegexes[i].re.ReplaceAllString(doc, cleanRegexes[i].to)
	}
	return doc
}

func extractDocs(files <-chan string) (docs chan string) {
	docs = make(chan string)
	wg := sync.WaitGroup{}

	for path := range files {
		wg.Add(1)
		go func(path string) {
			defer wg.Done()

			d, err := os.ReadFile(path)
			if err != nil {
				log.Printf("err: %v", err)
			}

			for _, pos := range doctorRegex.FindAllIndex(d, -1) {
				docs <- string(d[pos[0]:pos[1]])
			}
		}(path)
	}

	go func() {
		wg.Wait()
		close(docs)
	}()

	return docs
}
