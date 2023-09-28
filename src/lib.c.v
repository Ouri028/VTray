module vtray

import builtin.wchar

$if windows {
	#flag -I @VMODROOT/c/vtray.h
	#flag @VMODROOT/c/windows/tray.c
	#include "@VMODROOT/c/windows/tray.h"
} $else $if linux {
	#flag -I @VMODROOT/c/vtray.h
	#flag @VMODROOT/c/linux/tray.c
	#include "@VMODROOT/c/linux/tray.h"
} $else $if macos {
	#flag @VMODROOT/c/macos/tray.m
	#flag -framework Cocoa
	#include "@VMODROOT/c/macos/tray.h"
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

// we need to use primitive types for C
pub struct MenuItemWindows {
pub mut:
	id   int
	text &wchar.Character
	// TODO: Add menu item icons.
	// image    &char
}

pub struct MenuItemLinux {
pub mut:
	id   int
	text &char
	// TODO: Add menu item icons.
	// image    &char
}

pub struct MenuItemMac {
pub mut:
	id   int
	text &char
	// TODO: Add menu item icons.
	// image    &char
}

// Parameters to configure the tray button.
struct VTrayParamsWindows {
	identifier &char
	tooltip    &wchar.Character
	icon       &char
	on_click   fn (menu_id int) = unsafe { nil }
}

struct VTrayParamsLinux {
	identifier &char
	tooltip    &char
	icon       &char
	on_click   fn (menu_id int) = unsafe { nil }
}

struct VTrayParamsMac {
	identifier &char
	tooltip    &char
	icon       &char
	on_click   fn (menu_id int) = unsafe { nil }
}

// Windows
fn C.vtray_init_windows(params &VTrayParamsWindows, num_items usize, items []&MenuItemWindows) &VTray
fn C.vtray_run_windows(tray &VTray)
fn C.vtray_exit_windows(tray &VTray)

// Linux
fn C.vtray_init_linux(params &VTrayParamsLinux, num_items usize, items []&MenuItemLinux) &VTray
fn C.vtray_run_linux(tray &VTray)
fn C.vtray_exit_linux(tray &VTray)

// MacOS
fn C.vtray_init_mac(params &VTrayParamsMac, num_items usize, items []&MenuItemMac) &VTray
fn C.vtray_run_mac(tray &VTray)
fn C.vtray_exit_mac(tray &VTray)
