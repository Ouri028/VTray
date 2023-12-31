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
typedef struct MenuItem MenuItem;

typedef void (*CallbackFunction)(MenuItem *menu_item);

struct VTrayParams
{
    String identifier;
    String tooltip;
    String icon;
    CallbackFunction on_click;
};

struct MenuItem
{
    int id;
    String text;
    bool checked;
    bool checkable;
    bool disabled;
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
    struct MenuItem **items;
    size_t num_items;
};

struct VTray *vtray_init(VTrayParams *params, size_t num_items, struct MenuItem *items[]);

void vtray_exit(struct VTray *tray);

void vtray_update(struct VTray *tray);

void vtray_construct(struct VTray *parent);

void vtray_update_menu_item(struct VTray *tray, int menu_id, bool checked);

void vtray_set_icon(char *icon, struct VTray *tray);

void vtray_set_tooltip(char *tooltip, struct VTray *tray);

BOOL is_menu_item_checked(HMENU menu, UINT menuId);

MENUITEMINFO get_menu_item_by_id(HMENU menu, UINT menu_id);

MenuItem *get_vmenu_item_by_id(int menu_id, struct VTray *tray);

void vtray_run(struct VTray *tray);

#endif