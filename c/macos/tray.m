#ifdef __APPLE__
#include "tray.h"


// Callback for the tray icon click
void vtray_on_click(NSMenuItem *sender) {
     struct MenuItemMac *item =
      (struct MenuItemMac *)[[sender representedObject] pointerValue];
  if (item) {
    trayParams.on_click(item->id);
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
    tray->statusItem.toolTip = [NSString stringWithUTF8String:params->tooltip];
    tray->statusItem.button.image = [NSImage imageNamed:[NSString stringWithUTF8String:params->icon]];

    // Create a menu
    tray->menu = [[NSMenu alloc] initWithTitle:params->tooltip];
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
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithUTF8String:item->text] action:@selector(vtray_on_click:) keyEquivalent:@""];
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
