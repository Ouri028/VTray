#ifdef __linux__
#include "tray.h"

void *GLOBAL_TRAY = NULL;

static void on_menu_item_clicked(GtkMenuItem *menu_item, gpointer user_data)
{
    struct VTrayMenuItem *item = (struct VTrayMenuItem *)user_data;
    struct VTray *tray = (struct VTray *)get_global_vtray();
    if (tray != NULL)
    {
        tray->on_click(item);
    }
    else
    {
        printf("Global pointer is NULL\n");
    }
}

struct VTray *vtray_init(VTrayParams *params, size_t num_items, struct VTrayMenuItem *items[])
{
    struct VTray *tray = (struct VTray *)malloc(sizeof(struct VTray));
    if (!tray)
    {
        // Handle allocation failure
        fprintf(stderr, "Failed to allocate VTray!\n");
        return NULL;
    }

    gtk_init(NULL, NULL);

    tray->indicator = app_indicator_new(string_to_char(params->identifier), string_to_char(params->icon), APP_INDICATOR_CATEGORY_APPLICATION_STATUS);
    // Set the tooltip text for the indicator
    app_indicator_set_title(tray->indicator, string_to_char(params->tooltip));
    app_indicator_set_status(tray->indicator, APP_INDICATOR_STATUS_ACTIVE);
    app_indicator_set_attention_icon_full(tray->indicator, string_to_char(params->identifier), "New messages");
    app_indicator_set_menu(tray->indicator, GTK_MENU(tray->menu));

    tray->on_click = params->on_click;
    tray->items = items;
    tray->num_items = num_items;
    vtray_construct(tray);
    // Create the menu

    return tray;
}

void set_global_vtray(void *ptr)
{
    GLOBAL_TRAY = ptr;
}

void *get_global_vtray()
{
    return GLOBAL_TRAY;
}

void vtray_construct(struct VTray *parent)
{
    parent->menu = gtk_menu_new();

    if (parent->menu)
    {
        for (size_t i = 0; i < num_items; i++)
        {
            struct VTrayMenuItem *item = tray->items[i];
            GtkWidget *menu_item = gtk_menu_item_new_with_label(string_to_char(item->text));
            g_signal_connect(menu_item, "activate", G_CALLBACK(on_menu_item_clicked), item);
            gtk_menu_shell_append(GTK_MENU_SHELL(parent->menu), menu_item);
            gtk_widget_show(menu_item);
        }
    }

    gtk_widget_show_all(parent->menu);
    app_indicator_set_menu(parent->indicator, GTK_MENU(parent->menu));
    set_global_vtray(parent);
}

void vtray_exit(struct VTray *tray)
{
    // Deallocate memory, destroy the indicator, etc.
    if (tray)
    {
        if (tray->indicator)
            g_object_unref(tray->indicator);
        free(tray);
        gtk_main_quit();
        exit(1);
    }
}

void vtray_run(struct VTray *tray)
{
    // Run the GTK main loop
    gtk_main();
}

void vtray_update(struct VTray *tray)
{
    // Update the system tray icon and menu as needed
    app_indicator_set_status(tray->indicator, APP_INDICATOR_STATUS_ACTIVE);
}

#endif