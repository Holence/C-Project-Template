#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

backup () {
    folder=$1
    if [[ -d "$folder" ]]; then
        date_time=$(date "+%Y-%m-%dT%H%M%S")
        mv "$folder" "$folder"-"$date_time".backup
        echo -e "${BLUE}backup $folder-$date_time.backup${NC}"
    fi  
}

backup "utils"
backup "scripts"

fetch (){
    file=$1
    mkdir -p "$(dirname "$file")"
    url=https://raw.githubusercontent.com/Holence/C-Project-Template/refs/heads/main/"$file"
    if curl -fL -o "$file" "$url" 2> /dev/null ; then
        echo -e "${GREEN}success: $url${NC}"
    else
        echo -e "${RED}error: $url${NC}"
    fi
}

LIST="""
    utils/utils.h
    utils/Kconfig
    utils/macro.h
    utils/hex.c
    utils/hex.h
    utils/types.h
    utils/debug.h
    scripts/kconfig-build.mk
    scripts/color.mk
    scripts/addon/flex-bison.mk
    scripts/tools.mk
    scripts/Kconfig.compiler
    scripts/setting.mk
    scripts/build.mk
"""

for file in $LIST
do
    fetch "$file" &
done
wait
