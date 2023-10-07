module main

import ouri028.vtray

fn main() {
	icon := $if macos {
		'${@VMODROOT}/assets/icon.png'
	} $else {
		'${@VMODROOT}/assets/icon.ico'
	}
	mut systray := &vtray.VTrayApp{
		identifier: 'VTray!'
		tooltip: 'VTray Demo!'
		icon: icon
	}
	systray.items = [
		&vtray.VTrayMenuItem{
			text: 'Edit'
			checkable: true
		},
		&vtray.VTrayMenuItem{
			text: 'Copy'
			disabled: true
		},
		&vtray.VTrayMenuItem{
			text: 'Quit'
			on_click: fn [systray] () {
				systray.destroy()
			}
		},
	]
	systray.vtray_init()
	systray.run()
	systray.destroy()
}
