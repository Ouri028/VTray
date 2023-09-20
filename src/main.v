module main

import vtray

fn main() {
	mut v := vtray.VTrayApp{
		identifier: 'VTray!'
		tooltip: 'VTray Demo!'
		icon: '${@VMODROOT}/assets/icon.ico'
		items: []
	}
	v.vtray_init()
	v.run()
	v.destroy()
}
