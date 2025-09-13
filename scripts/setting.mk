# Copyright (C) 2025 Holence <Holence08@gmail.com>

# Reference: Your Makefiles are wrong: https://tech.davis-hansson.com/p/make/
SHELL := bash

# MAKEFLAGS += --warn-undefined-variables 

# don't use any Built-In Rules (https://www.gnu.org/software/make/manual/html_node/Catalogue-of-Rules.html)
MAKEFLAGS += --no-builtin-rules

# don't use TAB to indicate recipe line, use `>` instead
# .RECIPEPREFIX = >

###############################################################################
# copied from linux/scripts/Kbuild.include

# delete partially updated (i.e. corrupted) files on error
.DELETE_ON_ERROR:

# do not delete intermediate files automatically
#
# .NOTINTERMEDIATE is more correct, but only available on newer Make versions.
# Make 4.4 introduced .NOTINTERMEDIATE, and it appears in .FEATURES, but the
# global .NOTINTERMEDIATE does not work. We can use it on Make > 4.4.
# Use .SECONDARY for older Make versions, but "newer-prereqs" cannot detect
# deleted files.
ifneq ($(and $(filter notintermediate, $(.FEATURES)),$(filter-out 4.4,$(MAKE_VERSION))),)
.NOTINTERMEDIATE:
else
.SECONDARY:
endif
