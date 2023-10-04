#pragma once
#ifdef _WIN32
#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <locale.h>

typedef struct String String;

struct String
{
    char *str;
    size_t len;
};

char *string_to_char(String string);
size_t len(String string);
wchar_t *char_to_wchar_t(char *c);
wchar_t *string_to_wchar_t(String string);
#endif