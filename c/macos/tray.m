#ifdef __APPLE__

static NSString *nsstring(char* c_string) {
  return [NSString stringWithUTF8String:c_string];
}

// Manages the app lifecycle.
@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSAutoreleasePool *pool;
  NSApplication *app;
  NSStatusItem *statusItem;    // our button
  int num_items;
  vtray__VTrayParamsMac *trayParams; // VTrayParamsMac is defined in tray.v
  vtray__MenuItemMac *items[];
}
@end

@implementation AppDelegate
- (AppDelegate *)initWithParams:(vtray__VTrayParamsMac *)params
                        items:(vtray__MenuItemMac *)itemsArray
                    numItems:(int)numItems {
  if (self = [super init]) {
    trayParams = params;

//    memcpy(items, itemsArray, numItems * sizeof(vtray__MenuItemMac));
    num_items = numItems;
  }
  return self;
}


// Called when NSMenuItem is clicked.
- (void)onAction:(id)sender {
  struct vtray__MenuItemMac *item =
      (struct vtray__MenuItemMac *)[[sender representedObject] pointerValue];
  if (item) {
    trayParams->on_click(item->id);
  }
}

- (NSMenu *)buildMenu {
  NSMenu *menu = [NSMenu new];
  [menu autorelease];
  [menu setAutoenablesItems:NO];

  for (int i = 0; i < num_items; i++) {
    NSString *title = nsstring(items[i]->text);
    NSMenuItem *item = [menu addItemWithTitle:title
                                       action:@selector(onAction:)
                                keyEquivalent:@""];
    NSValue *representedObject = [NSValue valueWithPointer:(items + i)];
    [item setRepresentedObject:representedObject];
    [item setTarget:self];
    [item autorelease];
    [item setEnabled:YES];
  }

  return menu;
}

- (void)initTrayMenuItem {
  NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
  statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
  [statusItem retain];
  [statusItem setVisible:YES];
  NSStatusBarButton *statusBarButton = [statusItem button];

  // Height must be 22px.
  NSImage *img = [NSImage imageNamed:trayParams->icon];
  [statusBarButton setImage:img];
  NSMenu *menu = [self buildMenu];
  [statusItem setMenu:menu];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
  NSLog(@"applicationWillFinishLaunching called");
}

- (void)applicationWillTerminate:(NSNotification *)notif;
{ NSLog(@"applicationWillTerminate called"); }

- (NSApplicationTerminateReply)applicationShouldTerminate:
    (NSApplication *)sender {
  NSLog(@"applicationShouldTerminate called");
  return NSTerminateNow;
}
@end

// Initializes NSApplication and NSStatusItem, aka system tray menu item.
vtray__VTray *vtray_init_mac(vtray__VTrayParamsMac *params, int numItems, vtray__MenuItemMac *itemsArray[]) {
  NSApplication *app = [NSApplication sharedApplication];
  AppDelegate *appDelegate = [[AppDelegate alloc] initWithParams:params items:itemsArray numItems:numItems];

  // Hide icon from the doc.
  [app setActivationPolicy:NSApplicationActivationPolicyProhibited];
  [app setDelegate:appDelegate];

  [appDelegate initTrayMenuItem];

  vtray__VTray *tray = malloc(sizeof(vtray__VTray));
  tray->ptr = app;
  tray->ptr_delegate = appDelegate;
  return tray;
}

// Blocks and runs the application.
void vtray_run_mac(vtray__VTray *tray) {
  NSApplication *app = (NSApplication *)(tray->ptr);
  [app run];
}

// Terminates the app.
void vtray_exit_windows(vtray__VTray *tray) {
  NSApplication *app = (NSApplication *)(tray->ptr);
  [app terminate:app];
}
#endif
