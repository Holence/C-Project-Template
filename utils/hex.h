#ifndef __HEX_H__
#define __HEX_H__

#include <stdint.h>
#include <stdbool.h>

#define PrintByteArray(array, len)                    \
    do {                                              \
        printf(#array ":\n");                         \
        for (size_t i = 0; i < len; i++) {            \
            printf("%02X ", ((uint8_t *)(array))[i]); \
            if ((i + 1) % 16 == 0) putchar('\n');     \
        }                                             \
        putchar('\n');                                \
    } while (0)

#define ColorPrintByteArray(ANSI_COLOR, array, len)   \
    do {                                              \
        printf(ANSI_COLOR #array ":\n");              \
        for (size_t i = 0; i < len; i++) {            \
            printf("%02X ", ((uint8_t *)(array))[i]); \
            if ((i + 1) % 16 == 0) putchar('\n');     \
        }                                             \
        printf(ANSI_NONE "\n");                       \
    } while (0)

#define hex_dump(addr, len, num_per_line)   \
    do {                                    \
        printf(#addr ":\n");                \
        _hex_dump(addr, len, num_per_line); \
    } while (0);

void _hex_dump(void *addr, size_t len, size_t num_per_line);
size_t bytes_to_hex(const uint8_t bytes[], size_t bytes_len, char hex[], bool switch_endian);
size_t hex_to_bytes(const char hex[], size_t hex_len, uint8_t bytes[], bool switch_endian);

#endif
