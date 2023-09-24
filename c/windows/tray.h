#pragma once
#ifdef _WIN32

#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <shellapi.h>

#define WM_TRAYICON (WM_USER + 1)
#define ID_TRAYICON 100

typedef struct VTrayParams VTrayParams;
typedef struct VTrayMenuItem VTrayMenuItem;

typedef void (*CallbackFunction)(int id);

struct VTrayParams {
    char *identifier;
    wchar_t *tooltip;
    char *icon;
    CallbackFunction on_click;
};

struct VTrayMenuItem {
    int id;
    char *text;
    bool disabled;
    bool toggled;
    char *image;
};

struct VTray {
    char identifier[256];
    NOTIFYICONDATA notifyData;
    HMENU menu;
    WNDCLASSEX windowClass;
    HINSTANCE hInstance;
    HWND hwnd;
    wchar_t *tooltip;
    CallbackFunction on_click;
};


struct VTray *vtray_init_windows(VTrayParams *params, size_t num_items, struct VTrayMenuItem *items[]);

void vtray_exit_windows(struct VTray *tray);

void vtray_update_windows(struct VTray *tray);

void vtray_construct(struct VTrayMenuItem *items[], size_t num_items, struct VTray *parent);

void vtray_run_windows(struct VTray *tray);

#endif