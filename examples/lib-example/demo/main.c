#include <stdio.h>
#include <mymath.h>
#include <mymath/add.h>
#include <mymath/minus.h>

int main(int argc, char const *argv[]) {
    printf("libmymath version: %s\n", version());
    printf("1 + 113 = %d\n", add(1, 113));
    printf("515 - 1 =%d\n", minus(515, 1));
    return 0;
}
