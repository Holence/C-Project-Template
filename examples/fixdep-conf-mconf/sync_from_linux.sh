#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'


fetch() {
    file=$1
    mkdir -p "$(dirname "$file")"
    url=https://raw.githubusercontent.com/torvalds/linux/refs/heads/master/scripts/"$file"
    if curl -fL -o "$file" "$url" 2> /dev/null ; then
        echo -e "${GREEN}success: $url${NC}"
    else
        echo -e "${RED}error: $url${NC}"
    fi
}

LIST="""
    basic/fixdep.c
    include/array_size.h
    include/hash.h
    include/hashtable.h
    include/list_types.h
    include/list.h
    include/xalloc.h
    kconfig/conf.c
    kconfig/confdata.c
    kconfig/expr.c
    kconfig/expr.h
    kconfig/internal.h
    kconfig/lexer.l
    kconfig/lkc_proto.h
    kconfig/lkc.h
    kconfig/lxdialog/checklist.c
    kconfig/lxdialog/dialog.h
    kconfig/lxdialog/inputbox.c
    kconfig/lxdialog/menubox.c
    kconfig/lxdialog/textbox.c
    kconfig/lxdialog/util.c
    kconfig/lxdialog/yesno.c
    kconfig/mconf.c
    kconfig/menu.c
    kconfig/mnconf-common.c
    kconfig/mnconf-common.h
    kconfig/parser.y
    kconfig/preprocess.c
    kconfig/preprocess.h
    kconfig/symbol.c
    kconfig/util.c
"""

for file in $LIST
do
    fetch "$file" &
done
wait
