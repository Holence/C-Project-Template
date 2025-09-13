#include <stdio.h>
#include "cfuncs.h"

uint8_t c_func() {
    printf("[%s:%d] Hello from C!\n", __FILE__, __LINE__);
    return 0xc;
}
