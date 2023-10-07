module main

import ouri028.vtray

fn main() {
	icon := $if macos {
		'${@VMODROOT}/assets/icon.png'
	} $else {
		'${@VMODROOT}/assets/icon.ico'
	}
	mut tray := vtray.create(icon, tooltip: 'VTray Demo!')
	tray.add_item('Edit',
		checkable: true
		on_click: fn [tray] () {
			if x := tray.get_item('Edit') {
				if x.checked {
					tray.set_icon('${@VMODROOT}/assets/test.ico')
				} else {
					tray.set_icon('${@VMODROOT}/assets/icon.ico')
				}
			}
		}
	)
	tray.add_item('Copy',
		on_click: fn [tray] () {
			tray.set_tooltip('Copied!')
		}
	)
	tray.add_item('Quit', on_click: tray.destroy)
	tray.run()
	tray.destroy()
}
