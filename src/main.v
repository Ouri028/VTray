module main

import vtray

fn main() {
	v := vtray.vtray_init('Vtray!', '${@VMODROOT}/assets/icon.ico', 'Vtray Demo!')
	v.run()
	v.destroy()
}
