#include <stdio.h>
#include "generated/autoconf.h"
#include "wrapper.h"

int main(int argc, char const *argv[]) {
    printf("hello from main!\n");

#if CONFIG_USE_LIBA
    printf("func_a(): %d\n", wrapper_func_a());
#endif

#if CONFIG_USE_LIBB
    printf("func_b(): %d\n", wrapper_func_b());
#endif

    return 0;
}
