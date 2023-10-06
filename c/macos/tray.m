#ifdef __APPLE__

/**
 * This code was based off of https://github.com/vlang/v/blob/master/examples/macos_tray/tray.m
 * All credit goes to the legend who created this.
 */

static char *string_to_char(string str)
{
    if (str.str == NULL)
    {
        perror("string_to_char: string is NULL");
        return NULL;
    }
    return str.str;
}

static size_t len(string str)
{
    return str.len;
}

static char *char_to_nsstring(char *str)
{
    if (str == NULL)
    {
        perror("char_to_nsstring: string is NULL");
        return NULL;
    }
    return [NSString stringWithUTF8String:str];
}

static NSString *string_to_nsstring(string str)
{
    if (str.str == NULL)
    {
        perror("string_to_nsstring: string is NULL");
        return NULL;
    }
    return [NSString stringWithUTF8String:str.str];
}

// Manages the app lifecycle.
@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSAutoreleasePool *pool;
  NSApplication *app;
  NSStatusItem *statusItem;    // our button
  int num_items;
  vtray__VTrayParams *trayParams; // VTrayParams is defined in tray.v
  vtray__VTrayMenuItem **menuItems;
}
@end

@implementation AppDelegate
- (AppDelegate *)initWithParams:(vtray__VTrayParams *)params
                        itemsArray:(vtray__VTrayMenuItem *[])itemsArray
                    numItems:(int)numItems {
  if (self = [super init]) {
    trayParams = params;
    num_items = numItems;
    menuItems = itemsArray;


  }
  return self;
}


// Called when NSMenuItem is clicked.
- (void)onAction:(id)sender {
  struct vtray__VTrayMenuItem *item =
      (struct vtray__VTrayMenuItem *)[[sender representedObject] pointerValue];
  if (item) {
    trayParams->on_click(item);
  }
}

- (NSMenu *)buildMenu {
  NSLog(@"Building menu");
  NSMenu *menu = [NSMenu new];
  [menu autorelease];
  [menu setAutoenablesItems:NO];

  for (int i = 0; i < num_items; i++) {
    NSString *title = string_to_nsstring(menuItems[i]->text);
    NSMenuItem *item = [menu addItemWithTitle:title
                                       action:@selector(onAction:)
                                keyEquivalent:@""];
    NSValue *representedObject = [NSValue valueWithPointer:(menuItems[i])];
    if(menuItems[i]->disabled) {
        [item setEnabled:NO];
    } else {
        [item setEnabled:YES];
    }

    if(menuItems[i]->checkable) {
        [item setTarget:self];
        NSLog(@"%d", menuItems[i]->checked);
        if(menuItems[i]->checked) {
            [item setState: NSOnState];
        }
    }
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
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:string_to_nsstring(trayParams->icon)];
  if (img == nil) {
    NSLog(@"Error loading image: %@", string_to_nsstring(trayParams->icon));
    // Check the image path and file as well as other potential issues.
    } else {
        [statusBarButton setImage:img];
        NSMenu *menu = [self buildMenu];
        [statusItem setMenu:menu];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:
    (NSApplication *)sender {
  return NSTerminateNow;
}

@end

// Initializes NSApplication and NSStatusItem, aka system tray menu item.
vtray__VTray *vtray_init(vtray__VTrayParams *params, int numItems, vtray__VTrayMenuItem *itemsArray[]) {
  NSApplication *app = [NSApplication sharedApplication];
  AppDelegate *appDelegate = [[AppDelegate alloc] initWithParams:params itemsArray:itemsArray numItems:numItems];

  [app setActivationPolicy:NSApplicationActivationPolicyRegular];

  [app setDelegate:appDelegate];

  [appDelegate initTrayMenuItem];

  vtray__VTray *tray = malloc(sizeof(vtray__VTray));
  tray->ptr = app;
  tray->ptr_delegate = appDelegate;
  return tray;
}

// Blocks and runs the application.
void vtray_run(vtray__VTray *tray) {
  NSApplication *app = (NSApplication *)(tray->ptr);
  [app run];
}

// Terminates the app.
void vtray_exit(vtray__VTray *tray) {
  NSApplication *app = (NSApplication *)(tray->ptr);
  [app terminate:app];
}

#endif
