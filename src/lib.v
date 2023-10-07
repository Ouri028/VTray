module vtray

// Tray is the main struct that represents the tray app.
[noinit]
pub struct Tray {
mut:
	icon       string
	identifier string
	tooltip    string
	tray       &VTray = unsafe { nil }
	items      []&MenuItem
	callbacks  map[int]fn ()
}

[params]
pub struct CreatOptions {
	identifier string = 'VTray'
	tooltip    string
}

// MenuItem is a menu item that can be added to the tray.
pub struct MenuItem {
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
pub fn (mut v Tray) init() {
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
		on_click: fn [callbacks] (menu_item &MenuItem) {
			if cb := callbacks[menu_item.id] {
				cb()
			}
		}
	}, usize(v.items.len), v.items.data)
}

// create Create a Tray.
pub fn create(icon_path string, opts CreatOptions) &Tray {
	return &Tray{
		icon: icon_path
		identifier: opts.identifier
		tooltip: opts.tooltip
	}
}

pub fn (mut t Tray) add_item(item &MenuItem) {
	t.items << item
}

// run Run the tray app.
pub fn (v &Tray) run() {
	C.vtray_run(v.tray)
}

// destroy Destroy the tray app and free the memory.
pub fn (v &Tray) destroy() {
	C.vtray_exit(v.tray)
}
