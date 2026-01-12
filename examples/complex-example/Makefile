include scripts/setting.mk

export WORK_DIR = $(shell pwd)

SRCS = $(call find_srcs, src)

include scripts/build.mk

LIBS += third-party/liba/liba.a
LIBS += third-party/libb/libb.so
$(LIBS): FORCE
	$(MAKE) -C $(dir $@)

$(TARGET_EXEC): $(LIBS)

LDFLAGS += -L.
LDFLAGS += -l:third-party/liba/liba.a
LDFLAGS += -l:third-party/libb/libb.so
