# VTray

VTray is a cross-platform V library to place an icon and menu in the notification area.

## Features

- [x] Create a tray
- [x] Add an on click event listener
- [x] Supported on Windows
- [ ] Supported on Linux
- [ ] Supported on MacOS
- [ ] Menu items can be checked and/or disabled
- [ ] Allow menus to have their own icons

## Example

```v
module main

import vtray

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
					text: 'Edit'
				},
				&vtray.VTrayMenuItem{
					id: int(MenuItems.quit)
					text: 'Quit'
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
```

![image1.png](assets%2Fimage1.png)

![image2.png](assets%2Fimage2.png)

![image3.png](assets%2Fimage3.png)