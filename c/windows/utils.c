#include "utils.h"

#ifdef _WIN32
char *string_to_char(String string)
{
    if (string.str == NULL)
    {
        perror("string_to_char: string is NULL");
        return NULL;
    }
    return string.str;
}

size_t len(String string)
{
    return string.len;
}

wchar_t *char_to_wchar_t(char *c)
{
    if (c == NULL)
    {
        perror("char_to_wchar_t: string is NULL");
        return NULL;
    }
    size_t len = mbstowcs(NULL, c, 0) + 1;
    wchar_t *w = malloc(len * sizeof(wchar_t));
    if (w == NULL)
    {
        perror("char_to_wchar_t: failed to allocate memory");
        return NULL;
    }
    mbstowcs(w, c, len);
    return w;
}

wchar_t *string_to_wchar_t(String string)
{
    char *c = string_to_char(string);
    return char_to_wchar_t(c);
}
#endif