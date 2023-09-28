module vtray

import builtin.wchar

// Create a V struct that is easier to use for the end user.
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

pub struct VTrayMenuItem {
pub mut:
	id   int
	text string
	// TODO: Add menu item icons.
	// image    &char
}

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

pub fn (v &VTrayApp) run() {
	$if windows {
		C.vtray_run_windows(v.tray)
	} $else $if linux {
		C.vtray_run_linux(v.tray)
	} $else {
		panic('Unsupported platform')
	}
}

pub fn (v &VTrayApp) destroy() {
	$if windows {
		C.vtray_exit_windows(v.tray)
	} $else $if linux {
		C.vtray_exit_linux(v.tray)
	} $else {
		panic('Unsupported platform')
	}
}
