#include <Cocoa/Cocoa.h> // Uncomment for C/C++ intellisense

// See this tutorial to learn about NSApplicationDelegate:
// https://bumbershootsoft.wordpress.com/2018/11/22/unfiltered-cocoa-completing-the-application/

static NSString *nsstring(string s) {
  return [[NSString alloc] initWithBytesNoCopy:s.str
                                        length:s.len
                                      encoding:NSUTF8StringEncoding
                                  freeWhenDone:NO];
}

// Manages the app lifecycle.
@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSAutoreleasePool *pool;
  NSApplication *app;
  NSStatusItem *statusItem;    // our button
  main__VTrayParams trayParams; // TrayParams is defined in tray.v
}
@end

@implementation AppDelegate
- (AppDelegate *)initWithParams:(main__VTrayParams)params {
  if (self = [super init]) {
    trayParams = params;
  }
  return self;
}

// Called when NSMenuItem is clicked.
- (void)onAction:(id)sender {
  struct main__VTrayMenuItem *item =
      (struct main__VTrayMenuItem *)[[sender representedObject] pointerValue];
  if (item) {
    trayParams.on_click(*item);
  }
}

- (NSMenu *)buildMenu {
  NSMenu *menu = [NSMenu new];
  [menu autorelease];
  [menu setAutoenablesItems:NO];

  main__VTrayMenuItem *params_items = trayParams.items.data;
  for (int i = 0; i < trayParams.items.len; i++) {
    NSString *title = nsstring(params_items[i].text);
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
struct main__VTrayParams *params =
      (struct main__VTrayParams *)
  // Height must be 22px.
  // Need to come back to this since we probably need to construct
  // the image first, to be honest don't know much of Objective-C XD
  NSString* icon = [NSString stringWithFormat:@"%c" , params->icon];
  NSImage *img = [NSImage imageNamed: icon];
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
main__VTray *vtray_init_macos(main__VTrayParams params) {
  NSApplication *app = [NSApplication sharedApplication];
  AppDelegate *appDelegate = [[AppDelegate alloc] initWithParams:params];

  // Hide icon from the doc.
  [app setActivationPolicy:NSApplicationActivationPolicyProhibited];
  [app setDelegate:appDelegate];

  [appDelegate initTrayMenuItem];

  main__VTray *vtray = malloc(sizeof(main__VTray));
  vtray->ptr = app;
  vtray->ptr_delegate = appDelegate;
  return vtray;
}

// Blocks and runs the application.
void vtray_run_macos(main__VTray *vtray) {
  NSApplication *app = (NSApplication *)(vtray->ptr);
  [app run];
}

// Processes a single NSEvent while blocking the thread
// until there is an event.
void vtray_update_macos(main__VTray *vtray) {
  NSDate *until = [NSDate distantFuture];

  NSApplication *app = (NSApplication *)(vtray->app);
  NSEvent *event = [app nextEventMatchingMask:ULONG_MAX
                                    untilDate:until
                                       inMode:@"kCFRunLoopDefaultMode"
                                      dequeue:YES];

  if (event) {
    [app sendEvent:event];
  }
}

// Terminates the app.
void vtray_tray_exit_macos(main__VTray *vtray) {
  NSApplication *app = (NSApplication *)(vtray->app);
  [app terminate:app];
}
