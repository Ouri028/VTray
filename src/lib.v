module vtray

// VTrayApp is the main struct that represents the tray app.
[heap]
pub struct VTrayApp {
mut:
	tray &VTray = unsafe { nil }
pub mut:
	identifier string
	tooltip    string
	icon       string
	items      []&VTrayMenuItem
	on_click   fn (menu_item &VTrayMenuItem) = unsafe { nil }
}

// VTrayMenuItem is a menu item that can be added to the tray.
pub struct VTrayMenuItem {
pub mut:
	id        int
	text      string
	checked   bool
	disabled  bool
	checkable bool
}

// For MacOS the tray icon size must be 22x22 pixels in order for it to render correctly.
pub fn (mut v VTrayApp) vtray_init() {
	tray := C.vtray_init(&VTrayParams{
		identifier: v.identifier
		tooltip: v.tooltip
		icon: v.icon
		on_click: v.on_click
	}, usize(v.items.len), v.items.data)
	v.tray = tray
}

// run Run the tray app.
pub fn (v &VTrayApp) run() {
	C.vtray_run(v.tray)
}

// destroy Destroy the tray app and free the memory.
pub fn (v &VTrayApp) destroy() {
	C.vtray_exit(v.tray)
}
