# Keybind Viewer

A small, read-only Noctalia v5 panel for the active Hyprland keybindings on the Linux Desktop setup.

## Design

The plugin deliberately has a tiny trust surface:

- runs only `hyprctl -j binds`;
- uses Noctalia's argv subprocess API, so no shell parses the command;
- makes no network requests;
- reads no configuration files;
- writes no files or cache;
- never dispatches, edits, or executes a displayed keybind;
- refreshes only when opened or when **Refresh** is clicked.

The live binding list always comes from Hyprland. `labels.luau` contains a small presentation-only table for friendly names/categories for the stock CachyOS Hyprland/Noctalia bindings; unknown/custom bindings are still displayed. If a Hyprland binding provides its own `description`, that description takes precedence.

## Requirements

- Noctalia v5 with plugin API 24 or newer
- Hyprland
- `hyprctl`
- Optional but recommended for the key-chord column: `JetBrainsMono Nerd Font Mono`

## Install

Add this repository as a Noctalia plugin source:

```bash
noctalia msg plugins source add keybind-viewer git <repo-url>
```

Then enable the plugin:

```bash
noctalia msg plugins enable kevinalmansa/keybind-viewer
```

The plugin will then be available to Noctalia as `kevinalmansa/keybind-viewer`.

Reload Noctalia's configuration and enable the plugin:

```fish
noctalia msg config-reload
noctalia msg plugins enable kevinalmansa/keybind-viewer
```

Open the panel:

```fish
noctalia msg panel-toggle kevinalmansa/keybind-viewer:cheatsheet
```

## Optional Hyprland shortcut

After confirming the panel works, add a single personal bind to `~/.config/hypr/config/binds.lua`.

```lua
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd(noctCall .. "panel-toggle kevinalmansa/keybind-viewer:cheatsheet"), {
    description = "Show keybind viewer",
})
```

Then reload Hyprland:

```fish
hyprctl reload
```

`Super + F1` will then toggle the viewer. The description is deliberately attached to this new bind so Hyprland exposes a useful label for it.

## Uninstall

Disable it first:

```fish
noctalia msg plugins disable kevinalmansa/keybind-viewer
```

Then remove it from Noctalia.

If you added the optional Hyprland shortcut, remove that one `hl.bind(...)` block and run `hyprctl reload`.
