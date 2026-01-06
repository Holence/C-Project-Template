#ifndef __DEBUG_H__
#define __DEBUG_H__

#include <assert.h>
#include <stdio.h>

#define ANSI_FG_BLACK   "\33[1;30m"
#define ANSI_FG_RED     "\33[1;31m"
#define ANSI_FG_GREEN   "\33[1;32m"
#define ANSI_FG_YELLOW  "\33[1;33m"
#define ANSI_FG_BLUE    "\33[1;34m"
#define ANSI_FG_MAGENTA "\33[1;35m"
#define ANSI_FG_CYAN    "\33[1;36m"
#define ANSI_FG_WHITE   "\33[1;37m"
#define ANSI_BG_BLACK   "\33[1;40m"
#define ANSI_BG_RED     "\33[1;41m"
#define ANSI_BG_GREEN   "\33[1;42m"
#define ANSI_BG_YELLOW  "\33[1;43m"
#define ANSI_BG_BLUE    "\33[1;44m"
#define ANSI_BG_MAGENTA "\33[1;45m"
#define ANSI_BG_CYAN    "\33[1;46m"
#define ANSI_BG_WHITE   "\33[1;47m"
#define ANSI_NONE       "\33[0m"

#define ANSI_FMT(ANSI_COLOR, str) ANSI_COLOR str ANSI_NONE

#define ColorPrintStdout(ANSI_COLOR, format, ...) \
    fprintf(stdout, ANSI_FMT(ANSI_COLOR, format) "\n", ##__VA_ARGS__)
#define ColorPrintStderr(ANSI_COLOR, format, ...) \
    fprintf(stderr, ANSI_FMT(ANSI_COLOR, format) "\n", ##__VA_ARGS__)
#define ColorPrint(ANSI_COLOR, format, ...) \
    ColorPrintStdout(ANSI_COLOR, format, ##__VA_ARGS__)

#if defined(CONFIG_ENABLE_DEBUG_LOGGING) && CONFIG_ENABLE_DEBUG_LOGGING
#define ColorLog(ANSI_COLOR, format, ...) \
    ColorPrintStdout(ANSI_COLOR, "[%s:%d %s] " format, __FILE__, __LINE__, __func__, ##__VA_ARGS__)
#define Log(format, ...) \
    ColorLog(ANSI_FG_BLUE, format, ##__VA_ARGS__)
#define Debug(format, ...) \
    ColorLog(ANSI_FG_YELLOW, format, ##__VA_ARGS__)
#define Error(format, ...) \
    ColorPrintStderr(ANSI_FG_RED, "[%s:%d %s] " format, __FILE__, __LINE__, __func__, ##__VA_ARGS__)
#else
#define ColorLog(...)
#define Log(...)
#define Debug(...)
#define Error(...)
#endif

// Assert() is for inner state checking
// should cause crash when failed, even after release
#define Assert(cond, ...)                      \
    do {                                       \
        if (!(cond)) {                         \
            fflush(stdout);                    \
            Error("Assert failed: %s", #cond); \
            Error(__VA_ARGS__);                \
            exit(1);                           \
        }                                      \
    } while (0)

#if defined(CONFIG_ENABLE_DEBUG_ASSERT) && CONFIG_ENABLE_DEBUG_ASSERT
// Same as Assert(), but can be turned off
#define DebugAssert(cond, ...) \
    Assert(##__VA_ARGS__)

// Require() is for validating function arg
// only used during development
// must not fail when release
#define Require(cond)                           \
    do {                                        \
        if (!(cond)) {                          \
            Error("Require failed: %s", #cond); \
            exit(1);                            \
        }                                       \
    } while (0)

// TODO() is for todo
// only used during development
// must not fail when release
#define TODO()         \
    do {               \
        Error("TODO"); \
        exit(1);       \
    } while (0)
#else
#define DebugAssert(...)
#define Require(...)
#define TODO(...)
#endif

#endif
