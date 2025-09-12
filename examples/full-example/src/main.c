#include <stdio.h>
#include "cfuncs.h"
#include "cppfuncs.hpp"
#include "asm.h"

int main(void) {
    printf("%s", startup_message);
    c_function();
    cpp_function();
    return 0;
}
