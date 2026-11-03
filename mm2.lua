-- mm2.lua : panneau MM2 complet (tout vient de mon dépôt)
print("[mm2] chargé")

local SLATE_URL = "https://raw.githubusercontent.com/lnothingltherel/MM2hub/refs/heads/main/slate.lua"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Ferme l'ancien panneau s'il existe
if type(_G.MonHubPanel) == "table" and _G.MonHubPanel.Cleanup then
    pcall(_G.MonHubPanel.Cleanup)
end
_G.MonHubPanel = {}

local okSlate, Slate = pcall(function()
    return loadstring(game:HttpGet(SLATE_URL), "@Slate")()
end)
if not okSlate or type(Slate) ~= "table" then
    warn("[mm2] Slate n'a pas pu se charger : " .. tostring(Slate))
    return
end
pcall(function() Slate:PreloadIcons({ "lucide" }) end)

----------------------------------------------------------------
-- État
----------------------------------------------------------------
local state = {
    speedOn = false, speed = 16,
    jumpOn = false, jump = 50,
    infJump = false,
    noclip = false,
    fly = false, flySpeed = 60,
    esp = false, espNames = true,
    gunEsp = false,
    fullbright = false,
    noFog = false,
    fov = 70, fovOn = false,
    antiAfk = true,
}

local connections = {}
local espObjects = {}
local gunHighlight
local flyBV, flyBG

local oldLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    FogEnd = Lighting.FogEnd,
}

local function getChar() return LocalPlayer.Character end
local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

----------------------------------------------------------------
-- Rôles MM2 (visibles une fois la manche lancée)
----------------------------------------------------------------
local function hasTool(player, name)
    if player.Character and player.Character:FindFirstChild(name) then return true end
    if player.Backpack and player.Backpack:FindFirstChild(name) then return true end
    return false
end

local function getRole(player)
    if hasTool(player, "Knife") then return "Murderer" end
    if hasTool(player, "Gun") then return "Sheriff" end
    return "Innocent"
end

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff = Color3.fromRGB(70, 140, 255),
    Innocent = Color3.fromRGB(80, 220, 120),
}

----------------------------------------------------------------
-- ESP joueurs
----------------------------------------------------------------
local function removeEsp(player)
    local entry = espObjects[player]
    if entry then
        pcall(function() entry.hl:Destroy() end)
        pcall(function() entry.gui:Destroy() end)
        espObjects[player] = nil
    end
end

local function clearEsp()
    for player in pairs(espObjects) do
        removeEsp(player)
    end
end

local function refreshEsp()
    for player, entry in pairs(espObjects) do
        if not player.Parent or not player.Character or entry.hl.Parent ~= player.Character then
            removeEsp(player)
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        if player ~= LocalPlayer and char and head then
            local entry = espObjects[player]
            if not entry then
                local hl = Instance.new("Highlight")
                hl.FillTransparency = 0.55
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char

                local gui = Instance.new("BillboardGui")
                gui.Size = UDim2.fromOffset(140, 20)
                gui.StudsOffset = Vector3.new(0, 2.6, 0)
                gui.AlwaysOnTop = true
                gui.Adornee = head
                gui.Parent = head

                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Size = UDim2.fromScale(1, 1)
                label.Font = Enum.Font.GothamBold
                label.TextSize = 13
                label.TextStrokeTransparency = 0.4
                label.Parent = gui

                entry = { hl = hl, gui = gui, label = label }
                espObjects[player] = entry
            end
            local role = getRole(player)
            local color = ROLE_COLORS[role]
            entry.hl.FillColor = color
            entry.hl.OutlineColor = color
            entry.label.TextColor3 = color
            entry.label.Text = player.DisplayName .. " [" .. role .. "]"
            entry.gui.Enabled = state.espNames
        end
    end
end

----------------------------------------------------------------
-- ESP arme tombée
----------------------------------------------------------------
local function refreshGun()
    local drop = workspace:FindFirstChild("GunDrop", true)
    if drop and (not gunHighlight or gunHighlight.Parent ~= drop) then
        if gunHighlight then pcall(function() gunHighlight:Destroy() end) end
        gunHighlight = Instance.new("Highlight")
        gunHighlight.FillColor = Color3.fromRGB(255, 220, 60)
        gunHighlight.OutlineColor = Color3.fromRGB(255, 220, 60)
        gunHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        gunHighlight.Parent = drop
    elseif not drop and gunHighlight then
        pcall(function() gunHighlight:Destroy() end)
        gunHighlight = nil
    end
end

local function clearGun()
    if gunHighlight then
        pcall(function() gunHighlight:Destroy() end)
        gunHighlight = nil
    end
end

----------------------------------------------------------------
-- Vol
----------------------------------------------------------------
local function stopFly()
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
end

local function startFly()
    local root, hum = getRoot(), getHumanoid()
    if not root or not hum then return end
    stopFly()
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque =
