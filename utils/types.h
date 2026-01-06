#ifndef __TYPES_H__
#define __TYPES_H__

#include <stdbool.h>
#include <stdint.h>

#define size_t  uintptr_t
#define ssize_t intptr_t
_Static_assert(sizeof(ssize_t) == sizeof(size_t), "sizeof(ssize_t) should equals to sizeof(size_t)");

#endif