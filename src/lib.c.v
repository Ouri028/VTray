module vtray

import builtin.wchar

$if windows {
	#flag -I @VMODROOT/c/vtray.h
	#flag @VMODROOT/c/windows/tray.c
	#include "@VMODROOT/c/windows/tray.h"
} $else $if linux {
	#flag -I @VMODROOT/c/vtray.h
	#flag -I /usr/include/libappindicator3-0.1/libappindicator
	#flag @VMODROOT/c/linux/tray.c
	#include "@VMODROOT/c/linux/tray.h"
} $else $if macos {
	#include <Cocoa/Cocoa.h>
	#flag -framework Cocoa

	#include "@VMODROOT/c/macos/tray.m"
}

$if linux {
	#pkgconfig gtk+-3.0
}

struct VTray {
	// Pointer to VTray instance;
	ptr voidptr
	// Pointer to delegate the App (only for MacOS)
	ptr_delegate voidptr
}

// we need to use primitive types for C
pub struct VTrayMenuItem {
pub mut:
	id       int
	text     &char
	disabled bool
	toggled  bool
	image    &char
}

// Parameters to configure the tray button.
struct VTrayParams {
	identifier &char
	tooltip    &wchar.Character
	icon       &char
	items      []VTrayMenuItem
	on_click   fn (item VTrayMenuItem) = unsafe { nil }
}

fn C.vtray_init_windows(params &VTrayParams) &VTray
fn C.vtray_run_windows(tray &VTray)
fn C.vtray_exit_windows(tray &VTray)

// fn C.vtray_init_linux(identifier &char, icon &char, tooltip &char) &VTray
// fn C.vtray_run_linux(tray &VTray)
// fn C.vtray_exit_linux(tray &VTray)
