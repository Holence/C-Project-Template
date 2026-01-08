#include <stdio.h>
#include "generated/autoconf.h"

char *version() {
    return CONFIG_VERSION;
}

int add(int a, int b) {
    printf("[libmymath][%s:%d] calculating %d+%d\n", __FILE__, __LINE__, a, b);
    return a + b;
}

int minus(int a, int b) {
    printf("[libmymath][%s:%d] calculating %d-%d\n", __FILE__, __LINE__, a, b);
    return a - b;
}
