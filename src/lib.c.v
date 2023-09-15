module vtray

import builtin.wchar

#flag -I @VMODROOT/c/vtray.h
#flag @VMODROOT/c/vtray.c
#include "@VMODROOT/c/vtray.h"

struct C.VTray {}

pub type Vtray = C.VTray

fn C.vtray_init(identifier &char, icon &char, tooltip &wchar.Character) &Vtray
fn C.vtray_run(tray &Vtray)
fn C.vtray_update(tray &Vtray)
fn C.vtray_exit(tray &Vtray)
