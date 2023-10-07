module main

import ouri028.vtray

fn main() {
	icon := $if macos {
		'${@VMODROOT}/assets/icon.png'
	} $else {
		'${@VMODROOT}/assets/icon.ico'
	}
	mut tray := vtray.create(icon, tooltip: 'VTray Demo!')
	tray.add_item('Edit', checkable: true)
	tray.add_item('Copy', disabled: true)
	tray.add_item('Quit', on_click: tray.destroy)
	tray.run()
	tray.destroy()
}
