--!nonstrict
-- Friendly presentation metadata for the current CachyOS Hyprland/Noctalia defaults.
-- This file does not determine which binds exist; Hyprland remains the source of truth.

local M = {}

M.categoryOrder = {
    ["Applications"] = 1,
    ["Window Management"] = 2,
    ["Workspaces & Monitors"] = 3,
    ["Shell & Desktop"] = 4,
    ["Hardware & Media"] = 5,
    ["Utilities"] = 6,
    ["Other"] = 99,
}

M.known = {
    ["Super + Escape"] = { "Force close app/window", "Window Management" },
    ["Super + Q"] = { "Close focused window", "Window Management" },
    ["Super + Alt + Space"] = { "Toggle floating / tiled", "Window Management" },
    ["Super + D"] = { "Maximize focused window", "Window Management" },
    ["Super + F"] = { "Fullscreen focused window", "Window Management" },
    ["Super + J"] = { "Toggle split direction", "Window Management" },
    ["Super + Left"] = { "Focus left", "Window Management" },
    ["Super + Right"] = { "Focus right", "Window Management" },
    ["Super + Up"] = { "Focus up", "Window Management" },
    ["Super + Down"] = { "Focus down", "Window Management" },
    ["Alt + Tab"] = { "Switch window focus", "Window Management" },
    ["Super + Tab"] = { "Open window switcher", "Window Management" },
    ["Super + Shift + Up"] = { "Move window up", "Window Management" },
    ["Super + Shift + Right"] = { "Move window right", "Window Management" },
    ["Super + Shift + Left"] = { "Move window left", "Window Management" },
    ["Super + Shift + Down"] = { "Move window down", "Window Management" },
    ["Super + LMB"] = { "Move window with mouse", "Window Management" },
    ["Super + RMB"] = { "Resize window with mouse", "Window Management" },
    ["Super + Minus"] = { "Zoom out", "Window Management" },
    ["Super + Plus"] = { "Zoom in", "Window Management" },
    ["Super + Keypad -"] = { "Zoom out", "Window Management" },
    ["Super + Keypad +"] = { "Zoom in", "Window Management" },

    ["Super + Return"] = { "Terminal", "Applications" },
    ["Super + E"] = { "File manager", "Applications" },
    ["Super + T"] = { "Editor", "Applications" },
    ["Super + C"] = { "Calculator", "Applications" },
    ["Calculator"] = { "Calculator", "Applications" },
    ["Super + W"] = { "Browser", "Applications" },
    ["Ctrl + Shift + Escape"] = { "System monitor", "Applications" },

    ["Super + Z"] = { "Noctalia settings", "Shell & Desktop" },
    ["Super + X"] = { "Control center", "Shell & Desktop" },
    ["Super + Space"] = { "Application launcher", "Shell & Desktop" },
    ["Super + ."] = { "Emoji picker", "Shell & Desktop" },
    ["Super + L"] = { "Lock screen", "Shell & Desktop" },
    ["Super + Alt + C"] = { "Session menu", "Shell & Desktop" },
    ["Super + Shift + W"] = { "Wallpaper picker", "Shell & Desktop" },
    ["Super + V"] = { "Clipboard history", "Shell & Desktop" },
    ["Super + A"] = { "Notifications", "Shell & Desktop" },

    ["Volume Up"] = { "Volume up", "Hardware & Media" },
    ["Volume Down"] = { "Volume down", "Hardware & Media" },
    ["Volume Mute"] = { "Toggle audio mute", "Hardware & Media" },
    ["Mic Mute"] = { "Toggle microphone mute", "Hardware & Media" },
    ["Media Play"] = { "Play / pause media", "Hardware & Media" },
    ["Media Pause"] = { "Play / pause media", "Hardware & Media" },
    ["Media Next"] = { "Next media track", "Hardware & Media" },
    ["Media Previous"] = { "Previous media track", "Hardware & Media" },
    ["Brightness Up"] = { "Brightness up", "Hardware & Media" },
    ["Brightness Down"] = { "Brightness down", "Hardware & Media" },

    ["Super + P"] = { "Colour picker", "Utilities" },
    ["Print"] = { "Region screenshot", "Utilities" },
    ["Super + Print"] = { "Fullscreen screenshot", "Utilities" },

    ["Super + Shift + S"] = { "Move window to scratchpad", "Workspaces & Monitors" },
    ["Super + S"] = { "Toggle scratchpad", "Workspaces & Monitors" },
    ["Super + Ctrl + Right"] = { "Focus next workspace", "Workspaces & Monitors" },
    ["Super + Ctrl + Left"] = { "Focus previous workspace", "Workspaces & Monitors" },
    ["Super + Ctrl + Down"] = { "Focus next empty workspace", "Workspaces & Monitors" },
    ["Super + Wheel Down"] = { "Focus previous workspace", "Workspaces & Monitors" },
    ["Super + Wheel Up"] = { "Focus next workspace", "Workspaces & Monitors" },
    ["Super + Ctrl + Wheel Up"] = { "Focus previous workspace", "Workspaces & Monitors" },
    ["Super + Ctrl + Wheel Down"] = { "Focus next workspace", "Workspaces & Monitors" },
    ["Super + Shift + Wheel Up"] = { "Move window to previous monitor", "Workspaces & Monitors" },
    ["Super + Shift + Wheel Down"] = { "Move window to next monitor", "Workspaces & Monitors" },
    ["Super + Ctrl + Shift + Right"] = { "Move window to next workspace", "Workspaces & Monitors" },
    ["Super + Ctrl + Shift + Left"] = { "Move window to previous workspace", "Workspaces & Monitors" },
    ["Super + Ctrl + Shift + Wheel Up"] = { "Move window to previous workspace", "Workspaces & Monitors" },
    ["Super + Ctrl + Shift + Wheel Down"] = { "Move window to next workspace", "Workspaces & Monitors" },
}

return M
