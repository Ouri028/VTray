module vtray

import builtin.wchar

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
	on_click   fn (menu_id int) = unsafe { nil }
}

// VTrayMenuItem is a menu item that can be added to the tray.
pub struct VTrayMenuItem {
pub mut:
	id   int
	text string
	// TODO: Add menu item icons.
	// image    &char
}

// vtray_init Init VTray and convert the VTrayApp struct to the C struct based on the platform.
pub fn (mut v VTrayApp) vtray_init() {
	$if windows {
		mut items := []&MenuItemWindows{}
		for item in v.items {
			convert := &MenuItemWindows{
				id: item.id
				text: wchar.from_string(item.text)
			}
			items << convert
		}
		tray := C.vtray_init_windows(&VTrayParamsWindows{
			identifier: v.identifier.str
			tooltip: wchar.from_string(v.tooltip)
			icon: v.icon.str
			on_click: v.on_click
		}, usize(items.len), items.data)
		v.tray = tray
	} $else $if linux {
		mut items := []&MenuItemLinux{}
		for item in v.items {
			convert := &MenuItemLinux{
				id: item.id
				text: item.text.str
			}
			items << convert
		}
		tray := C.vtray_init_linux(&VTrayParamsLinux{
			identifier: v.identifier.str
			tooltip: v.tooltip.str
			icon: v.icon.str
			on_click: v.on_click
		}, usize(items.len), items.data)
		v.tray = tray
	} $else $if macos {
		mut items := []&MenuItemMac{}
		for item in v.items {
			convert := &MenuItemMac{
				id: item.id
				text: item.text.str
			}
			items << convert
		}
		tray := C.vtray_init_mac(&VTrayParamsMac{
			identifier: v.identifier.str
			tooltip: v.tooltip.str
			icon: v.icon.str
			on_click: v.on_click
		}, usize(items.len), items.data)
		v.tray = tray
	} $else {
		panic('Unsupported platform')
	}
}

// run Run the tray app.
pub fn (v &VTrayApp) run() {
	$if windows {
		C.vtray_run_windows(v.tray)
	} $else $if linux {
		C.vtray_run_linux(v.tray)
	} $else $if macos {
		C.vtray_run_mac(v.tray)
	} $else {
		panic('Unsupported platform')
	}
}

// destroy Destroy the tray app and free the memory.
pub fn (v &VTrayApp) destroy() {
	$if windows {
		C.vtray_exit_windows(v.tray)
	} $else $if linux {
		C.vtray_exit_linux(v.tray)
	} $else $if macos {
		C.vtray_exit_mac(v.tray)
	} $else {
		panic('Unsupported platform')
	}
}
