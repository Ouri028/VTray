module main

import ouri028.vtray

fn main() {
	icon := $if macos {
		'${@VMODROOT}/assets/icon.png'
	} $else {
		'${@VMODROOT}/assets/icon.ico'
	}
	mut tray := vtray.create(icon, tooltip: 'VTray Demo!')
	tray.add_item(vtray.MenuItem{
		text: 'Edit'
		checkable: true
	})
	tray.add_item(vtray.MenuItem{
		text: 'Copy'
		disabled: true
	})
	tray.add_item(vtray.MenuItem{
		text: 'Quit'
		on_click: fn [tray] () {
			tray.destroy()
		}
	})
	tray.init()
	tray.run()
	tray.destroy()
}
