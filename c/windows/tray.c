#ifdef _WIN32

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
                SetForegroundWindow(hwnd);
                TrackPopupMenu(tray->menu, TPM_TOPALIGN | TPM_LEFTALIGN | TPM_HORPOSANIMATION, cursor.x, cursor.y,
                               0, tray->hwnd, NULL);
                PostMessage(hwnd, WM_NULL, 0, 0);
            }
        }
        break;

    case WM_COMMAND:
        // Handle menu item selection
        if (HIWORD(wParam) == 0) // Menu item clicked
        {
            int menuId = LOWORD(wParam);
            BOOL checked = is_menu_item_checked(tray->menu, menuId);
            vtray_update_menu_item(tray, menuId, !checked);
            tray->on_click(menuId);
        }
        break;

    case WM_CLOSE:
        // Handle window close event
        ShowWindow(hwnd, SW_HIDE);
        break;

    default:
        return DefWindowProc(hwnd, msg, wParam, lParam);
    }
    return 0;
}

struct VTray *vtray_init_windows(VTrayParamsWindows *params, size_t num_items, struct MenuItemWindows *items[])
{
    struct VTray *tray = (struct VTray *)malloc(sizeof(struct VTray));
    if (!tray)
    {
        // Handle allocation failure
        return NULL;
    }

    // Initialize other members of the struct
    memset(tray, 0, sizeof(struct VTray));

    strncpy(tray->identifier, params->identifier, sizeof(tray->identifier));
    // Initialize window class
    memset(&tray->windowClass, 0, sizeof(WNDCLASSEX));
    tray->tooltip = params->tooltip;
    tray->windowClass.cbSize = sizeof(WNDCLASSEX);
    tray->windowClass.lpfnWndProc = vtray_wndProc;
    tray->windowClass.hInstance = tray->hInstance;
    tray->windowClass.lpszClassName = tray->identifier;
    tray->items = items;
    tray->num_items = num_items;

    if (!RegisterClassEx(&tray->windowClass))
    {
        // Handle class registration failure

        free(tray);
        fprintf(stderr, "Failed to register class\n");

        return NULL;
    }

    // Create a hidden window
    tray->hwnd = CreateWindow(tray->identifier, NULL, 0, 0, 0, 0, 0, NULL, NULL, tray->windowClass.hInstance,
                              NULL);

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
    wcscpy((wchar_t *)tray->notifyData.szTip, tray->tooltip);
    tray->notifyData.hWnd = tray->hwnd;
    tray->notifyData.uID = ID_TRAYICON;
    tray->notifyData.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
    tray->notifyData.uCallbackMessage = WM_TRAYICON;
    tray->hInstance = GetModuleHandle(NULL);
    tray->notifyData.hIcon = LoadImageA(tray->hInstance, params->icon, IMAGE_ICON, 0, 0,
                                        LR_LOADFROMFILE | LR_DEFAULTSIZE);
    vtray_construct(tray);
    tray->on_click = params->on_click;
    SetWindowLongPtr(tray->notifyData.hWnd, GWLP_USERDATA, (LONG_PTR)tray);
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
        exit(1);
    }
}

void vtray_update_windows(struct VTray *tray)
{
    // Update the system tray icon and menu as needed.
    tray->notifyData.hWnd = tray->hwnd;
    Shell_NotifyIcon(NIM_MODIFY, &tray->notifyData);
}

void vtray_construct(struct VTray *parent)
{
    parent->menu = CreatePopupMenu();
    if (parent->menu)
    {

        for (size_t i = 0; i < parent->num_items; i++)
        {
            struct MenuItemWindows *item = parent->items[i];
            MENUITEMINFO menuItem;
            memset(&menuItem, 0, sizeof(MENUITEMINFO));
            menuItem.cbSize = sizeof(MENUITEMINFO);
            menuItem.fMask = MIIM_ID | MIIM_TYPE | MIIM_STATE;
            menuItem.wID = item->id;
            menuItem.fMask |= MIIM_BITMAP;
            // TODO: Add menu icon support.
            //            if (item->image != NULL) {
            //
            //                menuItem.hbmpItem = LoadBitmapA(parent->hInstance, item->image);
            //            }

            if (item->checkable)
            {
                menuItem.fState = item->checked ? MFS_CHECKED : MFS_UNCHECKED;
            }
            if (item->disabled)
            {
                menuItem.fState |= MFS_DISABLED;
            }
            if (!AppendMenu(parent->menu, MF_STRING | (item->checkable ? MF_CHECKED : 0) | (item->disabled ? MF_GRAYED : 0), item->id, (LPCSTR)item->text))
            {
                fprintf(stderr, "Failed to add menu item\n");
                exit(1);
            }
        }
    }
}

BOOL is_menu_item_checked(HMENU menu, UINT menuId)
{
    MENUITEMINFO menuItemInfo;
    memset(&menuItemInfo, 0, sizeof(MENUITEMINFO));
    menuItemInfo.cbSize = sizeof(MENUITEMINFO);
    menuItemInfo.fMask = MIIM_STATE;

    if (GetMenuItemInfo(menu, menuId, FALSE, &menuItemInfo))
    {
        return (menuItemInfo.fState & MFS_CHECKED) != 0;
    }

    return FALSE;
}

void vtray_update_menu_item(struct VTray *tray, int menu_id, bool checked)
{
    MENUITEMINFO menuItemInfo = get_menu_item_by_id(tray->menu, menu_id);
    if (menuItemInfo.wID == 0)
    {
        fprintf(stderr, "Failed to find menu item with ID %d\n", menu_id);
        return;
    }
    menuItemInfo.fMask = MIIM_STATE;
    MenuItemWindows *item = get_vmenu_item_by_id(menu_id, tray);
    if (item == NULL)
    {
        fprintf(stderr, "Failed to find menu item with ID %d\n", menu_id);
        return NULL;
    }

    if (!item->checkable)
    {
        return NULL;
    }
    menuItemInfo.fState = (checked ? MFS_CHECKED : MFS_UNCHECKED);
    SetMenuItemInfo(tray->menu, menu_id, FALSE, &menuItemInfo);
}

MENUITEMINFO get_menu_item_by_id(HMENU menu, UINT menu_id)
{
    MENUITEMINFO menuItemInfo;
    memset(&menuItemInfo, 0, sizeof(MENUITEMINFO));
    menuItemInfo.cbSize = sizeof(MENUITEMINFO);
    menuItemInfo.fMask = MIIM_ID | MIIM_STATE | MIIM_FTYPE;

    int itemCount = GetMenuItemCount(menu);
    for (int i = 0; i < itemCount; ++i)
    {
        menuItemInfo.wID = 0; // Reset to 0 for each iteration
        if (GetMenuItemInfo(menu, i, TRUE, &menuItemInfo) && menuItemInfo.wID == menu_id)
        {
            // Found the menu item with the specified ID
            return menuItemInfo;
        }
    }
    memset(&menuItemInfo, 0, sizeof(MENUITEMINFO));
    menuItemInfo.cbSize = sizeof(MENUITEMINFO);
    return menuItemInfo;
}

MenuItemWindows *get_vmenu_item_by_id(int menu_id, struct VTray *tray)
{
    for (size_t i = 0; i < tray->num_items; i++)
    {
        if (tray->items[i]->id == menu_id)
        {
            return tray->items[i];
        }
    }
    return (MenuItemWindows *){0};
}

void vtray_run_windows(struct VTray *tray)
{
    // Show and run your Windows application loop here.
    ShowWindow(tray->hwnd, SW_HIDE);

    // Update the system tray icon
    vtray_update_windows(tray);

    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
}

#endif