#ifdef __APPLE__
#include "tray.h"

void *GLOBAL_TRAY = NULL;

static NSString *nsstring(char* c_string {
  return [NSString stringWithUTF8String:c_string];
}

// Callback for the tray icon click
void on_menu_item_clicked(NSMenuItem *menuItem) {
    MenuItemMac *item = (MenuItemMac *)menuItem.representedObject;
    VTray *tray = (__bridge VTray *)get_global_vtray();
    if (tray != nil) {
        const char *itemId = [item.text UTF8String];
        tray->on_click(itemId);
    } else {
        NSLog(@"Global pointer is NULL");
    }
}


// Create and initialize your VTray instance
struct VTray *vtray_init_mac(VTrayParamsMac *params, size_t num_items, MenuItemMac *items[]) {
    struct VTray *tray = (struct VTray *)malloc(sizeof(struct VTray));
    if (!tray) {
        // Handle allocation failure
        fprintf(stderr, "Unable to allocate memory for VTray!\n");
        exit(1);
    }

    // Initialize the NSApplication
    [NSApplication sharedApplication];

    // Create a status item in the system menu bar
    tray->statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    // Deprecated
    tray->statusItem.toolTip = [NSString stringWithUTF8String:nsstring(params->tooltip)];
    tray->statusItem.button.image = [NSImage imageNamed:[NSString stringWithUTF8String:nsstring(params->icon)]];

    // Create a menu
    tray->menu = [[NSMenu alloc] initWithTitle:nsstring(params->tooltip)];
    vtray_construct(items, num_items, tray);
    tray->statusItem.menu = tray->menu;

    // Set the callback for menu item clicks
    [NSApp setDelegate:(id<NSApplicationDelegate>)tray];
    [NSApp run];

    return tray;
}


void vtray_construct(MenuItemMac *items[], size_t num_items, struct VTray *parent) {
    if (parent->menu) {
        for (size_t i = 0; i < num_items; i++) {
            MenuItemMac *item = items[i];
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithUTF8String:nsstring(item->text)] action:@selector(vtray_on_click:) keyEquivalent:@""];
            menuItem.tag = item->id;
            [menuItem setTarget:nil];
            [parent->menu addItem:menuItem];
        }
    }
    // Attach the menu to the status item
    [parent->statusItem setMenu:parent->menu];
}

void vtray_run_mac(struct VTray *tray) {
  NSApplication *app = (NSApplication *)(tray->app);
  [app run];
}


// Clean up and exit the application
void vtray_exit_mac(struct VTray *tray) {
    // Release resources, dealloc, and exit
    if (tray) {
        [NSStatusBar.systemStatusBar removeStatusItem:tray->statusItem];
        free(tray);
        [NSApp terminate:nil];
        exit(1);
    }
}
#endif
