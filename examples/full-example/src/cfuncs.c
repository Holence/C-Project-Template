#include <stdio.h>
#include "cfuncs.h"

static uint8_t c_var = 0xc;
uint8_t c_func() {
    printf("[%s:%d] Hello from C!\n", __FILE__, __LINE__);
    return c_var;
}
