local function monitorRule(output, mirror)
    hl.monitor({
        output = output,
        mode = output == "DP-2" and "2560x1440@144" or "preferred",
        position = "auto",
        scale = 1,
        mirror = mirror or "",
    })
end

monitorRule("")
monitorRule("DP-2")

local function isLaptopPanel(name)
    return name:match("^eDP%-") or name:match("^LVDS%-")
end

local mirrored = {}
local applying = false

local function updateMirroring()
    if applying then
        return
    end

    local monitors = hl.get_monitors()
    local laptop
    for _, monitor in ipairs(monitors) do
        if isLaptopPanel(monitor.name) and not monitor.is_mirror then
            laptop = monitor.name
            break
        end
    end

    -- Applying a mirror rule can emit monitor events itself.
    applying = true
    if laptop then
        for _, monitor in ipairs(monitors) do
            if monitor.name ~= laptop and not isLaptopPanel(monitor.name)
                and mirrored[monitor.name] ~= laptop then
                mirrored[monitor.name] = laptop
                monitorRule(monitor.name, laptop)
            end
        end
    else
        -- Restore independent external displays if the laptop panel disappears.
        local previous = mirrored
        mirrored = {}
        for output in pairs(previous) do
            monitorRule(output)
        end
    end
    applying = false
end

hl.on("hyprland.start", updateMirroring)
hl.on("config.reloaded", function()
    mirrored = {}
    updateMirroring()
end)
hl.on("monitor.added", function(monitor)
    if applying then return end
    mirrored[monitor.name] = nil
    updateMirroring()
end)
hl.on("monitor.removed", function(monitor)
    if applying then return end
    mirrored[monitor.name] = nil
    updateMirroring()
end)
