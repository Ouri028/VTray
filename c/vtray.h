
#include <Windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <shellapi.h>

#define WM_TRAYICON (WM_USER + 1)
#define ID_TRAYICON 100

struct VTray
{
    char identifier[256];
    NOTIFYICONDATA notifyData;
    HMENU menu;
    const struct VTrayEntry **entries;
    size_t numEntries;
    struct Allocation *allocations;
    WNDCLASSEX windowClass;
    HINSTANCE hInstance;
    HWND hwnd;
};

struct Allocation
{
    char *name;
};

struct VTrayEntry
{
    char *text;
    bool disabled;
    bool toggled;
    HBITMAP image;
    struct VTrayEntry **submenuEntries;
    size_t numSubmenuEntries;
};

struct VTray *vtray_init(const char *identifier, const char *icon);
void vtray_exit(struct VTray *tray);
void vtray_update(struct VTray *tray);
HMENU vtray_construct(const struct VTrayEntry **entries, size_t numEntries, struct VTray *parent, bool cleanup);
LRESULT CALLBACK vtray_wndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);
void vtray_run(struct VTray *tray);