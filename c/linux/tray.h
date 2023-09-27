#pragma once
#ifdef __linux__
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libayatana-appindicator3-0.1/libayatana-appindicator/app-indicator.h>
#include <gtk/gtk.h>

typedef struct VTrayParamsLinux VTrayParamsLinux;
typedef struct MenuItemLinux MenuItemLinux;

typedef void (*CallbackFunction)(int id);

struct VTray {
    AppIndicator *indicator;
    GtkWidget *menu;
    CallbackFunction on_click;
};

struct VTrayParamsLinux {
    char *identifier;
    char *tooltip;
    char *icon;
    CallbackFunction on_click;
};

struct MenuItemLinux {
    int id;
    char *text;
};

struct VTray *vtray_init_linux(VTrayParamsLinux *params, size_t num_items, struct MenuItemLinux *items[]);

void vtray_exit_linux(struct VTray *tray);

void vtray_update_linux(struct VTray *tray);

void vtray_construct(struct MenuItemLinux *items[], size_t num_items, struct VTray *parent);

void vtray_run_linux(struct VTray *tray);

void set_global_vtray(void* ptr);

void* get_global_vtray();

#endif
