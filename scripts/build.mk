# Copyright (C) 2025 Holence <Holence08@gmail.com>

# project struture:
# .
# ├── Makefile
# └── scripts
#     ├── build.mk
#     ├── color.mk
#     ├── kconfig-build.mk
#     ├── setting.mk
#     └── tools.mk

# get the realpath of current file (https://stackoverflow.com/a/18137056)
__mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
__mkfile_dir  := $(dir $(__mkfile_path))
include $(__mkfile_dir)/tools.mk
include $(__mkfile_dir)/color.mk

################################
#        Custom Config         #
################################

##### Config for Verbose #####
V ?=
ifneq ($(findstring 1, $V),)
  Q =
else
  Q = @
endif

##### Config for Build #####
# the name of TARGET
# default value: main
NAME ?= main

# all the source files (.s, .S, .c, .cpp)
# will be compiled into object files using compiler, see "Recipes"
# default value: all srcs under current working directory
SRCS ?= $(call find_srcs, .)
# translate to relative path, and remove duplicated
SRCS := $(sort $(foreach __file,$(SRCS),$(shell realpath --relative-to . $(__file))))
ifneq ($(findstring ../, $(SRCS)),)
$(call colored_warning,SRCS: $(SRCS))
$(call colored_error,SRCS contain file outside current dir$(comma) this is not acceptable)
endif

# the building dir
# default value: ./build/$(NAME)
# note: Add another subfolder $(NAME) is just a conservative way to
#       prevent mixing of built files (in some rare cases, a makefile
#       is used to build multiple target by changing $(NAME)). If you
#       only have one build target, you can simply define
#       BUILD_DIR := ./build
BUILD_DIR ?= ./build/$(NAME)

# all the dirs for searching header files
# will be used as -I flags for compiling
# default value: all dirs under current working directory
INC_DIRS ?= $(call find_dirs, .)

##### Config for Build LIB #####
STATIC ?=
SHARED ?=

##### Config for Install #####
# To install to your system  

# default install location:
# - TARGET_EXEC -> $(INSTALL_DESTDIR)$(INSTALL_PREFIX)/bin/
# - TARGET_LIB_STATIC -> $(INSTALL_DESTDIR)$(INSTALL_PREFIX)/lib/
# - TARGET_LIB_SHARED -> $(INSTALL_DESTDIR)$(INSTALL_PREFIX)/lib/
# - each file/folder in INSTALL_HEADERS -> $(INSTALL_DESTDIR)$(INSTALL_PREFIX)/include/*
# 
# $(INSTALL_DESTDIR)$(INSTALL_PREFIX) default to /usr/local
#   you can change INSTALL_DESTDIR, such as /tmp
#   thus $(INSTALL_DESTDIR)$(INSTALL_PREFIX) will be /tmp/usr/local
INSTALL_DESTDIR ?=
INSTALL_PREFIX  ?= /usr/local
INSTALL_DIR     = $(INSTALL_DESTDIR)$(INSTALL_PREFIX)
INSTALL_HEADERS ?= $(shell find include -mindepth 1 -maxdepth 1 -not \( -path 'include/config' -o -path 'include/generated' \))

################################
#        Generated Vars        #
################################
# Generated Vars using Custom Config
# NAME -> TARGET
# SRCS -> OBJS
# INC_DIRS -> INC_FLAGS

# the TARGET
## build executable file only if STATIC && SHARED not set
ifeq ($(STATIC)$(SHARED),)
TARGET_EXEC = $(BUILD_DIR)/$(NAME)
endif
## build static library (archive file) if STATIC=1
ifeq ($(STATIC),1)
TARGET_LIB_STATIC = $(BUILD_DIR)/lib$(NAME).a
endif
## build dynamic library (shared object file) if SHARED=1
ifeq ($(SHARED),1)
TARGET_LIB_SHARED = $(BUILD_DIR)/lib$(NAME).so
endif

# Prepends BUILD_DIR and appends .o to every src file
# As an example, ./your_dir/hello.cpp turns into BUILD_DIR/./your_dir/hello.cpp.o
OBJS = $(SRCS:%=$(BUILD_DIR)/%.o)

# Add a prefix to INC_DIRS. So moduleA would become -ImoduleA. GCC understands this -I flag
INC_FLAGS += $(addprefix -I,$(INC_DIRS))

################################
#            Flags             #
################################
# Variables Names Convention
# https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html

# C PreProcessor Flags
# The -MMD and -MP flags will let gcc generate .d files
# which will be used by Makefile (see `-include $(DEPS)`)
CPPFLAGS += $(INC_FLAGS) -MMD -MP

# C Compiler Flags
## warning option
CFLAGS += -Wall -Werror -Wextra -Wpedantic
CFLAGS += -Wno-unused-function -Wno-unused-parameter
CFLAGS += -Wno-format
CFLAGS += -Wstrict-aliasing -Wstrict-overflow

## compile option
CFLAGS += -O2
# CFLAGS += -flto
# CFLAGS += -Og -ggdb3
# CFLAGS += -fanalyzer
# CFLAGS += -fdata-sections -ffunction-sections

## Sanitizers
# SAN_FLAGS += -fsanitize=undefined
# SAN_FLAGS += -fsanitize=address # don't use this with valgrind
# SAN_FLAGS += -fsanitize=leak # don't use this with valgrind
# SAN_FLAGS += -fsanitize=thread # can't be combined with -fsanitize=address, -fsanitize=leak
CFLAGS += $(SAN_FLAGS)

# add compiler flag -fPIC if building .so
ifeq ($(SHARED),1)
CFLAGS += -fPIC
endif

# CXX Compiler Flags
CXXFLAGS += $(CFLAGS)

# Linker Flags
LDFLAGS += $(SAN_FLAGS)
# CFLAGS += -flto
LDFLAGS += -Wl,--gc-sections
# LDFLAGS += -Wl,-Map=output.map

# add linker flag -shared if building .so
ifeq ($(SHARED),1)
LDFLAGS += -shared
endif

################################
#           Recipes            #
################################

FORCE:
PHONY += FORCE

##### DEPS #####

# As an example, BUILD_DIR/hello.cpp.o turns into BUILD_DIR/hello.cpp.d
DEPS = $(OBJS:.o=.d)
# Let make knows which .o depend on which .o / .h
-include $(DEPS)

##### Compile #####

# Compile Pure Assembly into Object File
as_o_S_log = @echo "+ AS $< -> $@"
as_o_S_cmd = $(AS) $(ASFLAGS) -c $< -o $@
$(BUILD_DIR)/%.s.o: %.s
	$(Q)mkdir -p $(dir $@)
	$(as_o_S_log)
	$(Q)$(as_o_S_cmd)

# Compile Preprocessed Assembly into Object File
cc_o_s_log = @echo "+ CC $< -> $@"
cc_o_s_cmd = $(CC) $(CPPFLAGS) $(ASFLAGS) -c $< -o $@
cc_o_s_preprocessor_log = @echo "+ CC $< -> $(@:.o=.i)"
cc_o_s_preprocessor_cmd = $(CC) $(CPPFLAGS) $(ASFLAGS) -E -MF /dev/null $< | grep -ve '^\#' | clang-format - > $(@:.o=.i)
$(BUILD_DIR)/%.S.o: %.S
	$(Q)mkdir -p $(dir $@)
	$(cc_o_s_log)
	$(Q)$(cc_o_s_cmd)
#   also generate preprocessed file
# 	$(cc_o_s_preprocessor_log)
# 	$(cc_o_s_preprocessor_cmd)

# Compile C source into Object File
cc_o_c_log = @echo "+ CC $< -> $@"
cc_o_c_cmd = $(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
cc_o_c_preprocessor_log = @echo "+ CC $< -> $(@:.o=.i)"
cc_o_c_preprocessor_cmd = $(CC) $(CPPFLAGS) $(CFLAGS) -E -MF /dev/null $< | grep -ve '^\#' | clang-format - > $(@:.o=.i)
$(BUILD_DIR)/%.c.o: %.c
	$(Q)mkdir -p $(dir $@)
	$(cc_o_c_log)
	$(Q)$(cc_o_c_cmd)
#   also generate preprocessed file
# 	$(cc_o_c_preprocessor_log)
# 	$(cc_o_c_preprocessor_cmd)

# Compile C++ source into Object File
cxx_o_cpp_log = @echo "+ CXX $< -> $@"
cxx_o_cpp_cmd = $(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@
cxx_o_cpp_preprocessor_log = @echo "+ CXX $< -> $(@:.o=.i)"
cxx_o_cpp_preprocessor_cmd = $(CXX) $(CPPFLAGS) $(CXXFLAGS) -E -MF /dev/null $< | grep -ve '^\#' | clang-format - > $(@:.o=.i)
$(BUILD_DIR)/%.cpp.o: %.cpp
	$(Q)mkdir -p $(dir $@)
	$(cxx_o_cpp_log)
	$(Q)$(cxx_o_cpp_cmd)
#   also generate preprocessed file
# 	$(cxx_o_cpp_preprocessor_log)
# 	$(cxx_o_cpp_preprocessor_cmd)

##### Link #####

# If LDFLAGS changed, by default make won't auto re-make. Thus borrowing
# the idea from ​​fixdep (record the command for compiling object files and
# FORCE check whether it's changed), we also record the LDFLAGS to a file
# and FORCE check whether the LDFLAGS is different from the recorded one.
SAVED_LDFLAGS = $(BUILD_DIR)/.saved_ldflags
# Update the .saved_ldflags file whenever LDFLAGS changes
$(SAVED_LDFLAGS): FORCE
	$(Q)mkdir -p $(dir $@)
	@echo "$(LDFLAGS)" | cmp -s - $@ || echo "$(LDFLAGS)" > $@

# Link all Object Files into TARGET_EXEC or TARGET_LIB_SHARED
link_log = @$(call print_ansi_fg_green,+ Link $@)
link_cmd = $(CXX) $(OBJS) -o $@ $(LDFLAGS)
$(TARGET_EXEC) $(TARGET_LIB_SHARED): $(OBJS) $(SAVED_LDFLAGS)
	$(link_log)
	$(Q)$(link_cmd)

##### Archive #####

# Archive all Object Files into TARGET_LIB_STATIC
archive_log = @$(call print_ansi_fg_green,+ AR $@)
archive_cmd = $(AR) rcs $@ $^
$(TARGET_LIB_STATIC): $(OBJS)
	$(archive_log)
	$(Q)$(archive_cmd)

################################
#            Target            #
################################

.DEFAULT_GOAL = all
all: $(TARGET_EXEC) $(TARGET_LIB_STATIC) $(TARGET_LIB_SHARED)
PHONY += all

run: $(TARGET_EXEC)
	$(Q)$(TARGET_EXEC)
PHONY += run

valgrind: $(TARGET_EXEC)
	$(call run_valgrind, $(TARGET_EXEC))
PHONY += valgrind

# clean build dir
clean::
	-$(RM) -r $(BUILD_DIR)
PHONY += clean

# all clean targets
clean-all:: clean
PHONY += clean-all

# __install(file_path,dst_dir,permission_mode)
# 1. create dst_dir if not exist
# 2. copy file from file_path to dst_dir and chmod permission_mode
define __install
	$(Q)install -d $2
	$(Q)install -m$3 $1 $2
	@$(call print_ansi_fg_green,+ Install $$(ls $2$(notdir $1)))
endef

# Install to system
# - /usr/local/bin/$(TARGET_EXEC)
# - /usr/local/lib/$(TARGET_LIB_STATIC)
# - /usr/local/lib/$(TARGET_LIB_SHARED)
# - each file/folder in INSTALL_HEADERS to /usr/local/include/*
install: all
ifneq ($(TARGET_EXEC),)
	$(call __install,$(TARGET_EXEC),$(INSTALL_DIR)/bin/,755)
endif
ifneq ($(TARGET_LIB_STATIC),)
	$(call __install,$(TARGET_LIB_STATIC),$(INSTALL_DIR)/lib/,644)
endif
ifneq ($(TARGET_LIB_SHARED),)
	$(call __install,$(TARGET_LIB_SHARED),$(INSTALL_DIR)/lib/,644)
	ldconfig
endif
ifneq ($(TARGET_LIB_STATIC)$(TARGET_LIB_SHARED),)
	$(foreach __file,$(shell find $(INSTALL_HEADERS) -type f),\
		$(call __install,$(__file),$(dir $(INSTALL_DIR)/$(__file)),644)$(newline)\
	)
endif
PHONY += install

# Remove installed files
# - /usr/local/bin/$(TARGET_EXEC)
# - /usr/local/lib/$(TARGET_LIB_STATIC)
# - /usr/local/lib/$(TARGET_LIB_SHARED)
# - each file/folder in INSTALL_HEADERS in /usr/local/include/*
uninstall:
ifneq ($(TARGET_EXEC),)
	-$(RM) -r $(INSTALL_DIR)/bin/$(notdir $(TARGET_EXEC))
endif
ifneq ($(TARGET_LIB_STATIC),)
	-$(RM) -r $(INSTALL_DIR)/lib/$(notdir $(TARGET_LIB_STATIC))
endif
ifneq ($(TARGET_LIB_SHARED),)
	-$(RM) -r $(INSTALL_DIR)/lib/$(notdir $(TARGET_LIB_SHARED))
	ldconfig
endif
ifneq ($(TARGET_LIB_STATIC)$(TARGET_LIB_SHARED),)
	$(foreach __file,$(INSTALL_HEADERS),\
		-$(RM) -r $(INSTALL_DIR)/$(__file)$(newline)\
	)
endif
PHONY += uninstall

help::
	@echo 'Main Targets:'
	@echo '    all          - build all (default target)'
	@echo '                   build TARGET_EXEC if STATIC && SHARED not set (default)'
	@echo '                   build TARGET_LIB_STATIC if STATIC=1'
	@echo '                   build TARGET_LIB_SHARED if SHARED=1'
	@echo '    run          - build TARGET_EXEC and run'
	@echo '    valgrind     - build TARGET_EXEC and run valgrind'
	@echo 'Install Targets:'
	@echo '    install      - install to system'
	@echo '                   install TARGET_EXEC if STATIC && SHARED not set (default)'
	@echo '                       default location: /usr/local/bin/'
	@echo '                   install TARGET_LIB_STATIC if STATIC=1'
	@echo '                       default location: /usr/local/lib/'
	@echo '                   install TARGET_LIB_SHARED if SHARED=1'
	@echo '                       default location: /usr/local/lib/'
	@echo '                   install each file/folder in INSTALL_HEADERS if STATIC || SHARED is set'
	@echo '                       default location: /usr/local/include/*'
	@echo '                       default INSTALL_HEADERS: each file/folder in ./include/, excluding'
	@echo '                                                include/config and include/generated'
	@echo '    uninstall    - remove installed files'
	@echo ''
	@echo '    Note: These targets require root permissions!'
	@echo '          And `ldconfig` is automatically called after install/uninstall SHARED lib'
	@echo 'Others:'
	@echo '    clean        - clean build dir'
	@echo '    clean-all    - run all clean targets'
	@echo '    help         - show help text'
	@echo 'Variables:'
	@echo '    make V=1     - verbose'
PHONY += help

.PHONY: $(PHONY)

ifneq ($(findstring 1, $V),)
$(call colored_info,$(ANSI_FG_BLACK),================= Custom Config ==================)
$(call colored_info,$(ANSI_FG_BLACK),--------------- Config for Build -----------------)
$(call colored_info,$(ANSI_FG_BLACK),NAME      : $(NAME))
$(call colored_info,$(ANSI_FG_BLACK),SRCS      : $(SRCS))
$(call colored_info,$(ANSI_FG_BLACK),BUILD_DIR : $(BUILD_DIR))
$(call colored_info,$(ANSI_FG_BLACK),INC_DIRS  : $(INC_DIRS))
$(call colored_info,$(ANSI_FG_BLACK),--------------- Config for Build LIB -------------)
$(call colored_info,$(ANSI_FG_BLACK),STATIC : $(STATIC))
$(call colored_info,$(ANSI_FG_BLACK),SHARED : $(SHARED))
$(call colored_info,$(ANSI_FG_BLACK),--------------- Config for Install ---------------)
$(call colored_info,$(ANSI_FG_BLACK),INSTALL_DESTDIR    : $(INSTALL_DESTDIR))
$(call colored_info,$(ANSI_FG_BLACK),INSTALL_PREFIX     : $(INSTALL_PREFIX))
$(call colored_info,$(ANSI_FG_BLACK),INSTALL_DIR        : $(INSTALL_DIR))
$(call colored_info,$(ANSI_FG_BLACK),INSTALL_HEADERS    : $(INSTALL_HEADERS))
$(call colored_info,$(ANSI_FG_BLACK),================= Generated Vars =================)
$(call colored_info,$(ANSI_FG_BLACK),TARGET_EXEC       : $(TARGET_EXEC))
$(call colored_info,$(ANSI_FG_BLACK),TARGET_LIB_STATIC : $(TARGET_LIB_STATIC))
$(call colored_info,$(ANSI_FG_BLACK),TARGET_LIB_SHARED : $(TARGET_LIB_SHARED))
$(call colored_info,$(ANSI_FG_BLACK),OBJS              : $(OBJS))
$(call colored_info,$(ANSI_FG_BLACK),INC_FLAGS         : $(INC_FLAGS))
$(call colored_info,$(ANSI_FG_BLACK),================ Common variables ================)
$(call colored_info,$(ANSI_FG_BLACK),AS  : $(AS))
$(call colored_info,$(ANSI_FG_BLACK),CC  : $(CC))
$(call colored_info,$(ANSI_FG_BLACK),CXX : $(CXX))
$(call colored_info,$(ANSI_FG_BLACK),AR  : $(AR))
$(call colored_info,$(ANSI_FG_BLACK),RM  : $(RM))
$(call colored_info,$(ANSI_FG_BLACK),====================== Flags =====================)
$(call colored_info,$(ANSI_FG_BLACK),CPPFLAGS : $(CPPFLAGS))
$(call colored_info,$(ANSI_FG_BLACK),CFLAGS   : $(CFLAGS))
$(call colored_info,$(ANSI_FG_BLACK),CXXFLAGS : $(CXXFLAGS))
$(call colored_info,$(ANSI_FG_BLACK),LDFLAGS  : $(LDFLAGS))
$(call colored_info,$(ANSI_FG_BLACK),====================== DEPS ======================)
$(call colored_info,$(ANSI_FG_BLACK),DEPS : $(DEPS))
endif
