module vtray

$if windows {
	#flag -I @VMODROOT/c/windows/utils.h
	#flag -I @VMODROOT/c/vtray.h
	#flag @VMODROOT/c/windows/utils.c
	#flag @VMODROOT/c/windows/tray.c
	#include "@VMODROOT/c/windows/tray.h"
} $else $if linux {
	#flag -I @VMODROOT/c/linux/utils.h
	#flag -I @VMODROOT/c/vtray.h
	#flag @VMODROOT/c/linux/utils.c
	#flag @VMODROOT/c/linux/tray.c
	#include "@VMODROOT/c/linux/tray.h"
} $else $if macos {
	#include <Cocoa/Cocoa.h>
	#flag -framework Cocoa
	#include "@VMODROOT/c/macos/tray.m"
}

$if linux {
	#pkgconfig gtk+-3.0
	#pkgconfig --cflags --libs ayatana-appindicator3-0.1
}

struct VTray {
	// Pointer to VTray instance;
	ptr voidptr
	// Pointer to delegate the App (only for MacOS)
	ptr_delegate voidptr
}

// Parameters to configure the tray button.
struct VTrayParams {
	identifier string
	tooltip    string
	icon       string
	on_click   fn (menu_item &MenuItem) = unsafe { nil }
}

[heap]
struct MenuItem {
pub:
	id        int
	text      string
	checked   bool
	checkable bool
	disabled  bool
}

fn C.vtray_init(params &VTrayParams, num_items usize, items []&MenuItem) &VTray
fn C.vtray_run(tray &VTray)
fn C.vtray_exit(tray &VTray)
fn C.vtray_set_icon(icon &char, tray &VTray)
fn C.vtray_set_tooltip(tooltip &char, tray &VTray)
