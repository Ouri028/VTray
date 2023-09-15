#pragma once
#ifdef __linux__
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <app-indicator.h>
#include <gtk/gtk.h>

struct VTray
{
    char identifier[256];
    char tooltip[128];

    AppIndicator *indicator;
};

struct VTray *vtray_init_linux(const char *identifier, const gchar *icon, const gchar *tooltip);
void vtray_exit_linux(struct VTray *tray);
void vtray_run_linux(struct VTray *tray);
#endif
