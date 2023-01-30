#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail

./setup.sh
if [ $? -ne 0 ]; then
    exit 1
fi

envPath=$1
if [ ! ${envPath::1} == '/' ] && [ ! ${envPath::1} == '~' ]; then
    envPath="$(pwd)/$envPath"
fi

marketplaceDir="$envPath/vendor/digikala/supernova-digikala-marketplace"
if [ ! -d $marketplaceDir ]; then
    echo "Error: wrong path to supernova-env-dev"
fi

doctorDir="$marketplaceDir/docs/doctor"
if [ ! -d $doctorDir ]; then
    mkdir $doctorDir
fi

doctorFile="$doctorDir/index.html"

go build -o doctor ./*.go

# markdown=$(rg -oUiIN --color never --crlf -E utf8 --no-heading --multiline-dotall --trim '/\*+?\s*?@doctor.*?\*/' --glob-case-insensitive -g '*.php' --no-ignore $envPath |
#     rg -i --color never --crlf -E utf8 --passthru '(.*)\*/' -r '$1' |
#     rg -i --color never --crlf -E utf8 --passthru '^(\*\s?)?(.*)' -r '$2' |
#     rg -i --color never --crlf -E utf8 --passthru '^/\*+?\s*?(@doctor.*)' -r '$1' |
#     ./doctor |
#     pandoc --from gfm --to html --standalone --metadata 'title=Seller Squad Documentation'
# )

markdown=$(
    ./doctor "$envPath"/* |
    pandoc --from gfm --to html --standalone --metadata 'title=Seller Squad Documentation'
)

if [ $? -ne 0 ]; then
    exit 1
fi

printf '%s' "$markdown" > $doctorFile

fileLink="file://$doctorFile"

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     xdg-open $fileLink >> /dev/null;;
    Darwin*)    open $fileLink >> /dev/null;;
    *)          echo "Open in your browser: $fileLink"
esac
