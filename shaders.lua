-- shaders.lua : ambiances visuelles côté client
local Lighting = game:GetService("Lighting")

local Shaders = {}
local created = {}
local saved = {}

local PRESETS = {
    ["Doux"] = {
        bloom = { Intensity = 0.4, Size = 24, Threshold = 1.8 },
        color = { Brightness = 0.02, Contrast = 0.08, Saturation = 0.1, TintColor = Color3.fromRGB(255, 248, 240) },
        rays = { Intensity = 0.08, Spread = 0.6 },
        atmo = { Density = 0.25, Offset = 0.1, Color = Color3.fromRGB(200, 210, 225), Decay = Color3.fromRGB(120, 130, 150), Glare = 0.1, Haze = 0.6 },
    },
    ["Néon nuit"] = {
        bloom = { Intensity = 1.2, Size = 40, Threshold = 0.9 },
        color = { Brightness = -0.03, Contrast = 0.2, Saturation = 0.35, TintColor = Color3.fromRGB(190, 170, 255) },
        rays = { Intensity = 0, Spread = 0.5 },
        atmo = { Density = 0.35, Offset = 0, Color = Color3.fromRGB(80, 60, 140), Decay = Color3.fromRGB(40, 20, 90), Glare = 0, Haze = 1.2 },
        clock = 0,
    },
    ["Rétro"] = {
        bloom = { Intensity = 0.3, Size = 18, Threshold = 1.5 },
        color = { Brightness = 0.04, Contrast = 0.12, Saturation = -0.25, TintColor = Color3.fromRGB(255, 228, 190) },
        rays = { Intensity = 0.05, Spread = 0.5 },
        atmo = { Density = 0.2, Offset = 0.2, Color = Color3.fromRGB(225, 200, 170), Decay = Color3.fromRGB(150, 120, 90), Glare = 0, Haze = 0.8 },
    },
    ["Cinéma"] = {
        bloom = { Intensity = 0.6, Size = 30, Threshold = 1.2 },
        color = { Brightness = 0, Contrast = 0.25, Saturation = 0.05, TintColor = Color3.fromRGB(235, 245, 255) },
        rays = { Intensity = 0.15, Spread = 0.8 },
        atmo = { Density = 0.3, Offset = 0.15, Color = Color3.fromRGB(190, 200, 215), Decay = Color3.fromRGB(100, 110, 130), Glare = 0.3, Haze = 1 },
        dof = { FarIntensity = 0.25, FocusDistance = 60, InFocusRadius = 40, NearIntensity = 0 },
    },
}

function Shaders.Presets()
    local names = {}
    for name in pairs(PRESETS) do table.insert(names, name) end
    table.sort(names)
    return names
end

local function make(class, name, props)
    local inst = Instance.new(class)
    inst.Name = name
    for k, v in pairs(props) do inst[k] = v end
    inst.Parent = Lighting
    table.insert(created, inst)
    return inst
end

function Shaders.Clear()
    for _, inst in ipairs(created) do pcall(function() inst:Destroy() end) end
    table.clear(created)
    if saved.ClockTime then
        Lighting.ClockTime = saved.ClockTime
        saved = {}
    end
end

function Shaders.Apply(name)
    local preset = PRESETS[name]
    if not preset then return false end
    Shaders.Clear()
    if not saved.ClockTime then saved.ClockTime = Lighting.ClockTime end

    make("BloomEffect", "HubBloom", preset.bloom)
    make("ColorCorrectionEffect", "HubColor", preset.color)
    make("SunRaysEffect", "HubRays", preset.rays)
    make("Atmosphere", "HubAtmo", preset.atmo)
    if preset.dof then make("DepthOfFieldEffect", "HubDof", preset.dof) end
    if preset.clock then Lighting.ClockTime = preset.clock end
    return true
end

return Shaders
