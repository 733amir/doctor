#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail

markdown=$(
    rg -oUiIN --color never --crlf -E utf8 --no-heading --multiline-dotall --trim '/\*+?\s*?@doctor.*?\*/' --glob-case-insensitive -g '*.php' --no-ignore $1 |
    rg -i --color never --crlf -E utf8 --passthru '(.*)\*/' -r '$1' |
    rg -i --color never --crlf -E utf8 --passthru '^(\*\s?)?(.*)' -r '$2' |
    rg -i --color never --crlf -E utf8 --passthru '^/\*+?\s*?(@doctor.*)' -r '$1' |
    /bin/doctor |
    pandoc --from gfm --to html --standalone --metadata 'title=Seller Squad Documentation')

if [ $? -ne 0 ]; then
    exit 1
fi

mkdir -p /results
echo "$markdown" > /results/index.html
