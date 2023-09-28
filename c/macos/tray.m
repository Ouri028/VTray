#ifdef __APPLE__

static NSString *nsstring(char* c_string {
  return [NSString stringWithUTF8String:c_string];
}

// Manages the app lifecycle.
@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSAutoreleasePool *pool;
  NSApplication *app;
  NSStatusItem *statusItem;    // our button
  main__VTrayParamsMac trayParams; // VTrayParamsMac is defined in tray.v
}
@end

@implementation AppDelegate
- (AppDelegate *)initWithParams:(main__VTrayParamsMac) params {
  if (self = [super init]) {
    trayParams = params;
  }
  return self;
}

// Called when NSMenuItem is clicked.
- (void)onAction:(id)sender {
  struct main__MenuItemMac *item =
      (struct main__MenuItemMac *)[[sender representedObject] pointerValue];
  if (item) {
    trayParams->on_click(*item->id);
  }
}

- (NSMenu *)buildMenu {
  NSMenu *menu = [NSMenu new];
  [menu autorelease];
  [menu setAutoenablesItems:NO];

  main__MenuItemMac *params_items = trayParams.items.data;
  for (int i = 0; i < trayParams.items.len; i++) {
    NSString *title = nsstring(params_items[i]->text);
    NSMenuItem *item = [menu addItemWithTitle:title
                                       action:@selector(onAction:)
                                keyEquivalent:@""];
    NSValue *representedObject = [NSValue valueWithPointer:(params_items + i)];
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
main__VTray *vtray_init_mac(main__VTrayParamsMac *params) {
  NSApplication *app = [NSApplication sharedApplication];
  AppDelegate *appDelegate = [[AppDelegate alloc] initWithParams:params];

  // Hide icon from the doc.
  [app setActivationPolicy:NSApplicationActivationPolicyProhibited];
  [app setDelegate:appDelegate];

  [appDelegate initTrayMenuItem];

  main__VTray *tray = malloc(sizeof(main__VTray));
  tray->ptr = app;
  tray->ptr_delegate = appDelegate;
  return tray;
}

// Blocks and runs the application.
void vtray_run_mac(main__VTray *tray) {
  NSApplication *app = (NSApplication *)(tray->ptr);
  [app run];
}

// Terminates the app.
void vtray_exit_windows(main__VTray *tray) {
  NSApplication *app = (NSApplication *)(tray->ptr);
  [app terminate:app];
}
#endif
