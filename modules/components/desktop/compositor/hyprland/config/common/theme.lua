-- Wallpaper colors from matugen (borders, shadow). theme-apply renders this
-- file and re-evaluates it live; loading it here keeps the colors after a
-- Hyprland restart or `hyprctl reload`. Missing file = static defaults from
-- appearance.lua.

local home = os.getenv("HOME")
local path = home and (home .. "/.cache/matugen/hyprland-colors.lua")

if path then
    local file = io.open(path, "r")

    if file then
        file:close()

        local ok, err = pcall(dofile, path)

        if not ok then
            print("matugen colors failed to load: " .. tostring(err))
        end
    end
end
