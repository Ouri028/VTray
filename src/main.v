module main

import vtray
import builtin.wchar

enum MenuItems {
	edit = 1
	quit = 2
}

struct App {
pub mut:
	tray vtray.VTrayApp
}

fn main() {
	mut app := App{
		tray: vtray.VTrayApp{
			identifier: 'VTray!'
			tooltip: 'VTray Demo!'
			icon: '${@VMODROOT}/assets/icon.ico'
			items: [
				&vtray.VTrayMenuItem{
					id: int(MenuItems.edit)
					text: wchar.from_string('Edit')
					disabled: false
					toggled: false
					image: '${@VMODROOT}/assets/1.bmp'.str
				},
				&vtray.VTrayMenuItem{
					id: int(MenuItems.quit)
					text: wchar.from_string('Quit')
					disabled: false
					toggled: false
					image: '${@VMODROOT}/assets/1.bmp'.str
				},
			]
		}
	}
	app.tray.on_click = app.on_click
	app.tray.vtray_init()
	app.tray.run()
	app.tray.destroy()
}

fn (app &App) on_click(menu_id int) {
	match menu_id {
		int(MenuItems.edit) {
			println('EDIT!')
		}
		int(MenuItems.quit) {
			app.tray.destroy()
		}
		else {}
	}
}
