#include "tray.h"

LRESULT CALLBACK vtray_wndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    struct VTray *tray = (struct VTray *)GetWindowLongPtr(hwnd, GWLP_USERDATA);

    switch (msg)
    {
    case WM_TRAYICON:
        // Handle tray icon messages here
        if (wParam == ID_TRAYICON)
        {
            if (lParam == WM_RBUTTONUP)
            {
                POINT cursor;
                GetCursorPos(&cursor);
                SetForegroundWindow(tray->hwnd);
                TrackPopupMenu(tray->menu, 0, cursor.x, cursor.y, 0, tray->hwnd, NULL);
                PostMessage(tray->hwnd, WM_NULL, 0, 0);
            }
        }
        break;

    case WM_COMMAND:
        // Handle menu item selection
        if (HIWORD(wParam) == 0) // Menu item clicked
        {
            int menuId = LOWORD(wParam);
            // Handle menu item action based on menuId
            // You can identify menu items using their IDs.
        }
        break;

    case WM_CLOSE:
        // Handle window close event
        ShowWindow(tray->hwnd, SW_HIDE);
        break;

    default:
        return DefWindowProc(hwnd, msg, wParam, lParam);
    }
    return 0;
}

struct VTray *vtray_init_windows(const char *identifier, const char *icon, wchar_t *tooltip)
{
    struct VTray *tray = (struct VTray *)malloc(sizeof(struct VTray));
    if (!tray)
    {
        // Handle allocation failure
        return NULL;
    }

    // Initialize other members of the struct
    memset(tray, 0, sizeof(struct VTray));
    strncpy(tray->identifier, identifier, sizeof(tray->identifier));
    // Initialize window class
    memset(&tray->windowClass, 0, sizeof(WNDCLASSEX));
    tray->tooltip = tooltip;
    tray->windowClass.cbSize = sizeof(WNDCLASSEX);
    tray->windowClass.lpfnWndProc = vtray_wndProc;
    tray->windowClass.hInstance = tray->hInstance;
    tray->windowClass.lpszClassName = tray->identifier;

    if (!RegisterClassEx(&tray->windowClass))
    {
        // Handle class registration failure

        free(tray);
        fprintf(stderr, "Failed to register class\n");

        return NULL;
    }

    // Create a hidden window
    tray->hwnd = CreateWindow(tray->identifier, NULL, 0, 0, 0, 0, 0, NULL, NULL, tray->windowClass.hInstance, NULL);

    if (!tray->hwnd)
    {
        // Handle window creation failure
        UnregisterClass(tray->identifier, tray->hInstance);
        free(tray);
        fprintf(stderr, "Failed to create window\n");
        return NULL;
    }

    // Initialize the NOTIFYICONDATA structure
    tray->notifyData.cbSize = sizeof(NOTIFYICONDATA);
    wcscpy(tray->notifyData.szTip, tray->tooltip);
    tray->notifyData.hWnd = tray->hwnd;
    tray->notifyData.uID = ID_TRAYICON;
    tray->notifyData.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
    tray->notifyData.uCallbackMessage = WM_TRAYICON;
    tray->hInstance = GetModuleHandle(NULL);
    tray->notifyData.hIcon = LoadImageA(tray->hInstance, icon, IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTSIZE);

    SetWindowLongPtr(tray->hwnd, GWLP_USERDATA, (LONG_PTR)tray);

    if (Shell_NotifyIcon(NIM_ADD, &tray->notifyData) == FALSE)
    {
        fprintf(stderr, "Failed to register tray icon\n");
        return NULL;
    }

    return tray;
}

void vtray_exit_windows(struct VTray *tray)
{
    // Deallocate memory, destroy windows, etc.

    if (tray)
    {
        if (tray->hwnd)
            DestroyWindow(tray->hwnd);
        if (tray->menu)
            DestroyMenu(tray->menu);
        if (tray->notifyData.hIcon)
            DestroyIcon(tray->notifyData.hIcon);
        UnregisterClass(tray->identifier, tray->hInstance);
        free(tray);
    }
}

void vtray_update(struct VTray *tray)
{
    // Update the system tray icon and menu as needed.
    tray->notifyData.hWnd = tray->hwnd;
    Shell_NotifyIcon(NIM_MODIFY, &tray->notifyData);
}

HMENU vtray_construct(const struct VTrayEntry **entries, size_t numEntries, struct VTray *parent, bool cleanup)
{
    // Construct the menu here.
    HMENU menu = CreatePopupMenu();

    if (menu)
    {
        for (size_t i = 0; i < numEntries; i++)
        {
            const struct VTrayEntry *entry = entries[i];
            MENUITEMINFO menuItem;
            memset(&menuItem, 0, sizeof(MENUITEMINFO));
            menuItem.cbSize = sizeof(MENUITEMINFO);
            menuItem.fMask = MIIM_FTYPE | MIIM_STRING | MIIM_STATE | MIIM_ID;
            menuItem.fType = MFT_STRING;
            menuItem.dwTypeData = entry->text;
            menuItem.cch = strlen(entry->text);
            menuItem.wID = i + 1; // Assign unique IDs to each menu item

            if (entry->disabled)
            {
                menuItem.fState = MFS_DISABLED;
            }

            if (entry->toggled)
            {
                menuItem.fState |= MFS_CHECKED;
            }

            if (entry->image)
            {
                menuItem.fMask |= MIIM_BITMAP;
                menuItem.hbmpItem = entry->image;
            }

            InsertMenuItem(menu, i, TRUE, &menuItem);

            // If the entry has sub-menu items, create them recursively
            if (entry->numSubmenuEntries > 0)
            {
                HMENU submenu = vtray_construct(entry->submenuEntries, entry->numSubmenuEntries, parent, false);
                if (submenu)
                {
                    menuItem.hSubMenu = submenu;
                    SetMenuItemInfo(menu, i, TRUE, &menuItem);
                }
            }
        }
    }

    if (cleanup)
    {
        // Cleanup the menu if this is the top-level menu
        // (do not destroy sub-menu items' menus)
        for (size_t i = 0; i < numEntries; i++)
        {
            const struct VTrayEntry *entry = entries[i];
            if (entry->numSubmenuEntries > 0)
            {
                for (size_t j = 0; j < entry->numSubmenuEntries; j++)
                {
                    free(entry->submenuEntries[j]->text);
                    // Free any other resources associated with sub-menu entries
                }
                free(entry->submenuEntries);
            }
            free(entry->text);
            // Free any other resources associated with menu entries
        }
    }

    return menu;
}

void vtray_run_windows(struct VTray *tray)
{
    // Show and run your Windows application loop here.
    ShowWindow(tray->hwnd, SW_HIDE);

    // Update the system tray icon
    vtray_update(tray);

    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
}
