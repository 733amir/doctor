#!/usr/bin/env bash
set -o nounset

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=linux;;
    Darwin*)    machine=mac;;
    *)          echo 'Operating System Not Supported. Contact Developer!'; exit 1;
esac


#################### Dependency Checking
dep_go=1
go_version=$(go version 2>&1)
if [ $? -ne 0 ] || [[ ! "$go_version" =~ .*go1\.1[89]\..* ]]; then
    dep_go=0
fi

# dep_rg=1
# rg_version=$(rg --version 2>&1)
# if [ $? -ne 0 ] || [[ ! "$rg_version" =~ .*ripgrep\ 13\..* ]]; then
#     dep_rg=0
# fi

dep_pandoc=1
pandoc_version=$(pandoc -v 2>&1)
if [ $? -ne 0 ] || [[ ! "$pandoc_version" =~ .*pandoc\ 3\.0\..* ]]; then
    dep_pandoc=0
fi


if [ $dep_go -ne 1 ] ||
    # [ $dep_rg -ne 1 ] ||
    [ $dep_pandoc -ne 1 ]; then
    printf 'Error: You need to install\n'

    if [ $dep_go -ne 1 ]; then
        printf '* Go Compiler [v1.18.* and above]\n'
        case "$machine" in
        linux) printf '  - Run: sudo apt install golang\n';;
        mac) printf '  - Run: brew install go\n';;
        esac
    fi

    # if [ $dep_rg -ne 1 ]; then
    #     printf '* RipGrep [v13.*.* and above]\n'
    #     case "$machine" in
    #     linux) printf '  - Run: sudo apt install ripgrep\n';;
    #     mac) printf '  - Run: brew install ripgrep\n';;
    #     esac
    # fi

    if [ $dep_pandoc -ne 1 ]; then
        printf '* Pandoc [v3.0.*]\n'
        case "$machine" in
        linux)
            printf '  - Download https://github.com/jgm/pandoc/releases/download/3.0.1/pandoc-3.0.1-1-amd64.deb\n'
            printf '  - Run: sudo dpkg -i pandoc-3.0.1-1-amd64.deb\n'
        ;;
        mac) printf '  - Run: brew install pandoc\n';;
        esac
    fi

    exit 1
fi
