#!/bin/bash

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
    kconfig/lxdialog
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

for FILE in $LIST
do
    wget -O "$FILE" https://raw.githubusercontent.com/torvalds/linux/refs/heads/master/scripts/"$FILE"
done
