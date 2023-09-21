module main

import vtray

fn main() {
	mut v := vtray.VTrayApp{
		identifier: 'VTray!'
		tooltip: 'VTray Demo!'
		icon: '${@VMODROOT}/assets/icon.ico'
		items: [
			vtray.VTrayMenuItem{
				id: 1
				text: &char('item 1'.str)
				disabled: false
				toggled: false
				image: &char('${@VMODROOT}/assets/icon.ico'.str)
			},
		]
	}
	v.vtray_init()
	v.run()
	v.destroy()
}
