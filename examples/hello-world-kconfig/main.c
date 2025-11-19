#include <stdio.h>
#include "generated/autoconf.h"

int main(int argc, char const *argv[]) {
    printf("Hello world, I'm %s\n", CONFIG_MY_NAME);
    for (int i = 0; i < argc; i++) {
        printf("argv[%d]: %s\n", i, argv[i]);
    }
    return 0;
}
