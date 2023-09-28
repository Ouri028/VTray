#pragma once

#ifdef __APPLE__

#include <Cocoa/Cocoa.h>
#include <Foundation/Foundation.h>

typedef struct VTrayParamsMac VTrayParamsMac;
typedef struct MenuItemMac MenuItemMac;

typedef void (*CallbackFunction)(int id);

struct VTrayParamsMac
{
    string identifier;
    string tooltip;
    string icon;
    CallbackFunction on_click;
};

struct MenuItemMac
{
    int id;
    string text;
};

struct VTray
{
    NSStatusItem *statusItem;
    NSMenu *menu;
};

struct VTray *vtray_init_mac(VTrayParamsMac *params, size_t num_items, MenuItemMac *items[]);

void vtray_exit_mac(struct VTray *tray);

void vtray_construct(struct MenuItemMac *items[], size_t num_items, struct VTray *parent);

void vtray_run_mac(struct VTray *tray);

#endif
