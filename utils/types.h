#ifndef __TYPES_H__
#define __TYPES_H__

#include <stdbool.h>
#include <stdint.h>
#include "sys/types.h"

_Static_assert(sizeof(ssize_t) == sizeof(size_t), "sizeof(ssize_t) should equals to sizeof(size_t)");

#endif