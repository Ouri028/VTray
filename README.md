# VTray

VTray is a cross-platform V library to place an icon and menu in the notification area.

## Features

- [x] Create a tray
- [x] Custom icon for tray
- [x] Add tooltip.
- [x] Add an on click event listener
- [x] Supported on Windows
- [x] Supported on Linux
- [x] Supported on MacOS
- [x] Menu items can be checked/unchecked
- [x] Menu items can be enabled/disabled
- [ ] Allow menus to have their own icons
- [ ] Allow submenus within menus

## Requirements

For Linux you will need the following packages installed:

```bash
sudo apt-get install libayatana-appindicator3-dev
sudo apt-get install libgtk-3-dev
sudo apt-get install pkg-config
```

For MacOS the tray icon size must be 22x22 pixels in order for it to render correctly.

I have only tested this using GCC, so I am not sure if it will work with other compilers.

## Example

```v
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
```

### Windows 11

![image1.png](assets%2Fimage1.png)

![image2.png](assets%2Fimage2.png)

![image3.png](assets%2Fimage3.png)

![image6.png](assets%2Fimage6.png)

### Linux

![image4.png](assets%2Fimage4.png)

### MacOS

![image5.png](assets%2Fimage5.png)

## Definitions

```v
module vtray

fn create(icon_path string, opts CreatOptions) &Tray
struct MenuItemOptions {
        checked   bool
        checkable bool
        disabled  bool
        on_click  ?fn ()
}
struct Tray {
mut:
        instance   &VTray = unsafe { nil }
        icon       string
        identifier string
        tooltip    string
        items      []&MenuItem
        callbacks  map[int]fn ()
        last_id    int = 1
}
fn (mut t Tray) add_item(text string, opts MenuItemOptions)
fn (t &Tray) set_icon(icon string)
fn (t &Tray) set_tooltip(tooltip string)
fn (t &Tray) get_item(item string) ?&MenuItem
fn (mut t Tray) run()
fn (t &Tray) destroy()
struct CreatOptions {
        identifier string = 'VTray'
        tooltip    string
}
```

## License

MIT License

```text
MIT License

Copyright (c) 2023 Sylvester Stephenson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```
