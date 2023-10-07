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
}

// VTrayMenuItem is a menu item that can be added to the tray.
pub struct VTrayMenuItem {
mut:
	id int
pub mut:
	text      string
	checked   bool
	checkable bool
	disabled  bool
	on_click  ?fn ()
}

// For MacOS the tray icon size must be 22x22 pixels in order for it to render correctly.
pub fn (mut v VTrayApp) vtray_init() {
	mut callbacks := map[int]fn (){}
	mut id := 1
	for mut item in v.items {
		item.id = id
		if cb := item.on_click {
			callbacks[id] = cb
		}
		id++
	}
	v.tray = C.vtray_init(&VTrayParams{
		identifier: v.identifier
		tooltip: v.tooltip
		icon: v.icon
		on_click: fn [callbacks] (menu_item &VTrayMenuItem) {
			if cb := callbacks[menu_item.id] {
				cb()
			}
		}
	}, usize(v.items.len), v.items.data)
}

// run Run the tray app.
pub fn (v &VTrayApp) run() {
	C.vtray_run(v.tray)
}

// destroy Destroy the tray app and free the memory.
pub fn (v &VTrayApp) destroy() {
	C.vtray_exit(v.tray)
}
