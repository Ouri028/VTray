module vtray

// Tray is the main struct that represents the tray app.
[heap; noinit]
pub struct Tray {
mut:
	instance   &VTray = unsafe { nil }
	icon       string
	identifier string
	tooltip    string
	items      []&MenuItem
	callbacks  map[int]fn ()
	last_id    int = 1
}

[params]
pub struct CreatOptions {
	identifier string = 'VTray'
	tooltip    string
}

// MenuItem is a menu item that can be added to the tray.
[params]
pub struct MenuItemOptions {
	checked   bool
	checkable bool
	disabled  bool
	on_click  ?fn ()
}

// create creates the tray.
// On macOS, the tray icon size must be 22x22 pixels to be rendered correctly.
pub fn create(icon_path string, opts CreatOptions) &Tray {
	return &Tray{
		icon: icon_path
		identifier: opts.identifier
		tooltip: opts.tooltip
	}
}

// add_item adds an item to the tray.
pub fn (mut t Tray) add_item(text string, opts MenuItemOptions) {
	id := t.last_id++
	t.items << &MenuItem{
		id: id
		text: text
		checked: opts.checked
		checkable: opts.checkable
		disabled: opts.disabled
	}
	if cb := opts.on_click {
		t.callbacks[id] = cb
	}
}

// run runs the tray app.
pub fn (mut t Tray) run() {
	t.instance = C.vtray_init(&VTrayParams{
		identifier: t.identifier
		tooltip: t.tooltip
		icon: t.icon
		on_click: fn [t] (menu_item &MenuItem) {
			if cb := t.callbacks[menu_item.id] {
				cb()
			}
		}
	}, usize(t.items.len), t.items.data)
	C.vtray_run(t.instance)
}

// destroy destroys the tray app and frees allocated memory.
pub fn (t &Tray) destroy() {
	C.vtray_exit(t.instance)
}
