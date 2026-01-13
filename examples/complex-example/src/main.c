#include <stdio.h>
#include "generated/autoconf.h"
#include "bridge/bridge.h"

int main(int argc, char const *argv[]) {
    printf("hello from main!\n");

#if CONFIG_USE_LIBA
    wrapper_func_a();
#endif

#if CONFIG_USE_LIBB
    wrapper_func_b();
#endif

    return 0;
}
