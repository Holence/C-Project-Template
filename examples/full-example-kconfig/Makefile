include scripts/setting.mk
include scripts/tools.mk

BUILD_DIR := build
NAME := full-example-kconfig
SRCS := $(call find_srcs, src)
INC_DIRS := ./include/
LDFLAGS += -lm -lpthread

include scripts/kconfig-build.mk
