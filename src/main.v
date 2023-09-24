module main

import vtray
import builtin.wchar

fn main() {
	mut v := vtray.VTrayApp{
		identifier: 'VTray!'
		tooltip: 'VTray Demo!'
		icon: '${@VMODROOT}/assets/icon.ico'
		on_click: on_click
		items: [
			&vtray.VTrayMenuItem{
				id: 1
				text: wchar.from_string('item 1')
				disabled: false
				toggled: false
				image: '${@VMODROOT}/assets/icon.ico'.str
			},
			&vtray.VTrayMenuItem{
				id: 2
				text: wchar.from_string('item 2')
				disabled: false
				toggled: false
				image: '${@VMODROOT}/assets/icon.ico'.str
			},
			&vtray.VTrayMenuItem{
				id: 3
				text: wchar.from_string('item 3')
				disabled: false
				toggled: false
				image: '${@VMODROOT}/assets/icon.ico'.str
			},
		]
	}
	v.vtray_init()
	v.run()
	v.destroy()
}

fn on_click(menu_id int) {
	println('ITEM: ${item}')
}
