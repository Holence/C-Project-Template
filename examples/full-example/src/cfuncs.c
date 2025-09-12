#include <stdio.h>
#include <math.h>  // will require -lm
#include "asm.h"
#include "cfuncs.h"

void c_function(void) {
    int v = call_me_from_c();
    double root = sqrt((double)v);  // uses libm
    printf("[C] Value from asm = %d, sqrt = %.2f\n", v, root);
}
