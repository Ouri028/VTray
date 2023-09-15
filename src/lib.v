module vtray


pub fn vtray_init(tray_name string, icon_path string) &Vtray {
	return C.vtray_init(&char(tray_name.str), &char(icon_path.str))
}

pub fn (v &Vtray) run() {
	C.vtray_run(v)
}

pub fn (v &Vtray) update() {
	C.vtray_update(v)
}

pub fn (v &Vtray) destroy() {
	C.vtray_exit(v)
}
