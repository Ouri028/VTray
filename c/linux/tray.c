#ifdef __linux__
#include "tray.h"
void tray_icon_activate(GtkMenuItem *item, gpointer user_data)
{
    // Handle tray icon click event here
    // You can perform actions when the tray icon is clicked
}

struct VTray *vtray_init_linux(const char *identifier, const char *icon_path, const char *tooltip)
{
    struct VTray *tray = (struct VTray *)malloc(sizeof(struct VTray));
    strncpy(tray->identifier, identifier, sizeof(tray->identifier));
    strncpy(tray->tooltip, tooltip, sizeof(tray->tooltip));

    if (!tray)
    {
        free(tray);
        fprintf(stderr, "Failed to create window\n");
        return NULL;
    }

    gtk_init(NULL, NULL);

    tray->indicator = app_indicator_new(tray->identifier, icon_path, APP_INDICATOR_CATEGORY_APPLICATION_STATUS);
    app_indicator_set_status(tray->indicator, APP_INDICATOR_STATUS_ACTIVE);
    app_indicator_set_attention_icon(tray->indicator, icon_path);
    app_indicator_set_menu(tray->indicator, GTK_MENU(tray_icon_create_menu()));
    app_indicator_set_label(tray->indicator, tray->tooltip, NULL);

    return tray;
}

GtkMenu *tray_icon_create_menu()
{
    // Create a menu for your tray icon here
    GtkMenu *menu = GTK_MENU(gtk_menu_new());

    // Add menu items
    GtkWidget *menu_item = gtk_menu_item_new_with_label("Item 1");
    g_signal_connect(menu_item, "activate", G_CALLBACK(tray_icon_activate), NULL);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);

    menu_item = gtk_menu_item_new_with_label("Item 2");
    g_signal_connect(menu_item, "activate", G_CALLBACK(tray_icon_activate), NULL);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);

    // Add a quit item
    menu_item = gtk_menu_item_new_with_label("Quit");
    g_signal_connect(menu_item, "activate", G_CALLBACK(gtk_main_quit), NULL);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);

    return menu;
}

void vtray_exit_linux(struct VTray *tray)
{
    // Deallocate memory, destroy windows, etc.
    if (tray)
    {
        app_indicator_unref(tray->indicator);
        free(tray);
    }
}

void vtray_update(struct VTray *tray)
{
    // Update the system tray icon and menu as needed.
}

void vtray_run_linux(struct VTray *tray)
{
    // Show and run your Linux application loop here.
    gtk_main();
}

#endif