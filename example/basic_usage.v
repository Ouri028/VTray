module main

import vtray

enum MenuItems {
	edit = 1
	quit = 2
}

fn main() {
	mut systray := &vtray.VTrayApp{
		identifier: 'VTray!'
		tooltip: 'VTray Demo!'
		icon: $if macos {
			'${@VMODROOT}/assets/icon.png'
		} $else {
			'${@VMODROOT}/assets/icon.ico'
		}
		items: [
			&vtray.VTrayMenuItem{
				id: int(MenuItems.edit)
				text: 'Edit'
			},
			&vtray.VTrayMenuItem{
				id: int(MenuItems.quit)
				text: 'Quit'
			},
		]
	}
	on_click := fn [systray] (menu_id int) {
		match menu_id {
			int(MenuItems.edit) {
				println('EDIT!')
			}
			int(MenuItems.quit) {
				systray.destroy()
			}
			else {}
		}
	}
	systray.on_click = on_click
	systray.vtray_init()
	systray.run()
	systray.destroy()
}
