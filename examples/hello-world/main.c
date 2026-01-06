#include <stdio.h>

#define CONFIG_ENABLE_DEBUG_LOGGING 1
#include "utils/debug.h"
#include "utils/hex.h"
#include <string.h>
#include <stdlib.h>

int main(int argc, char const *argv[]) {
    Log("Hello world");

    for (int i = 0; i < argc; i++) {
        printf("argv[%d]: %s\n", i, argv[i]);
    }

    char s1[] = "this string lives on stack";
    hex_dump(s1, strlen(s1), 8);
    ColorPrintByteArray(ANSI_FG_GREEN, s1, strlen(s1));

    char *s2 = malloc(32);
    strcpy(s2, "this string lives on heap");
    hex_dump(s2, strlen(s2), 8);
    ColorPrintByteArray(ANSI_FG_MAGENTA, s2, strlen(s2));
    free(s2);

    char *s3 = "this string lives on .rodata";
    hex_dump(s3, strlen(s3), 8);
    ColorPrintByteArray(ANSI_FG_BLACK, s3, strlen(s3));

    return 0;
}
