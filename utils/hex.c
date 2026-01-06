#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

#include "debug.h"
#include "hex.h"

/// @brief dump memory in addr[0:len]
/// @param addr 起始地址
/// @param len 往后打印多少长度
/// @param num_per_line 每行打印多少个byte
void _hex_dump(void *addr, size_t len, size_t num_per_line) {
    const unsigned char *p = (const unsigned char *)addr;
    size_t offset = 0;
    while (offset < len) {
        printf("%p: ", (const void *)(p + offset));
        for (size_t i = 0; i < num_per_line; i++) {
            if (offset + i < len)
                printf("%02X ", p[offset + i]);
            else
                printf("   ");
        }
        printf("| ");
        for (size_t i = 0; i < num_per_line && offset + i < len; i++) {
            unsigned char c = p[offset + i];
            printf("%c", isprint(c) ? c : '.');
        }
        printf("\n");
        offset += num_per_line;
    }
}

/// @brief 将 bytes[] 转换为 hex字符串(大写), 并在最后附加 '\0'
/// @param bytes 输入读取 bytes[] 的地址
/// @param bytes_len 输入读取 bytes[] 的长度
/// @param hex 输出写入 hex字符串 的地址, 其空间至少得有 `bytes_len*2 + 1`
/// @param switch_endian 是否需要转换大小端
/// @return 写入的长度，即`bytes_len*2`
/// @note require `bytes[] != hex[]`
size_t bytes_to_hex(const uint8_t bytes[], size_t bytes_len, char hex[], bool switch_endian) {
    Require(bytes != NULL);
    Require(hex != NULL);
    Require((void *)bytes != (void *)hex);

    static const char hex_lut[] = "0123456789ABCDEF";
    const uint8_t *bytes_ptr = switch_endian ? bytes + bytes_len - 1 : bytes;
    const int step = switch_endian ? -1 : 1;
    for (size_t i = 0; i < bytes_len; i++) {
        uint8_t b = *bytes_ptr;
        *(hex++) = hex_lut[b >> 4];
        *(hex++) = hex_lut[b & 0x0F];
        bytes_ptr += step;
    }
    *hex = '\0';
    return bytes_len << 1;
}

/// @brief convert ASCII hex char to 0x00-0x0F
/// @param c
/// @return 0x00-0x0F if valid, 0xFF if invalid
static inline uint8_t parse_hex_char(char c) {
    if ((c >= '0') && (c <= '9')) return c - '0';
    if ((c >= 'A') && (c <= 'F')) return c - 'A' + 10;
    if ((c >= 'a') && (c <= 'f')) return c - 'a' + 10;
    return 0xFF;  // invalid
}

/// @brief 将 hex字符串 转换为 bytes[]
/// @param hex 输入读取 hex字符串 的地址
/// @param hex_len 输入读取 hex字符串 不包含`\0`的长度 (即`strlen(hex)`的返回结果), 且必须为偶数
/// @param bytes 输出写入 bytes[] 的地址, 其空间至少得有 `hex_len/2`
/// @param switch_endian 是否需要转换大小端
/// @return 写入的长度，即`hex_len/2`。如果失败的话，返回0
/// @note require `hex[] != bytes[]`
size_t hex_to_bytes(const char hex[], size_t hex_len, uint8_t bytes[], bool switch_endian) {
    Require(bytes != NULL);
    Require(hex != NULL);
    Require((void *)bytes != (void *)hex);
    Require((hex_len & 1) == 0);

    const size_t bytes_len = hex_len >> 1;
    uint8_t *bytes_ptr = switch_endian ? bytes + bytes_len - 1 : bytes;
    const int step = switch_endian ? -1 : 1;
    for (size_t i = 0; i < bytes_len; i++) {
        uint8_t hi = parse_hex_char(*(hex++));
        uint8_t lo = parse_hex_char(*(hex++));
        if ((hi | lo) == 0xFF) {
            return 0;
        }

        *bytes_ptr = (hi << 4) | lo;
        bytes_ptr += step;
    }
    return bytes_len;
}