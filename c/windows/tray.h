#pragma once
#ifdef _WIN32

#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <shellapi.h>
#include <stdbool.h>

#define WM_TRAYICON (WM_USER + 1)
#define ID_TRAYICON 100

typedef struct VTrayParamsWindows VTrayParamsWindows;
typedef struct MenuItemWindows MenuItemWindows;

typedef void (*CallbackFunction)(int id);

struct VTrayParamsWindows
{
    char *identifier;
    wchar_t *tooltip;
    char *icon;
    CallbackFunction on_click;
};

struct MenuItemWindows
{
    int id;
    wchar_t *text;
    bool checked;
    bool disabled;
    bool checkable;
};

struct VTray
{
    char identifier[256];
    NOTIFYICONDATA notifyData;
    HMENU menu;
    WNDCLASSEX windowClass;
    HINSTANCE hInstance;
    HWND hwnd;
    wchar_t *tooltip;
    CallbackFunction on_click;
    struct MenuItemWindows **items;
    size_t num_items;
};

struct VTray *vtray_init_windows(VTrayParamsWindows *params, size_t num_items, struct MenuItemWindows *items[]);

void vtray_exit_windows(struct VTray *tray);

void vtray_update_windows(struct VTray *tray);

void vtray_construct(struct VTray *parent);

void vtray_update_menu_item(struct VTray *tray, int menu_id, bool checked);

// BOOL is_menu_item_disabled(HMENU menu, UINT menuId);

BOOL is_menu_item_checked(HMENU menu, UINT menuId);

MENUITEMINFO get_menu_item_by_id(HMENU menu, UINT menu_id);

MenuItemWindows *get_vmenu_item_by_id(int menu_id, struct VTray *tray);

void vtray_run_windows(struct VTray *tray);

#endif