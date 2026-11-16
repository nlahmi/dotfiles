; chromescroll: scroll over a Chromium browser's tab bar to switch tabs,
; the way Chrome does natively on Linux (Windows builds hard-code it off).
;   wheel up   -> previous tab (Ctrl+PgUp)
;   wheel down -> next tab     (Ctrl+PgDn)
; Ctrl/Shift/Alt + wheel keep their normal behavior (e.g. Ctrl+wheel zoom).
#Requires AutoHotkey v2.0
#SingleInstance Force

; Browsers to act on, matched against the process name.
BROWSER_EXES := "i)^(chrome|Island)\.exe$"

; Height of the scroll zone below the visible top of the window, in DIPs
; (pixels at 100% scaling). The tab bar of a maximized window measures 41 DIP;
; the extra covers the padding Chromium adds above the tabs when the window is
; not maximized. Overshooting only reaches the toolbar, which doesn't scroll.
TAB_BAR_DIP := 50

#HotIf MouseOverTabBar()
WheelUp::   SwitchTab("^{PgUp}")
WheelDown:: SwitchTab("^{PgDn}")
#HotIf

MouseOverTabBar() {
    ; Use physical pixels so monitors with different scaling agree.
    DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")  ; PER_MONITOR_AWARE_V2
    CoordMode "Mouse", "Screen"
    MouseGetPos(&x, &y, &hwnd)
    return IsOverTabBar(x, y, hwnd)
}

IsOverTabBar(x, y, hwnd) {
    try {
        if !(WinGetProcessName(hwnd) ~= BROWSER_EXES)
            return false
        if WinGetClass(hwnd) != "Chrome_WidgetWin_1"
            return false
        ; Real browser windows are resizable; menus and the omnibox dropdown aren't.
        if !(WinGetStyle(hwnd) & 0x40000)  ; WS_THICKFRAME
            return false
        WinGetPos(, &wy, , , hwnd)
        maximized := WinGetMinMax(hwnd) = 1
    } catch {
        return false
    }
    dpi := DllCall("GetDpiForWindow", "ptr", hwnd, "uint")
    top := wy
    if maximized {
        ; A maximized window's resize border hangs off-screen above the tabs.
        top += DllCall("GetSystemMetricsForDpi", "int", 33, "uint", dpi)  ; SM_CYSIZEFRAME
        top += DllCall("GetSystemMetricsForDpi", "int", 92, "uint", dpi)  ; SM_CXPADDEDBORDER
    }
    return y - top < TAB_BAR_DIP * dpi / 96
}

SwitchTab(keys) {
    ; Tab shortcuts go to the focused window, so focus the one under the cursor.
    MouseGetPos(, , &hwnd)
    if !WinActive(hwnd)
        WinActivate(hwnd)
    Send(keys)
}
