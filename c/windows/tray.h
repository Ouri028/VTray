#pragma once
#ifdef _WIN32

#include <windows.h>
#include <string.h>
#include <stdbool.h>
#include <shellapi.h>
#include <stdbool.h>
#include "utils.h"

#define WM_TRAYICON (WM_USER + 1)
#define ID_TRAYICON 100

typedef struct VTrayParams VTrayParams;
typedef struct VTrayMenuItem VTrayMenuItem;

typedef void (*CallbackFunction)(VTrayMenuItem *menu_item);

struct VTrayParams
{
    String identifier;
    String tooltip;
    String icon;
    CallbackFunction on_click;
};

struct VTrayMenuItem
{
    int id;
    String text;
    bool checked;
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
    struct VTrayMenuItem **items;
    size_t num_items;
};

struct VTray *vtray_init(VTrayParams *params, size_t num_items, struct VTrayMenuItem *items[]);

void vtray_exit(struct VTray *tray);

void vtray_update(struct VTray *tray);

void vtray_construct(struct VTray *parent);

void vtray_update_menu_item(struct VTray *tray, int menu_id, bool checked);

// BOOL is_menu_item_disabled(HMENU menu, UINT menuId);

BOOL is_menu_item_checked(HMENU menu, UINT menuId);

MENUITEMINFO get_menu_item_by_id(HMENU menu, UINT menu_id);

VTrayMenuItem *get_vmenu_item_by_id(int menu_id, struct VTray *tray);

void vtray_run(struct VTray *tray);

#endif