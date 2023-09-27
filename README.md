# VTray

VTray is a cross-platform V library to place an icon and menu in the notification area.

## Features

- [x] Create a tray
- [x] Add an on click event listener
- [x] Supported on Windows
- [x] Supported on Linux
- [ ] Supported on MacOS
- [ ] Menu items can be checked and/or disabled
- [ ] Allow menus to have their own icons

## Requirements

For Linux you will need the following packages installed:

```bash
sudo apt-get install libayatana-appindicator3-dev
sudo apt-get install libgtk-3-dev
sudo apt-get install pkg-config
```

## Example

```v
module main

import ouri028.vtray

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

Edit v.mod

```v
Module {
	name: 'myapp'
	description: ''
	version: '0.0.1'
	license: 'MIT'
	dependencies: ['ouri028.vtray']
}
```

![image1.png](assets%2Fimage1.png)

![image2.png](assets%2Fimage2.png)

![image3.png](assets%2Fimage3.png)
