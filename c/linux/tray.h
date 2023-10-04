#pragma once
#ifdef __linux__
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libayatana-appindicator3-0.1/libayatana-appindicator/app-indicator.h>
#include <gtk/gtk.h>
#include "utils.h"

typedef struct VTrayParams VTrayParams;
typedef struct VTrayMenuItem VTrayMenuItem;
typedef void (*CallbackFunction)(VTrayMenuItem *menu_item);

struct VTray
{
    AppIndicator *indicator;
    GtkWidget *menu;
    CallbackFunction on_click;
};

struct VTrayParams
{
    String identifier;
    String tooltip;
    String icon;
    CallbackFunction on_click;
    struct VTrayMenuItem **items;
    size_t num_items;
};

struct VTrayMenuItem
{
    int id;
    String text;
};

struct VTray *vtray_init(VTrayParams *params, size_t num_items, struct VTrayMenuItem *items[]);

void vtray_exit(struct VTray *tray);

void vtray_update(struct VTray *tray);

void vtray_construct(struct VTray *parent);

void vtray_run(struct VTray *tray);

void set_global_vtray(void *ptr);

void *get_global_vtray();

#endif
