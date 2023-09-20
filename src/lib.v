module vtray

import builtin.wchar

// Create a V struct that is easier to use for the end user.
[heap]
pub struct VTrayApp {
mut:
	tray     &VTray = unsafe { nil }
	on_click fn (item VTrayMenuItem) = unsafe { nil }
pub mut:
	identifier string
	tooltip    string
	icon       string
	items      []VTrayMenuItem
}

pub fn (mut v VTrayApp) vtray_init() {
	$if windows {
		params := &VTrayParams{
			identifier: &char(v.identifier.str)
			tooltip: wchar.from_string(v.tooltip)
			icon: &char(v.icon.str)
			items: v.items
			on_click: v.on_menu_item_click
		}
		tray := C.vtray_init_windows(params)
		v.tray = tray
	}
	// } $else $if linux {
	// 	C.vtray_init_linux(&char(tray_name.str), &char(icon_path.str), &char(tooltip.str))
	// }
	// panic('Unsupported platform')
}

pub fn (v &VTrayApp) run() {
	$if windows {
		C.vtray_run_windows(v.tray)
	}
	// $else $if linux {
	// 	C.vtray_run_linux(v)
	// }
	panic('Unsupported platform')
}

// Override function
pub fn (v &VTrayApp) on_menu_item_click(item VTrayMenuItem) {
	println(item.text)
}

pub fn (v &VTrayApp) destroy() {
	$if windows {
		C.vtray_exit_windows(v.tray)
	}
	// $else $if linux {
	// 	C.vtray_exit_linux(v)
	// }
	panic('Unsupported platform')
}
