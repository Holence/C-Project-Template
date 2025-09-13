#include <stdio.h>
#include "asmfuncs.h"
#include "cfuncs.h"
#include "cppfuncs.hpp"

#include <math.h>
#include <pthread.h>
#include <unistd.h>

static void *worker_thread(void *arg) {
    size_t i = (size_t)arg;
    usleep(100000 * i);
    printf("pthread worker [%zu] done\n", i);
    return NULL;
}

int main(void) {
    printf("char*  startup_message  from .S: %s\n", startup_message);
    printf("char*  asm_S_func()     from .S: %s\n", asm_S_func());
    printf("int    asm_s_func()     from .s: %d\n", asm_s_func());
    printf("uint_8 c_func()         from .c: %d\n", c_func());
    printf("float  cpp_func()       from .cpp: %f\n", cpp_func());
    printf("double sqrt() from math.h: %f\n", sqrt((double)cpp_func()));

    pthread_t tid[8];
    for (size_t i = 0; i < 8; i++) {
        pthread_create(tid + i, NULL, worker_thread, (void *)i);
    }
    for (size_t i = 0; i < 8; i++) {
        pthread_join(tid[i], NULL);
    }

    return 0;
}
