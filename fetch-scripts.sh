#!/bin/bash

# backup ./scripts/ if exists
if [[ -d ./scripts/ ]]; then
    date_time=$(date "+%Y-%m-%dT%H%M%S")
    mv ./scripts/ ./scripts-"$date_time".backup/
fi

# fetch all the scripts
LIST="""
    build.mk
    color.mk
    kconfig-build.mk
    Kconfig.compiler
    setting.mk
    tools.mk
"""
for FILE in $LIST
do
    wget --directory-prefix scripts/ https://raw.githubusercontent.com/Holence/C-Project-Template/refs/heads/main/scripts/"$FILE"
done
