# Copyright (C) 2025 Holence <Holence08@gmail.com>

# Find all the C/C++ files recursively  (also follow symlinks)
find_srcs = $(shell find $1 -name '*.cpp' -or -name '*.c' -or -name '*.s' -or -name '*.S' -follow)

# Find all folders recursively (also follow symlinks)
find_dirs = $(shell find $1 -type d -follow)

# run valgrind
define run_valgrind
	valgrind --show-error-list=yes --leak-check=full --show-leak-kinds=all --track-origins=yes $1
endef

# copied from linux/scripts/Kbuild.include
# Convenient variables
comma   := ,
quote   := "
squote  := '
empty   :=
space   := $(empty) $(empty)
space_escape := _-_SPACE_-_
pound := \#
define newline


endef

# Escape single quote for use in echo statements
escsq = $(subst $(squote),'\$(squote)',$1)
