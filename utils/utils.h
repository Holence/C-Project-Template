#ifndef __UTILS_H__
#define __UTILS_H__
#include "utils/types.h"

/// @brief count number of digits in `n`
/// @note if `n==0`, return `1`
static inline size_t count_digits(size_t n) {
    size_t digits = 0;
    do {
        digits++;
        n /= 10;
    } while (n != 0);
    return digits;
}

#endif