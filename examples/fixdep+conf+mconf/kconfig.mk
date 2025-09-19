include scripts/setting.mk
include scripts/tools.mk
include scripts/color.mk

SRCS := $(call find_srcs, kconfig, -mindepth 1 -maxdepth 1)
SRCS := $(filter-out kconfig/mconf.c kconfig/conf.c, $(SRCS))
INC_DIRS := $(call find_dirs, ./kconfig/) ./include/

# check $(NAME)
ifeq ($(findstring clean,$(MAKECMDGOALS))$(filter help,$(MAKECMDGOALS)),)
  ifeq ($(NAME),conf)
    SRCS += kconfig/conf.c
  else ifeq ($(NAME),mconf)
    SRCS += kconfig/mconf.c $(call find_srcs, kconfig/lxdialog)
    LDFLAGS += -lncursesw -ltinfo
  else
    $(call colored_error,NAME should be either "conf" or "mconf")
  endif
endif

FLEX_SRC = kconfig/lexer.l
BISON_SRC = kconfig/parser.y
include scripts/addon/flex-bison.mk

# these code even cannot pass -Werror ?!!
CFLAGS += -w

include scripts/build.mk
