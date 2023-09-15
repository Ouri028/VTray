module vtray

import builtin.wchar

pub fn vtray_init(tray_name string, icon_path string, tooltip string) &Vtray {
	$if windows {
		return C.vtray_init_windows(&char(tray_name.str), &char(icon_path.str), wchar.from_string(tooltip))
	} $else $if linux {
		return C.vtray_init_linux(&char(tray_name.str), &char(icon_path.str), &char(tooltip.str))
	}
	panic('Unsupported platform')
}

pub fn (v &Vtray) run() {
	$if windows {
		C.vtray_run_windows(v)
	} $else $if linux {
		C.vtray_run_linux(v)
	}
	panic('Unsupported platform')
}

pub fn (v &Vtray) destroy() {
	$if windows {
		C.vtray_exit_windows(v)
	} $else $if linux {
		C.vtray_exit_linux(v)
	}
	panic('Unsupported platform')
}
