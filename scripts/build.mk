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
# the name of "Binary File"
# default value: main
NAME ?= main

# all the source files (.s, .S, .c, .cpp)
# will be compiled into object files using compiler, see "Recipes"
# default value: all srcs under current working directory
SRCS ?= $(call find_srcs, .)

# the building dir
# default value: ./build
BUILD_DIR ?= ./build

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
# - BINARY_EXEC -> $(INSTALL_DESTDIR)$(INSTALL_PREFIX)/bin/
# - BINARY_LIB_STATIC -> $(INSTALL_DESTDIR)$(INSTALL_PREFIX)/lib/
# - BINARY_LIB_SHARED -> $(INSTALL_DESTDIR)$(INSTALL_PREFIX)/lib/
# - BINARY_LIB_HEADERS -> $(INSTALL_DESTDIR)$(INSTALL_PREFIX)/include/
# 
# $(INSTALL_DESTDIR)$(INSTALL_PREFIX) default to /usr/local
#   you can change INSTALL_DESTDIR, such as /tmp
#   thus $(INSTALL_DESTDIR)$(INSTALL_PREFIX) will be /tmp/usr/local
INSTALL_DESTDIR ?=
INSTALL_PREFIX  ?= /usr/local
INSTALL_DIR     = $(INSTALL_DESTDIR)$(INSTALL_PREFIX)

# if you also want to install header files, then
# you should define them manulayy
# (using `find -type f -name "*.h"` is too rude)
BINARY_LIB_HEADERS ?=

################################
#        Generated Vars        #
################################
# Generated Vars using Custom Config
# NAME -> BINARY
# SRCS -> OBJS
# INC_DIRS -> INC_FLAGS

# the "Binary File"
## build executable file only if STATIC && SHARED not set
ifeq ($(STATIC)$(SHARED),)
BINARY_EXEC = $(BUILD_DIR)/$(NAME)
endif
## build static library (archive file) if STATIC=1
ifeq ($(STATIC),1)
BINARY_LIB_STATIC = $(BUILD_DIR)/lib$(NAME).a
endif
## build dynamic library (shared object file) if SHARED=1
ifeq ($(SHARED),1)
BINARY_LIB_SHARED = $(BUILD_DIR)/lib$(NAME).so
endif

# Prepends BUILD_DIR and appends .o to every src file
# As an example, ./your_dir/hello.cpp turns into BUILD_DIR/./your_dir/hello.cpp.o
OBJS = $(SRCS:%=$(BUILD_DIR)/%.o)

# Add a prefix to INC_DIRS. So moduleA would become -ImoduleA. GCC understands this -I flag
INC_FLAGS = $(addprefix -I,$(INC_DIRS))

################################
#            Flags             #
################################
# Variables Names Convention
# https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html

# C PreProcessor Flags
# The -MMD and -MP flags will let gcc generate .d files
# which will be used by Makefile (see `-include $(DEPS)`)
CPPFLAGS = $(INC_FLAGS) -MMD -MP

# C Compiler Flags
## warning option
CFLAGS += -Wall -Werror -Wextra -Wpedantic
CFLAGS += -Wno-unused-function -Wno-unused-parameter
CFLAGS += -Wno-format
CFLAGS += -Wstrict-aliasing=2 -Wstrict-overflow=5

## compile option
CFLAGS += -O2
# CFLAGS += -flto
# CFLAGS += -Og -ggdb3
# CFLAGS += -fanalyzer
# CFLAGS += -fdata-sections -ffunction-sections

## Sanitizers
SAN_FLAGS += -fsanitize=undefined
# SAN_FLAGS += -fsanitize=address # don't use these with valgrind
# SAN_FLAGS += -fsanitize=leak # don't use these with valgrind
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

# As an example, BUILD_DIR/hello.cpp.o turns into BUILD_DIR/hello.cpp.d
DEPS = $(OBJS:.o=.d)
# Let make knows which .o depend on which .o / .h
-include $(DEPS)

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

# Link all Object Files into BINARY_EXEC or BINARY_LIB_SHARED
link_log = @echo "+ Link $@"
link_cmd = $(CXX) $^ -o $@ $(LDFLAGS)
$(BINARY_EXEC) $(BINARY_LIB_SHARED): $(OBJS)
	$(link_log)
	$(Q)$(link_cmd)

# Archive all Object Files into BINARY_LIB_STATIC
archive_log = @echo "+ AR $@"
archive_cmd = $(AR) rcs $@ $^
$(BINARY_LIB_STATIC): $(OBJS)
	$(archive_log)
	$(Q)$(archive_cmd)

################################
#            Rules             #
################################

.DEFAULT_GOAL = all
all: $(BINARY_EXEC) $(BINARY_LIB_STATIC) $(BINARY_LIB_SHARED)
PHONY += all

run: $(BINARY_EXEC)
	@$(BINARY_EXEC)
PHONY += run

memcheck: $(BINARY_EXEC)
	$(call run_memcheck, $(BINARY_EXEC))
PHONY += memcheck

# clean build dir
clean:
	-$(RM) -r $(BUILD_DIR)
PHONY += clean

# all clean targets
clean-all: clean
PHONY += clean-all

# Install to system
# - /usr/local/bin/$(BINARY_EXEC)
# - /usr/local/lib/$(BINARY_LIB_STATIC)
# - /usr/local/lib/$(BINARY_LIB_SHARED)
# - each of $(BINARY_LIB_HEADERS) to /usr/local/include/
define __install # __install(file_path,dst_dir,permission_mode)
	$(Q)install -d $2
	$(Q)install -m$3 $1 $2
	@printf "$(ANSI_FG_GREEN)+ Install $$(ls $2$(notdir $1))$(ANSI_NONE)\n"
endef
install: all
ifneq ($(BINARY_EXEC),)
	$(call __install,$(BINARY_EXEC),$(INSTALL_DIR)/bin/,755)
endif
ifneq ($(BINARY_LIB_STATIC),)
	$(call __install,$(BINARY_LIB_STATIC),$(INSTALL_DIR)/lib/,644)
endif
ifneq ($(BINARY_LIB_SHARED),)
	$(call __install,$(BINARY_LIB_SHARED),$(INSTALL_DIR)/lib/,644)
endif
ifneq ($(BINARY_LIB_HEADERS),)
	$(foreach header,$(BINARY_LIB_HEADERS),\
		$(call __install,$(header),$(INSTALL_DIR)/include/,644)$(newline)\
	)
endif
PHONY += install

# Remove installed files
# - /usr/local/bin/$(BINARY_EXEC)
# - /usr/local/lib/$(BINARY_LIB_STATIC)
# - /usr/local/lib/$(BINARY_LIB_SHARED)
# - each of $(BINARY_LIB_HEADERS) in /usr/local/include/
define __uninstall # __uninstall(dir,file_path) # note: notdir is used for extracting filename from file_path
	-$(RM) $1$(notdir $2)
endef
uninstall:
ifneq ($(BINARY_EXEC),)
	$(call __uninstall,$(INSTALL_DIR)/bin/,$(BINARY_EXEC))
endif
ifneq ($(BINARY_LIB_STATIC),)
	$(call __uninstall,$(INSTALL_DIR)/lib/,$(BINARY_LIB_STATIC))
endif
ifneq ($(BINARY_LIB_SHARED),)
	$(call __uninstall,$(INSTALL_DIR)/lib/,$(BINARY_LIB_SHARED))
endif
ifneq ($(BINARY_LIB_HEADERS),)
	$(foreach header,$(BINARY_LIB_HEADERS),\
		$(call __uninstall,$(INSTALL_DIR)/include/,$(header))$(newline)\
	)
endif
PHONY += uninstall

help::
	@echo 'Main Targets:'
	@echo '    all          - compile (default target)'
	@echo '                   build BINARY_EXEC if STATIC && SHARED not set (default)'
	@echo '                   build BINARY_LIB_STATIC if STATIC=1'
	@echo '                   build BINARY_LIB_SHARED if SHARED=1'
	@echo '    run          - compile BINARY_EXEC and run'
	@echo '    memcheck     - compile BINARY_EXEC and memcheck'
	@echo 'Install Targets:'
	@echo '    install      - install to system'
	@echo '                   install BINARY_EXEC if STATIC && SHARED not set (default)'
	@echo '                       default location: /usr/local/bin/'
	@echo '                   install BINARY_LIB_STATIC if STATIC=1'
	@echo '                       default location: /usr/local/lib/'
	@echo '                   install BINARY_LIB_SHARED if SHARED=1'
	@echo '                       default location: /usr/local/lib/'
	@echo '                   install BINARY_LIB_HEADERS if STATIC || SHARED is set'
	@echo '                       default location: /usr/local/include/'
	@echo '    uninstall    - remove installed files'
	@echo 'Others:'
	@echo '    clean        - clean build dir'
	@echo '    clean-all    - run all clean targets'
	@echo '    help         - show help text'
	@echo 'Variables:'
	@echo '    make V=1     - verbose'
PHONY += help

.PHONY: $(PHONY)

ifneq ($(findstring 1, $V),)
$(call colored_print,$(ANSI_FG_BLACK),================= Custom Config ==================)
$(call colored_print,$(ANSI_FG_BLACK),--------------- Config for Build -----------------)
$(call colored_print,$(ANSI_FG_BLACK),NAME      : $(NAME))
$(call colored_print,$(ANSI_FG_BLACK),SRCS      : $(SRCS))
$(call colored_print,$(ANSI_FG_BLACK),BUILD_DIR : $(BUILD_DIR))
$(call colored_print,$(ANSI_FG_BLACK),INC_DIRS  : $(INC_DIRS))
$(call colored_print,$(ANSI_FG_BLACK),--------------- Config for Build LIB -------------)
$(call colored_print,$(ANSI_FG_BLACK),STATIC : $(STATIC))
$(call colored_print,$(ANSI_FG_BLACK),SHARED : $(SHARED))
$(call colored_print,$(ANSI_FG_BLACK),--------------- Config for Install ---------------)
$(call colored_print,$(ANSI_FG_BLACK),INSTALL_DESTDIR    : $(INSTALL_DESTDIR))
$(call colored_print,$(ANSI_FG_BLACK),INSTALL_PREFIX     : $(INSTALL_PREFIX))
$(call colored_print,$(ANSI_FG_BLACK),INSTALL_DIR        : $(INSTALL_DIR))
$(call colored_print,$(ANSI_FG_BLACK),BINARY_LIB_HEADERS : $(BINARY_LIB_HEADERS))
$(call colored_print,$(ANSI_FG_BLACK),================= Generated Vars =================)
$(call colored_print,$(ANSI_FG_BLACK),BINARY_EXEC       : $(BINARY_EXEC))
$(call colored_print,$(ANSI_FG_BLACK),BINARY_LIB_STATIC : $(BINARY_LIB_STATIC))
$(call colored_print,$(ANSI_FG_BLACK),BINARY_LIB_SHARED : $(BINARY_LIB_SHARED))
$(call colored_print,$(ANSI_FG_BLACK),OBJS              : $(OBJS))
$(call colored_print,$(ANSI_FG_BLACK),INC_FLAGS         : $(INC_FLAGS))
$(call colored_print,$(ANSI_FG_BLACK),================ Common variables ================)
$(call colored_print,$(ANSI_FG_BLACK),AS  : $(AS))
$(call colored_print,$(ANSI_FG_BLACK),CC  : $(CC))
$(call colored_print,$(ANSI_FG_BLACK),CXX : $(CXX))
$(call colored_print,$(ANSI_FG_BLACK),AR  : $(AR))
$(call colored_print,$(ANSI_FG_BLACK),RM  : $(RM))
$(call colored_print,$(ANSI_FG_BLACK),====================== Flags =====================)
$(call colored_print,$(ANSI_FG_BLACK),CPPFLAGS : $(CPPFLAGS))
$(call colored_print,$(ANSI_FG_BLACK),CFLAGS   : $(CFLAGS))
$(call colored_print,$(ANSI_FG_BLACK),CXXFLAGS : $(CXXFLAGS))
$(call colored_print,$(ANSI_FG_BLACK),LDFLAGS  : $(LDFLAGS))
$(call colored_print,$(ANSI_FG_BLACK),====================== DEPS ======================)
$(call colored_print,$(ANSI_FG_BLACK),DEPS : $(DEPS))
endif
