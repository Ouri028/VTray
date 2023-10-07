#ifdef __linux__
#include "tray.h"

void *GLOBAL_TRAY = NULL;

static void on_menu_item_clicked(GtkMenuItem *menu_item, gpointer user_data)
{
    struct MenuItem *item = (struct MenuItem *)user_data;
    struct VTray *tray = (struct VTray *)get_global_vtray();
    if (tray != NULL)
    {
        vtray_update_menu_item(tray, item->id);
    }
    else
    {
        printf("Global pointer is NULL\n");
    }
}

static void on_toggle_menu_item_clicked(GtkCheckMenuItem *menu_item, gpointer user_data)
{
    struct MenuItem *item = (struct MenuItem *)user_data;
    struct VTray *tray = (struct VTray *)get_global_vtray();
    if (tray != NULL)
    {
        vtray_update_menu_item(tray, item->id);
    }
    else
    {
        printf("Global pointer is NULL\n");
    }
}

struct VTray *vtray_init(VTrayParams *params, size_t num_items, struct MenuItem *items[])
{
    struct VTray *tray = (struct VTray *)malloc(sizeof(struct VTray));
    if (!tray)
    {
        // Handle allocation failure
        fprintf(stderr, "Failed to allocate VTray!\n");
        return NULL;
    }

    gtk_init(NULL, NULL);
    tray->menu = gtk_menu_new();
    tray->indicator = app_indicator_new(string_to_char(params->identifier), string_to_char(params->icon), APP_INDICATOR_CATEGORY_APPLICATION_STATUS);

    // Set the tooltip text for the indicator
    app_indicator_set_title(tray->indicator, string_to_char(params->tooltip));
    app_indicator_set_label(tray->indicator, string_to_char(params->tooltip), "");
    app_indicator_set_status(tray->indicator, APP_INDICATOR_STATUS_ACTIVE);
    app_indicator_set_attention_icon_full(tray->indicator, string_to_char(params->identifier), "New messages");
    if (!GTK_IS_MENU(tray->menu))
    {
        fprintf(stderr, "Invalid menu instance!\n");
        return NULL;
    }

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
    if (parent->menu)
    {
        parent->num_menus = 0;

        for (size_t i = 0; i < parent->num_items; i++)
        {
            struct MenuItem *item = parent->items[i];
            GtkMenuItem *menu_item;

            if (item->checkable)
            {
                size_t len = parent->num_menus;
                menu_item = gtk_check_menu_item_new_with_label(string_to_char(item->text));
                gtk_check_menu_item_set_active(GTK_CHECK_MENU_ITEM(menu_item), item->checked);         // Set initial state to checked
                g_signal_connect(menu_item, "toggled", G_CALLBACK(on_toggle_menu_item_clicked), item); // Connect to the "toggled" signal
                parent->menus[len] = menu_item;
                parent->num_menus++;
            }
            else
            {
                size_t len = parent->num_menus;
                menu_item = gtk_menu_item_new_with_label(string_to_char(item->text));
                g_signal_connect(menu_item, "activate", G_CALLBACK(on_menu_item_clicked), item);
                parent->menus[len] = menu_item;
                parent->num_menus++;
            }
            if (item->disabled)
            {
                gtk_widget_set_sensitive(GTK_WIDGET(menu_item), FALSE);
            }
            gtk_menu_shell_append(GTK_MENU_SHELL(parent->menu), menu_item);
            gtk_widget_show(menu_item);
        }
        gtk_widget_show_all(parent->menu);
        app_indicator_set_menu(parent->indicator, GTK_MENU(parent->menu));
        set_global_vtray(parent);
    }
}

void vtray_update_menu_item(struct VTray *tray, int menu_id)
{
    MenuItem *item = get_vmenu_item_by_id(menu_id, tray);
    GtkMenuItem *menu_item = get_menu_item_by_label(tray, string_to_char(item->text));
    if (item == NULL)
    {
        fprintf(stderr, "Failed to find menu item with ID %d\n", menu_id);
        return;
    }

    if (!item->checkable)
    {
        tray->on_click(item);
        return;
    }
    if (gtk_check_menu_item_get_active(menu_item))
    {
        item->checked = true;
    }
    else
    {
        item->checked = false;
    }

    gtk_check_menu_item_set_active(GTK_CHECK_MENU_ITEM(menu_item), item->checked);

    tray->on_click(item);
}

GtkMenuItem *get_menu_item_by_label(struct VTray *tray, char *label)
{
    for (size_t i = 0; i < tray->num_menus; i++)
    {
        GtkMenuItem *menu_item = GTK_MENU_ITEM(tray->menus[i]);
        if (strcmp(gtk_menu_item_get_label(menu_item), label) == 0)
        {
            return menu_item;
        }
    }
    return NULL;
}

MenuItem *get_vmenu_item_by_id(int menu_id, struct VTray *tray)
{
    for (size_t i = 0; i < tray->num_items; i++)
    {
        if (tray->items[i]->id == menu_id)
        {
            return tray->items[i];
        }
    }
    return (MenuItem *){0};
}

void vtray_set_icon(char *icon, struct VTray *tray)
{
    // Update the icon
    app_indicator_set_icon_full(tray->indicator, icon, "");
    app_indicator_set_attention_icon_full(tray->indicator, icon, "");
}
// Set the tooltip for the system tray icon
void vtray_set_tooltip(char *tooltip, struct VTray *tray)
{
    app_indicator_set_title(tray->indicator, tooltip);
}

void vtray_exit(struct VTray *tray)
{
    // Deallocate memory, destroy the indicator, etc.
    if (tray)
    {
        if (tray->menus)
        {
            // Deallocate memory for individual menu items in the flexible array
            for (int i = 0; i < tray->num_menus; i++)
            {
                if (tray->menus[i] != NULL)
                {
                    gtk_widget_destroy(tray->menus[i]);
                }
            }
        }
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