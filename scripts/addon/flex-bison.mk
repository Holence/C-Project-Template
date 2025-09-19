# Copyright (C) 2025 Holence <Holence08@gmail.com>

# this file should be included before
# - `include scripts/build.mk`
# - `include scripts/kconfig-build.mk`

# Your lexer.l
FLEX_SRC  ?=
# Your parser.y
BISON_SRC ?=

FLEX  ?= flex
BISON ?= bison

# Generated Files
FLEX_C  := $(FLEX_SRC:%.l=%.lex.c)
BISON_C := $(BISON_SRC:%.y=%.tab.c)
BISON_H := $(BISON_SRC:%.y=%.tab.h)

SRCS += $(FLEX_C) $(BISON_C)

LDFLAGS += -lfl

# Bison generates parser .tab.c and .tab.h
%.tab.c: %.y
	@echo "+ YACC $< -> $@"
	$(Q)$(BISON) --no-lines $(BISON_FLAGS) -o $(BISON_C) $<
%.tab.h: %.y
	@echo "+ YACC $< -> $@"
	$(Q)$(BISON) --header=$(BISON_H) $(BISON_FLAGS) $< -o /dev/null

# Flex generates .lex.c
%.lex.c: %.l $(BISON_H)
	@echo "+ LEX $< -> $@"
	$(Q)$(FLEX) --noline $(FLEX_FLAGS) -o $@ $<

clean::
	-$(RM) $(FLEX_C) $(BISON_C) $(BISON_H)
