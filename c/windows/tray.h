#pragma once
#ifdef _WIN32
#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <shellapi.h>

#define WM_TRAYICON (WM_USER + 1)
#define ID_TRAYICON 100

// FIXME: Implement opaque struct for windows implementation.

// In your header file (e.g., mylib.h)
// typedef struct MyOpaqueStruct MyOpaqueStruct;

// // Function to create and initialize the opaque struct
// MyOpaqueStruct *createMyStruct();

// // Function to set a value in the opaque struct
// void setMyStructValue(MyOpaqueStruct *obj, int value);

// // Function to get a value from the opaque struct
// int getMyStructValue(MyOpaqueStruct *obj);

// // Function to destroy the opaque struct
// void destroyMyStruct(MyOpaqueStruct *obj);

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
    wchar_t *tooltip;
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

struct VTray *vtray_init_windows(const char *identifier, const char *icon, wchar_t *tooltip);
void vtray_exit_windows(struct VTray *tray);
void vtray_update(struct VTray *tray);
HMENU vtray_construct(const struct VTrayEntry **entries, size_t numEntries, struct VTray *parent, bool cleanup);
LRESULT CALLBACK vtray_wndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);
void vtray_run_windows(struct VTray *tray);

#endif
