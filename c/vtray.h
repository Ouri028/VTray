#pragma once
#ifdef _WIN32
#include "windows/tray.h"
#elif __linux__
#include "linux/tray.h"
#endif
