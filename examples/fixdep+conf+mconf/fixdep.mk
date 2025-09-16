include scripts/setting.mk
include scripts/tools.mk

NAME := fixdep
SRCS := $(call find_srcs, basic)
INC_DIRS := ./include/

# these code even cannot pass -Werror ?!!
CFLAGS += -w

include scripts/build.mk
