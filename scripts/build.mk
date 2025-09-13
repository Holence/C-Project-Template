# Copyright (C) 2025 Holence <Holence08@gmail.com>

# TODO "Final Binary File" could be .so or .a

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

ifneq ($(findstring 1, $V),)
  Q =
else
  Q = @
endif

# the name of "Final Binary File"
# default value: main.out
NAME ?= main.out

# all the source files (.s, .S, .c, .cpp)
# will be compiled into object files using compiler, see "Recipes"
# default value: all srcs under current working directory
SRCS ?= $(call find_srcs, .)

# the build dir
# default value: ./build
BUILD_DIR ?= ./build

# all dirs for searching header files
# will be used as -I flags for compiling
# default value: all dirs under current working directory
INC_DIRS ?= $(call find_dirs, .)

################################
#        Generated Vars        #
################################
# Generated Vars using Custom Config
# NAME -> BINARY
# SRCS -> OBJS
# INC_DIRS -> INC_FLAGS

# the "Final Binary File"
BINARY = $(BUILD_DIR)/$(NAME)

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

# CXX Compiler Flags
CXXFLAGS += $(CFLAGS)

# Linker Flags
LDFLAGS += $(SAN_FLAGS)
# CFLAGS += -flto
LDFLAGS += -Wl,--gc-sections
# LDFLAGS += -Wl,-Map=output.map

################################
#           Recipes            #
################################

# As an example, BUILD_DIR/hello.cpp.o turns into BUILD_DIR/hello.cpp.d
DEPS     := $(OBJS:.o=.d)
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

# Link all Object Files into "Final Binary File"
link_log = @echo "+ Link $@"
link_cmd = $(CXX) $^ -o $@ $(LDFLAGS)
$(BINARY): $(OBJS)
	$(link_log)
	$(Q)$(link_cmd)

################################
#            Rules             #
################################

.DEFAULT_GOAL = app
app: $(BINARY)
PHONY += app

run: app
	@$(BINARY)
PHONY += run

memcheck: app
	$(call run_memcheck, $(BINARY))
PHONY += memcheck

clean:
	-$(RM) -r $(BUILD_DIR)
PHONY += clean

clean-all: clean
PHONY += clean-all

help::
	@echo 'Main Targets:'
	@echo '    app              - compile (default target)'
	@echo '    run              - compile and run'
	@echo '    memcheck         - compile and memcheck'
	@echo 'Others:'
	@echo '    clean            - clean build files'
	@echo '    clean-all        - run all clean targets'
	@echo '    help             - show help text'
	@echo 'Variables:'
	@echo '    make V=1         - verbose'
PHONY += help

.PHONY: $(PHONY)

ifneq ($(findstring 1, $V),)
$(call colored_print,$(ANSI_FG_BLACK),---------- Custom Config -----------)
$(call colored_print,$(ANSI_FG_BLACK),NAME      : $(NAME))
$(call colored_print,$(ANSI_FG_BLACK),SRCS      : $(SRCS))
$(call colored_print,$(ANSI_FG_BLACK),BUILD_DIR : $(BUILD_DIR))
$(call colored_print,$(ANSI_FG_BLACK),INC_DIRS  : $(INC_DIRS))
$(call colored_print,$(ANSI_FG_BLACK),---------- Generated Vars ----------)
$(call colored_print,$(ANSI_FG_BLACK),BINARY    : $(BINARY))
$(call colored_print,$(ANSI_FG_BLACK),OBJS      : $(OBJS))
$(call colored_print,$(ANSI_FG_BLACK),INC_FLAGS : $(INC_FLAGS))
$(call colored_print,$(ANSI_FG_BLACK),--------- Common variables ---------)
$(call colored_print,$(ANSI_FG_BLACK),AS        : $(AS))
$(call colored_print,$(ANSI_FG_BLACK),CC        : $(CC))
$(call colored_print,$(ANSI_FG_BLACK),CXX       : $(CXX))
$(call colored_print,$(ANSI_FG_BLACK),RM        : $(RM))
$(call colored_print,$(ANSI_FG_BLACK),-------------- Flags ---------------)
$(call colored_print,$(ANSI_FG_BLACK),CPPFLAGS  : $(CPPFLAGS))
$(call colored_print,$(ANSI_FG_BLACK),CFLAGS    : $(CFLAGS))
$(call colored_print,$(ANSI_FG_BLACK),CXXFLAGS  : $(CXXFLAGS))
$(call colored_print,$(ANSI_FG_BLACK),LDFLAGS   : $(LDFLAGS))
$(call colored_print,$(ANSI_FG_BLACK),-------------- DEPS ----------------)
$(call colored_print,$(ANSI_FG_BLACK),DEPS      : $(DEPS))
endif
