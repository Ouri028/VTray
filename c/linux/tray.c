#ifdef __linux__
#include "tray.h"

static void menu_item_activate(GtkMenuItem *menu_item, gpointer user_data) {
    guint menu_id = GPOINTER_TO_UINT(g_object_get_data(G_OBJECT(menu_item), "menu-id"));
    struct VTray *tray = (struct VTray *)user_data;
    tray->on_click(menu_id);
}

struct VTray *vtray_init_linux(VTrayParamsLinux *params, size_t num_items, struct MenuItemLinux *items[]) {
    struct VTray *tray = (struct VTray *)malloc(sizeof(struct VTray));
    if (!tray) {
        // Handle allocation failure
        fprintf(stderr, "Failed to allocate VTray!\n");
        return NULL;
    }

    gtk_init(NULL, NULL);

    tray->indicator = app_indicator_new(params->identifier, params->icon, APP_INDICATOR_CATEGORY_APPLICATION_STATUS);
     // Set the tooltip text for the indicator
    app_indicator_set_title(tray->indicator, params->tooltip);
    app_indicator_set_status(tray->indicator, APP_INDICATOR_STATUS_ACTIVE);
    app_indicator_set_attention_icon_full(tray->indicator, params->identifier, "New messages");
    app_indicator_set_menu(tray->indicator, GTK_MENU(tray->menu));

    tray->on_click = params->on_click;

    // Create the menu
    tray->menu = gtk_menu_new();

    for (size_t i = 0; i < num_items; i++) {
        GtkWidget *menu_item = gtk_menu_item_new_with_label(items[i]->text);
        g_object_set_data(G_OBJECT(menu_item), "menu-id", GUINT_TO_POINTER(items[i]->id));
        g_signal_connect(menu_item, "activate", G_CALLBACK(menu_item_activate), tray);
        gtk_menu_shell_append(GTK_MENU_SHELL(tray->menu), menu_item);
        gtk_widget_show(menu_item);
    }

    return tray;
}

void vtray_exit_linux(struct VTray *tray) {
    // Deallocate memory, destroy the indicator, etc.
    if (tray) {
        if (tray->indicator)
            g_object_unref(tray->indicator);
        free(tray);
        gtk_main_quit();
    }
}

void vtray_run_linux(struct VTray *tray) {
    // Run the GTK main loop
    gtk_main();
}

void vtray_update_linux(struct VTray *tray) {
    // Update the system tray icon and menu as needed
    app_indicator_set_status(tray->indicator, APP_INDICATOR_STATUS_ACTIVE);
}

#endif