#ifdef __APPLE__
#include "tray.h"

// Callback for the tray icon click
void vtray_on_click(NSMenuItem *sender) {
    // Handle menu item click here
}

// Create and initialize your VTray instance
struct VTray *vtray_init_mac(VTrayParamsMac *params, size_t num_items, MenuItemMac *items[]) {
    struct VTray *tray = (struct VTray *)malloc(sizeof(struct VTray));
    if (!tray) {
        // Handle allocation failure
        return NULL;
    }

    // Initialize the NSApplication
    [NSApplication sharedApplication];

    // Create a status item in the system menu bar
    tray->statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    tray->statusItem.toolTip = [NSString stringWithUTF8String:params->tooltip];
    tray->statusItem.button.image = [NSImage imageNamed:[NSString stringWithUTF8String:params->icon]];
    // Create a menu
    tray->menu = [[NSMenu alloc] initWithTitle:params->tooltip]; // Replace "YourMenuTitle" with your desired menu title

    tray->statusItem.menu = tray->menu;

    // Set the callback for menu item clicks
    [NSApp setDelegate:(id<NSApplicationDelegate>)tray];
    [NSApp run];

    return tray;
}


void vtray_update_mac(struct VTray *tray) {
    // Update the system tray icon and menu as needed.
    [tray->statusItem setImage:[NSImage imageNamed:@"YourNewIcon.png"]]; // Replace "YourNewIcon.png" with the new icon's filename
    // You can update the menu here if needed.
}

void vtray_construct(MenuItemMac *items[], size_t num_items, struct VTray *parent) {
    if (parent->menu) {
        for (size_t i = 0; i < num_items; i++) {
            MenuItemMac item = items[i];
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithUTF8String:item.text] action:@selector(vtray_on_click:) keyEquivalent:@""];
            menuItem.tag = item.id;
            [menuItem setTarget:nil];
            [parent->menu addItem:menuItem];
        }
    }
    // Attach the menu to the status item
    [parent->statusItem setMenu:parent->menu];
}

void vtray_run_mac(struct VTray *tray) {
    // Show and run your macOS application loop here.
    // You may not need to do anything here since the menu bar app runs its own loop.
}


// Clean up and exit the application
void vtray_exit_mac(struct VTray *tray) {
    // Release resources, dealloc, and exit
    if (tray) {
        [NSStatusBar.systemStatusBar removeStatusItem:tray->statusItem];
        free(tray);
        [NSApp terminate:nil];
    }
}
#endif
