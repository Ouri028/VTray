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
	callbacks  map[int]ItemCallback
	last_id    int = 1
}

pub struct MenuItem {
pub:
	id        int
	text      string
	checked   bool
	checkable bool
	disabled  bool
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
	on_click  ?ItemCallback
}

type ItemCallback = fn () | fn (menu_item &MenuItem)

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

// set_icon sets the tray icon.
pub fn (t &Tray) set_icon(icon string) {
	C.vtray_set_icon(icon.str, t.instance)
}

// set_tooltip sets the tray tooltip.
pub fn (t &Tray) set_tooltip(tooltip string) {
	C.vtray_set_tooltip(tooltip.str, t.instance)
}

// get_item returns the menu item with the given text.
pub fn (t &Tray) get_item(item string) ?&MenuItem {
	return t.items.filter(it.text == item)[0] or { return none }
}

// run runs the tray app.
pub fn (mut t Tray) run() {
	t.instance = C.vtray_init(&VTrayParams{
		identifier: t.identifier
		tooltip: t.tooltip
		icon: t.icon
		on_click: fn [t] (menu_item &MenuItem) {
			cb := t.callbacks[menu_item.id] or { return }
			match cb {
				fn (menu_item &MenuItem) {
					cb(menu_item)
				}
				fn () {
					cb()
				}
			}
		}
	}, usize(t.items.len), t.items.data)
	C.vtray_run(t.instance)
}

// destroy destroys the tray app and frees allocated memory.
pub fn (t &Tray) destroy() {
	C.vtray_exit(t.instance)
}
