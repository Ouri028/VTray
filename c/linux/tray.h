#pragma once
#ifdef __linux__
#include <stdlib.h>
#include <string.h>
#include <libayatana-appindicator3-0.1/libayatana-appindicator/app-indicator.h>
#include <gtk/gtk.h>
#include <stdbool.h>
#include "utils.h"

typedef struct VTrayParams VTrayParams;
typedef struct VTrayMenuItem VTrayMenuItem;
typedef void (*CallbackFunction)(VTrayMenuItem *menu_item);

struct VTray
{
    AppIndicator *indicator;
    GtkWidget *menu;
    CallbackFunction on_click;
    struct VTrayMenuItem **items;
    size_t num_items;
    size_t num_menus;
    GtkMenuItem **menus;
};

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
    bool disabled;
};

struct VTray *vtray_init(VTrayParams *params, size_t num_items, struct VTrayMenuItem *items[]);

void vtray_run(struct VTray *tray);

void vtray_exit(struct VTray *tray);

void vtray_update(struct VTray *tray);

void vtray_construct(struct VTray *parent);

void vtray_update_menu_item(struct VTray *tray, int menu_id);

GtkMenuItem *get_menu_item_by_label(struct VTray *tray, char *label);

VTrayMenuItem *get_vmenu_item_by_id(int menu_id, struct VTray *tray);

void set_global_vtray(void *ptr);

void *get_global_vtray();

#endif
