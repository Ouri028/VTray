module main

import vtray

fn main() {
	v := vtray.vtray_init('Vtray!','${@VMODROOT}/assets/icon.ico')
	v.run()
	v.destroy()
}
