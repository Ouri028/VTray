#ifdef __linux__
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

size_t len(String string)
{
    return string.len;
}
#endif