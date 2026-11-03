-- mm2.lua : panneau d'options (tout vient de mon dépôt)
print("[mm2] chargé")

local SLATE_URL = "https://raw.githubusercontent.com/lnothingltherel/MM2hub/refs/heads/main/slate.lua"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Ferme l'ancien panneau s'il existe
if type(_G.MonHubPanel) == "table" and _G.MonHubPanel.Cleanup then
    pcall(_G.MonHubPanel.Cleanup)
end
_G.MonHubPanel = {}

-- Chargement de Slate (sans Cleanup, pour ne pas fermer le hub)
local okSlate, Slate = pcall(function()
    return loadstring(game:HttpGet(SLATE_URL), "@Slate")()
end)
if not okSlate or type(Slate) ~= "table" then
    warn("[mm2] Slate n'a pas pu se charger : " .. tostring(Slate))
    return
end
pcall(function() Slate:PreloadIcons({ "lucide" }) end)

-- Réglages
local state = {
    speedOn = false, speed = 16,
    jumpOn = false, jump = 50,
    infJump = false,
    esp = false,
    fullbright = false,
    fov = 70,
}

local connections = {}
local highlights = {}
local oldLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
}

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Vitesse / saut appliqués en continu
table.insert(connections, RunService.Heartbeat:Connect(function()
    local hum = getHumanoid()
    if hum then
        if state.speedOn then
            hum.WalkSpeed = state.speed
        end
        if state.jumpOn then
            hum.UseJumpPower = true
            hum.JumpPower = state.jump
        end
    end
    local camera = workspace.CurrentCamera
    if camera then
        camera.FieldOfView = state.fov
    end
end))

-- Saut infini
table.insert(connections, UserInputService.JumpRequest:Connect(function()
    if state.infJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- ESP : contour autour des autres joueurs
local function clearEsp()
    for _, item in pairs(highlights) do
        pcall(function() item:Destroy() end)
    end
    table.clear(highlights)
end

local function refreshEsp()
    for player, item in pairs(highlights) do
        if not player.Parent or not player.Character or item.Parent ~= player.Character then
            pcall(function() item:Destroy() end)
            highlights[player] = nil
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and not highlights[player] then
            local item = Instance.new("Highlight")
            item.FillColor = Color3.fromRGB(255, 255, 255)
            item.FillTransparency = 0.6
            item.OutlineColor = Color3.fromRGB(255, 255, 255)
            item.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            item.Parent = player.Character
            highlights[player] = item
        end
    end
end

task.spawn(function()
    while _G.MonHubPanel and not _G.MonHubPanel.Dead do
        if state.esp then
            pcall(refreshEsp)
        end
        task.wait(1)
    end
end)

-- Lumière max
local function setFullbright(on)
    if on then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = oldLighting.Brightness
        Lighting.ClockTime = oldLighting.ClockTime
        Lighting.GlobalShadows = oldLighting.GlobalShadows
        Lighting.Ambient = oldLighting.Ambient
    end
end

-- Fenêtre
local Window = Slate:CreateWindow({
    Name = "MM2 Panel",
    Subtitle = "options",
    Icon = "zap",
    Logo = true,
    Size = UDim2.fromOffset(560, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    Launcher = false,
})
if not Window then
    warn("[mm2] impossible de créer la fenêtre")
    return
end

pcall(function() Slate.Theme.Preset("Ash") end)

local function cleanup()
    _G.MonHubPanel.Dead = true
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(connections)
    clearEsp()
    setFullbright(false)
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    local camera = workspace.CurrentCamera
    if camera then
        camera.FieldOfView = 70
    end
end
_G.MonHubPanel.Cleanup = cleanup
Window.Closed:Connect(cleanup)

local Tab = Window:CreateTab({ Name = "Joueur", Icon = "user" })

local move = Tab:CreateSection({ Name = "Mouvement" })
move:Toggle({
    Name = "Vitesse personnalisée",
    Default = false,
    Callback = function(value)
        state.speedOn = value
        if not value then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})
move:Slider({
    Name = "Vitesse",
    Min = 16, Max = 100, Default = 16, Step = 1,
    Callback = function(value) state.speed = value end,
})
move:Toggle({
    Name = "Saut personnalisé",
    Default = false,
    Callback = function(value)
        state.jumpOn = value
        if not value then
            local hum = getHumanoid()
            if hum then hum.JumpPower = 50 end
        end
    end,
})
move:Slider({
    Name = "Hauteur de saut",
    Min = 50, Max = 200, Default = 50, Step = 1,
    Callback = function(value) state.jump = value end,
})
move:Toggle({
    Name = "Saut infini",
    Default = false,
    Callback = function(value) state.infJump = value end,
})

local visual = Tab:CreateSection({ Name = "Visuel" })
visual:Toggle({
    Name = "Contour des joueurs",
    Default = false,
    Callback = function(value)
        state.esp = value
        if value then
            pcall(refreshEsp)
        else
            clearEsp()
        end
    end,
})
visual:Toggle({
    Name = "Lumière max",
    Default = false,
    Callback = function(value)
        state.fullbright = value
        setFullbright(value)
    end,
})
visual:Slider({
    Name = "Champ de vision (FOV)",
    Min = 50, Max = 120, Default = 70, Step = 1,
    Callback = function(value) state.fov = value end,
})

local menu = Tab:CreateSection({ Name = "Menu" })
menu:Button({
    Name = "Fermer ce panneau",
    Icon = "x",
    Callback = function()
        pcall(function() Window:Destroy() end)
    end,
})

Slate:Notify({
    Title = "MM2 Panel",
    Description = "Panneau chargé. Touche Shift droit pour l'afficher ou le cacher.",
    Type = "Success",
    Duration = 6,
})
