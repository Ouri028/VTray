#pragma once
#ifdef __linux__
#include <stdio.h>

typedef struct String String;

struct String
{
    char *str;
    size_t len;
};

char *string_to_char(String string);
size_t len(String string);
#endif