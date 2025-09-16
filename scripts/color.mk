# Copyright (C) 2025 Holence <Holence08@gmail.com>

################################
#            Color             #
################################

ANSI_FG_BLACK   = \33[1;30m
ANSI_FG_RED     = \33[1;31m
ANSI_FG_GREEN   = \33[1;32m
ANSI_FG_YELLOW  = \33[1;33m
ANSI_FG_BLUE    = \33[1;34m
ANSI_FG_MAGENTA = \33[1;35m
ANSI_FG_CYAN    = \33[1;36m
ANSI_FG_WHITE   = \33[1;37m
ANSI_BG_BLACK   = \33[1;40m
ANSI_BG_RED     = \33[1;41m
ANSI_BG_GREEN   = \33[1;42m
ANSI_BG_YELLOW  = \33[1;43m
ANSI_BG_BLUE    = \33[1;44m
ANSI_BG_MAGENTA = \33[1;35m
ANSI_BG_CYAN    = \33[1;46m
ANSI_BG_WHITE   = \33[1;47m
ANSI_NONE       = \33[0m

print_ansi_fg_black   = printf "$(ANSI_FG_BLACK)$1$(ANSI_NONE)\n"
print_ansi_fg_red     = printf "$(ANSI_FG_RED)$1$(ANSI_NONE)\n"
print_ansi_fg_green   = printf "$(ANSI_FG_GREEN)$1$(ANSI_NONE)\n"
print_ansi_fg_yellow  = printf "$(ANSI_FG_YELLOW)$1$(ANSI_NONE)\n"
print_ansi_fg_blue    = printf "$(ANSI_FG_BLUE)$1$(ANSI_NONE)\n"
print_ansi_fg_magenta = printf "$(ANSI_FG_MAGENTA)$1$(ANSI_NONE)\n"
print_ansi_fg_cyan    = printf "$(ANSI_FG_CYAN)$1$(ANSI_NONE)\n"
print_ansi_fg_white   = printf "$(ANSI_FG_WHITE)$1$(ANSI_NONE)\n"
print_ansi_bg_black   = printf "$(ANSI_BG_BLACK)$1$(ANSI_NONE)\n"
print_ansi_bg_red     = printf "$(ANSI_BG_RED)$1$(ANSI_NONE)\n"
print_ansi_bg_green   = printf "$(ANSI_BG_GREEN)$1$(ANSI_NONE)\n"
print_ansi_bg_yellow  = printf "$(ANSI_BG_YELLOW)$1$(ANSI_NONE)\n"
print_ansi_bg_blue    = printf "$(ANSI_BG_BLUE)$1$(ANSI_NONE)\n"
print_ansi_bg_magenta = printf "$(ANSI_BG_MAGENTA)$1$(ANSI_NONE)\n"
print_ansi_bg_cyan    = printf "$(ANSI_BG_CYAN)$1$(ANSI_NONE)\n"
print_ansi_bg_white   = printf "$(ANSI_BG_WHITE)$1$(ANSI_NONE)\n"

define colored_info
	$(info $(shell printf "$1$2$(ANSI_NONE)\n"))
endef

define colored_warning
	$(warning $(shell $(call print_ansi_fg_yellow,$1)))
endef

define colored_error
	$(error $(shell $(call print_ansi_fg_red,$1)))
endef
