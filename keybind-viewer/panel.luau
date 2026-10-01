--!nonstrict
-- Keybind Viewer
--
-- Deliberately small and read-only:
--   * executes only: hyprctl -j binds
--   * uses argv execution (no shell)
--   * performs no network access
--   * reads/writes no files
--   * never dispatches or edits a binding

local bindings = {}
local query = ""
local loading = false
local errorMessage = nil
local searchKey = 0

local labels = require("./labels.luau")
local CATEGORY_ORDER = labels.categoryOrder
local KNOWN = labels.known

local function hasBit(mask, bit)
    return math.floor((tonumber(mask) or 0) / bit) % 2 == 1
end

local function digitFromCode(code)
    code = tonumber(code)
    if code == nil then return nil end
    if code >= 10 and code <= 18 then return tostring(code - 9) end
    if code == 19 then return "0" end
    return nil
end

local function displayKey(binding)
    local key = tostring(binding.key or "")
    local code = tonumber(binding.keycode or 0) or 0

    local codeInKey = string.match(key, "^code:(%d+)$")
    if codeInKey ~= nil then
        local digit = digitFromCode(codeInKey)
        if digit ~= nil then return digit end
        if tonumber(codeInKey) == 82 then return "Keypad -" end
        if tonumber(codeInKey) == 86 then return "Keypad +" end
        return "Code " .. codeInKey
    end

    if key == "" and code > 0 then
        local digit = digitFromCode(code)
        if digit ~= nil then return digit end
        if code == 82 then return "Keypad -" end
        if code == 86 then return "Keypad +" end
        return "Code " .. tostring(code)
    end

    local names = {
        ["Return"] = "Return",
        ["Escape"] = "Escape",
        ["space"] = "Space",
        ["Space"] = "Space",
        ["period"] = ".",
        ["mouse:272"] = "LMB",
        ["mouse:273"] = "RMB",
        ["mouse_up"] = "Wheel Up",
        ["mouse_down"] = "Wheel Down",
        ["mouse_left"] = "Wheel Left",
        ["mouse_right"] = "Wheel Right",
        ["XF86Calculator"] = "Calculator",
        ["XF86AudioRaiseVolume"] = "Volume Up",
        ["XF86AudioLowerVolume"] = "Volume Down",
        ["XF86AudioMute"] = "Volume Mute",
        ["XF86AudioMicMute"] = "Mic Mute",
        ["XF86AudioPlay"] = "Media Play",
        ["XF86AudioPause"] = "Media Pause",
        ["XF86AudioNext"] = "Media Next",
        ["XF86AudioPrev"] = "Media Previous",
        ["XF86MonBrightnessUp"] = "Brightness Up",
        ["XF86MonBrightnessDown"] = "Brightness Down",
    }

    return names[key] or key
end

local function modifierState(binding)
    local mask = tonumber(binding.modmask or 0) or 0
    return {
        shift = hasBit(mask, 1),
        ctrl = hasBit(mask, 4),
        alt = hasBit(mask, 8),
        super = hasBit(mask, 64),
    }
end

local function chordFor(binding)
    local mods = modifierState(binding)
    local parts = {}
    if mods.super then table.insert(parts, "Super") end
    if mods.ctrl then table.insert(parts, "Ctrl") end
    if mods.alt then table.insert(parts, "Alt") end
    if mods.shift then table.insert(parts, "Shift") end

    local key = displayKey(binding)
    if key ~= "" then table.insert(parts, key) end
    return table.concat(parts, " + ")
end

local function dynamicWorkspaceDescription(binding, key)
    if not string.match(key, "^%d$") then return nil end

    local mods = modifierState(binding)
    if not mods.super then return nil end

    if mods.shift and mods.ctrl and not mods.alt then
        return "Move window to workspace " .. key, "Workspaces & Monitors"
    elseif mods.shift and mods.alt and not mods.ctrl then
        return "Move window to workspace " .. key .. " (stay here)", "Workspaces & Monitors"
    elseif mods.alt and not mods.shift and not mods.ctrl then
        return "Focus workspace " .. key, "Workspaces & Monitors"
    elseif mods.ctrl and not mods.shift and not mods.alt then
        return "Focus workspace " .. key, "Workspaces & Monitors"
    elseif mods.shift and not mods.ctrl and not mods.alt then
        return "Move window to monitor " .. key, "Workspaces & Monitors"
    elseif not mods.shift and not mods.ctrl and not mods.alt then
        return "Focus monitor " .. key, "Workspaces & Monitors"
    end

    return nil
end

local function presentationFor(binding)
    local chord = chordFor(binding)
    local key = displayKey(binding)
    local known = KNOWN[chord]
    local description = nil
    local category = nil

    if known ~= nil then
        description = known[1]
        category = known[2]
    else
        description, category = dynamicWorkspaceDescription(binding, key)
    end

    local supplied = tostring(binding.description or "")
    if supplied ~= "" then
        description = supplied
    end

    if description == nil or description == "" then
        local dispatcher = tostring(binding.dispatcher or "")
        local arg = tostring(binding.arg or "")
        if dispatcher ~= "" and dispatcher ~= "__lua" then
            description = dispatcher .. (arg ~= "" and (" " .. arg) or "")
        else
            description = "Hyprland binding"
        end
    end

    if category == nil then category = "Other" end

    local submap = tostring(binding.submap or "")
    if submap == "default" then submap = "" end

    return {
        chord = chord ~= "" and chord or "Unknown key",
        description = description,
        category = category,
        categoryIndex = CATEGORY_ORDER[category] or 99,
        submap = submap,
    }
end

local function filteredBindings()
    local needle = string.lower(query)
    local result = {}

    for _, item in ipairs(bindings) do
        local haystack = string.lower(item.chord .. " " .. item.description .. " " .. item.category .. " " .. item.submap)
        if needle == "" or string.find(haystack, needle, 1, true) ~= nil then
            table.insert(result, item)
        end
    end

    table.sort(result, function(a, b)
        if a.categoryIndex ~= b.categoryIndex then return a.categoryIndex < b.categoryIndex end
        if a.category ~= b.category then return a.category < b.category end
        if a.chord ~= b.chord then return a.chord < b.chord end
        return a.description < b.description
    end)

    return result
end

local function bindingRow(item, index)
    local actionChildren = {
        ui.label({
            text = item.description,
            fontSize = 13,
            color = "on_surface",
            maxLines = 1,
        }),
    }

    if item.submap ~= "" then
        table.insert(actionChildren, ui.label({
            text = "Submap: " .. item.submap,
            fontSize = 11,
            color = "on_surface_variant",
            maxLines = 1,
        }))
    end

    return ui.row({
        key = "binding-" .. tostring(index) .. "-" .. item.chord,
        gap = 18,
        align = "center",
        paddingV = 7,
        paddingH = 8,
    }, {
        ui.label({
            text = item.chord,
            width = 270,
            fontSize = 12,
            fontWeight = "medium",
            fontFamily = "JetBrainsMono Nerd Font Mono",
            color = "primary",
            maxLines = 1,
        }),
        ui.column({ flexGrow = 1, gap = 2 }, actionChildren),
    })
end

local function render()
    local visible = filteredBindings()
    local rows = {}
    local currentCategory = nil

    if loading and #bindings == 0 then
        table.insert(rows, ui.label({
            text = "Reading active Hyprland keybinds…",
            color = "on_surface_variant",
        }))
    elseif errorMessage ~= nil then
        table.insert(rows, ui.label({
            text = errorMessage,
            color = "error",
            maxLines = 4,
        }))
    elseif #visible == 0 then
        table.insert(rows, ui.label({
            text = "No keybinds match “" .. query .. "”.",
            color = "on_surface_variant",
        }))
    else
        for i, item in ipairs(visible) do
            if item.category ~= currentCategory then
                if currentCategory ~= nil then
                    table.insert(rows, ui.separator({ spacing = 6 }))
                end
                currentCategory = item.category
                table.insert(rows, ui.label({
                    key = "category-" .. currentCategory,
                    text = currentCategory,
                    fontSize = 12,
                    fontWeight = "bold",
                    color = "on_surface_variant",
                }))
            end
            table.insert(rows, bindingRow(item, i))
        end
    end

    local status
    if loading then
        status = "Refreshing…"
    elseif errorMessage ~= nil then
        status = "Unable to read Hyprland keybinds"
    elseif query ~= "" then
        status = tostring(#visible) .. " matches · " .. tostring(#bindings) .. " active bindings"
    else
        status = tostring(#bindings) .. " active bindings · live from Hyprland · read-only"
    end

    panel.render(ui.column({ flexGrow = 1, gap = 14 }, {
        ui.row({ align = "center", justify = "space_between", gap = 10 }, {
            ui.column({ flexGrow = 1, gap = 2 }, {
                ui.label({
                    text = "Keybinds",
                    fontSize = 18,
                    fontWeight = "bold",
                    color = "on_surface",
                }),
                ui.label({
                    text = status,
                    fontSize = 11,
                    color = "on_surface_variant",
                }),
            }),
            ui.button({ text = "Refresh", controlSize = "sm", variant = "ghost", onClick = "onRefreshClicked" }),
            ui.button({ glyph = "close", controlSize = "sm", variant = "ghost", onClick = "onCloseClicked" }),
        }),

        ui.input({
            key = "search-" .. tostring(searchKey),
            value = query,
            placeholder = "Search keys, actions or categories…",
            controlSize = "md",
            focus = true,
            onChange = "onSearchChanged",
        }),

        ui.scroll({ flexGrow = 1, gap = 2, align = "stretch" }, rows),
    }))
end

local function refreshBindings()
    loading = true
    errorMessage = nil
    render()

    local accepted = noctalia.runAsync({ "hyprctl", "-j", "binds" }, function(result)
        loading = false

        if result.exitCode ~= 0 then
            errorMessage = "hyprctl failed: " .. tostring(result.stderr or "unknown error")
            render()
            return
        end

        local decoded, decodeError = noctalia.json.decode(result.stdout or "")
        if decoded == nil then
            errorMessage = "Could not parse hyprctl JSON: " .. tostring(decodeError or "unknown error")
            render()
            return
        end

        local nextBindings = {}
        for _, binding in ipairs(decoded) do
            table.insert(nextBindings, presentationFor(binding))
        end

        bindings = nextBindings
        errorMessage = nil
        render()
    end, 2500)

    if not accepted then
        loading = false
        errorMessage = "Noctalia could not start hyprctl."
        render()
    end
end

function onOpen(_context)
    query = ""
    searchKey = searchKey + 1
    refreshBindings()
end

function onSearchChanged(value)
    query = value or ""
    render()
end

function onRefreshClicked()
    refreshBindings()
end

function onCloseClicked()
    panel.close()
end
