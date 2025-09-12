#include <stdio.h>
#include "generated/autoconf.h"

int main(int argc, char const *argv[]) {
    printf("hello world, I'm %s", CONFIG_MY_NAME);
    return 0;
}
