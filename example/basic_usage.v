module main

import ouri028.vtray

enum MenuItems {
	edit = 1
	copy = 2
	quit = 3
}

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
		items: [
			&vtray.VTrayMenuItem{
				id: int(MenuItems.edit)
				text: 'Edit'
				checkable: true
			},
			&vtray.VTrayMenuItem{
				id: int(MenuItems.copy)
				text: 'Copy'
				checkable: true
			},
			&vtray.VTrayMenuItem{
				id: int(MenuItems.quit)
				text: 'Quit'
			},
		]
	}
	on_click := fn [systray] (mut menu_item vtray.VTrayMenuItem) {
		println(menu_item)
		if menu_item.id == int(MenuItems.quit) {
			systray.destroy()
		}
	}
	systray.on_click = on_click
	systray.vtray_init()
	systray.run()
	systray.destroy()
}
