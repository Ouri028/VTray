#ifdef _WIN32
#include "utils.h"
char *string_to_char(String string)
{
    if (string.str == NULL)
    {
        perror("string_to_char: string is NULL");
        return NULL;
    }
    return string.str;
}

int len(String string)
{
    return string.len;
}

bool string_empty(String string)
{
    if (len(string) == 0)
    {
        return true;
    }
    return false;
}

wchar_t *char_to_wchar_t(char *c)
{
    if (c == NULL)
    {
        perror("char_to_wchar_t: string is NULL");
        return NULL;
    }
    size_t len = strlen(c) + 1;
    wchar_t *w = malloc(len * sizeof(wchar_t));
    if (w == NULL)
    {
        perror("char_to_wchar_t: failed to allocate memory");
        return NULL;
    }
    size_t converted = 0;
    mbstowcs_s(&converted, w, len, c, _TRUNCATE);
    return w;
}

wchar_t *string_to_wchar_t(String string)
{
    char *c = string_to_char(string);
    return char_to_wchar_t(c);
}

#endif