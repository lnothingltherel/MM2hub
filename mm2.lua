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
    flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBG.P = 1e4
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root
    hum.PlatformStand = true
end

----------------------------------------------------------------
-- Lumière
----------------------------------------------------------------
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

local function setNoFog(on)
    Lighting.FogEnd = on and 1e6 or oldLighting.FogEnd
end

----------------------------------------------------------------
-- Boucles
----------------------------------------------------------------
table.insert(connections, RunService.Heartbeat:Connect(function()
    local hum = getHumanoid()
    if hum then
        if state.speedOn then hum.WalkSpeed = state.speed end
        if state.jumpOn then
            hum.UseJumpPower = true
            hum.JumpPower = state.jump
        end
    end

    local camera = workspace.CurrentCamera
    if camera and state.fovOn then
        camera.FieldOfView = state.fov
    end

    if state.fly then
        local root = getRoot()
        if root and camera then
            if not flyBV or not flyBV.Parent then startFly() end
            if flyBV and flyBG then
                local dir = Vector3.zero
                local cf = camera.CFrame
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
                flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * state.flySpeed or Vector3.zero
                flyBG.CFrame = cf
            end
        end
    end
end))

table.insert(connections, RunService.Stepped:Connect(function()
    if state.noclip then
        local char = getChar()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end))

table.insert(connections, UserInputService.JumpRequest:Connect(function()
    if state.infJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

table.insert(connections, LocalPlayer.Idled:Connect(function()
    if state.antiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

table.insert(connections, Players.PlayerRemoving:Connect(removeEsp))

task.spawn(function()
    while _G.MonHubPanel and not _G.MonHubPanel.Dead do
        if state.esp then pcall(refreshEsp) end
        if state.gunEsp then pcall(refreshGun) end
        task.wait(0.5)
    end
end)

----------------------------------------------------------------
-- Fenêtre
----------------------------------------------------------------
local Window = Slate:CreateWindow({
    Name = "MM2 Panel",
    Subtitle = "panneau complet",
    Icon = "zap",
    Logo = true,
    Size = UDim2.fromOffset(620, 430),
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
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    table.clear(connections)
    state.fly = false
    stopFly()
    clearEsp()
    clearGun()
    setFullbright(false)
    setNoFog(false)
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    local camera = workspace.CurrentCamera
    if camera then camera.FieldOfView = 70 end
end
_G.MonHubPanel.Cleanup = cleanup
Window.Closed:Connect(cleanup)

----------------------------------------------------------------
-- Onglet Mouvement
----------------------------------------------------------------
local tabMove = Window:CreateTab({ Name = "Mouvement", Icon = "user" })

local s1 = tabMove:CreateSection({ Name = "Vitesse et saut" })
s1:Toggle({
    Name = "Vitesse personnalisée",
    Callback = function(v)
        state.speedOn = v
        if not v then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})
s1:Slider({ Name = "Vitesse", Min = 16, Max = 120, Default = 16, Step = 1,
    Callback = function(v) state.speed = v end })
s1:Toggle({
    Name = "Saut personnalisé",
    Callback = function(v)
        state.jumpOn = v
        if not v then
            local hum = getHumanoid()
            if hum then hum.JumpPower = 50 end
        end
    end,
})
s1:Slider({ Name = "Hauteur de saut", Min = 50, Max = 250, Default = 50, Step = 1,
    Callback = function(v) state.jump = v end })
s1:Toggle({ Name = "Saut infini", Callback = function(v) state.infJump = v end })

local s2 = tabMove:CreateSection({ Name = "Vol et traversée" })
s2:Toggle({
    Name = "Vol (WASD, Espace, Shift)",
    Callback = function(v)
        state.fly = v
        if v then startFly() else stopFly() end
    end,
})
s2:Slider({ Name = "Vitesse de vol", Min = 20, Max = 200, Default = 60, Step = 5,
    Callback = function(v) state.flySpeed = v end })
s2:Toggle({ Name = "Noclip (traverser les murs)", Callback = function(v) state.noclip = v end })

----------------------------------------------------------------
-- Onglet Visuel
----------------------------------------------------------------
local tabVisual = Window:CreateTab({ Name = "Visuel", Icon = "eye" })

local v1 = tabVisual:CreateSection({ Name = "ESP" })
v1:Toggle({
    Name = "ESP joueurs (rôles en couleur)",
    Callback = function(v)
        state.esp = v
        if v then pcall(refreshEsp) else clearEsp() end
    end,
})
v1:Toggle({
    Name = "Afficher les noms et rôles",
    Default = true,
    Callback = function(v) state.espNames = v end,
})
v1:Toggle({
    Name = "ESP arme tombée",
    Callback = function(v)
        state.gunEsp = v
        if v then pcall(refreshGun) else clearGun() end
    end,
})
v1:Label({ Name = "Rouge = Murderer, Bleu = Sheriff, Vert = Innocent" })

local v2 = tabVisual:CreateSection({ Name = "Environnement" })
v2:Toggle({ Name = "Lumière max", Callback = function(v) state.fullbright = v setFullbright(v) end })
v2:Toggle({ Name = "Supprimer le brouillard", Callback = function(v) state.noFog = v setNoFog(v) end })
v2:Toggle({
    Name = "Champ de vision personnalisé",
    Callback = function(v)
        state.fovOn = v
        if not v then
            local camera = workspace.CurrentCamera
            if camera then camera.FieldOfView = 70 end
        end
    end,
})
v2:Slider({ Name = "FOV", Min = 50, Max = 120, Default = 70, Step = 1,
    Callback = function(v) state.fov = v end })

----------------------------------------------------------------
-- Onglet Joueurs
----------------------------------------------------------------
local tabPlayers = Window:CreateTab({ Name = "Joueurs", Icon = "users" })

local selected
local function playerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    table.sort(names)
    return names
end

local p1 = tabPlayers:CreateSection({ Name = "Téléportation" })
local dropdown = p1:Dropdown({
    Name = "Joueur",
    Options = playerNames(),
    Placeholder = "Choisir un joueur",
    Callback = function(v) selected = v end,
})
p1:Button({
    Name = "Actualiser la liste",
    Icon = "refresh-cw",
    Callback = function()
        pcall(function() dropdown:SetOptions(playerNames()) end)
    end,
})
p1:Button({
    Name = "Se téléporter au joueur",
    Icon = "map-pin",
    Callback = function()
        local target = selected and Players:FindFirstChild(selected)
        local tRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        local root = getRoot()
        if tRoot and root then
            root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
        else
            Slate:Notify({ Title = "Joueurs", Description = "Joueur introuvable.", Type = "Warning", Duration = 4 })
        end
    end,
})

local p2 = tabPlayers:CreateSection({ Name = "Rôles de la manche" })
p2:Button({
    Name = "Afficher les rôles",
    Icon = "search",
    Callback = function()
        local murderer, sheriff = "inconnu", "inconnu"
        for _, p in ipairs(Players:GetPlayers()) do
            local role = getRole(p)
            if role == "Murderer" then murderer = p.DisplayName end
            if role == "Sheriff" then sheriff = p.DisplayName end
        end
        Slate:Notify({
            Title = "Rôles",
            Description = "Murderer : " .. murderer .. " | Sheriff : " .. sheriff,
            Type = "Info",
            Duration = 8,
        })
    end,
})

----------------------------------------------------------------
-- Onglet Divers
----------------------------------------------------------------
local tabMisc = Window:CreateTab({ Name = "Divers", Icon = "settings" })

local m1 = tabMisc:CreateSection({ Name = "Utilitaires" })
m1:Toggle({ Name = "Anti-AFK", Default = true, Callback = function(v) state.antiAfk = v end })
m1:Button({
    Name = "Réinitialiser le personnage",
    Icon = "refresh-cw",
    Callback = function()
        local hum = getHumanoid()
        if hum then hum.Health = 0 end
    end,
})
m1:Button({
    Name = "Rejoindre le même jeu",
    Icon = "log-in",
    Callback = function()
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end,
})
m1:Button({
    Name = "Changer de serveur",
    Icon = "globe",
    Callback = function()
        local ok = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId
                .. "/servers/Public?sortOrder=Asc&limit=100"
            local data = HttpService:JSONDecode(game:HttpGet(url))
            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
            error("aucun serveur")
        end)
        if not ok then
            Slate:Notify({ Title = "Serveur", Description = "Aucun autre serveur trouvé.", Type = "Warning", Duration = 5 })
        end
    end,
})

local m2 = tabMisc:CreateSection({ Name = "Menu" })
m2:Button({
    Name = "Fermer ce panneau",
    Icon = "x",
    Callback = function() pcall(function() Window:Destroy() end) end,
})
----------------------------------------------------------------
-- Onglet Shaders + Protection (anti-fling)
----------------------------------------------------------------
local BASE = "https://raw.githubusercontent.com/lnothingltherel/MM2hub/refs/heads/main/"
local okSh, Shaders = pcall(function()
    return loadstring(game:HttpGet(BASE .. "shaders.lua"), "@Shaders")()
end)

local tabShaders = Window:CreateTab({ Name = "Shaders", Icon = "sparkles" })
local shSec = tabShaders:CreateSection({ Name = "Ambiance visuelle" })

if okSh and type(Shaders) == "table" then
    local current = "Doux"
    local enabled = false

    shSec:Dropdown({
        Name = "Preset",
        Options = Shaders.Presets(),
        Default = current,
        Search = false,
        Callback = function(v)
            current = v
            if enabled then Shaders.Apply(current) end
        end,
    })
    shSec:Toggle({
        Name = "Activer les shaders",
        Callback = function(v)
            enabled = v
            if v then Shaders.Apply(current) else Shaders.Clear() end
        end,
    })
    shSec:Button({
        Name = "Retirer tous les effets",
        Icon = "trash-2",
        Callback = function()
            enabled = false
            Shaders.Clear()
        end,
    })
    Window.Closed:Connect(function() pcall(Shaders.Clear) end)
else
    shSec:Label({ Name = "shaders.lua introuvable dans ton dépôt" })
end

local tabProtect = Window:CreateTab({ Name = "Protection", Icon = "shield" })
local prSec = tabProtect:CreateSection({ Name = "Anti-fling" })

local antiFling = false

prSec:Toggle({
    Name = "Anti-fling",
    Callback = function(v) antiFling = v end,
})
prSec:Label({ Name = "Empêche les autres de te projeter dans les airs" })

-- 1) les autres joueurs ne te touchent plus physiquement (chez toi)
table.insert(connections, RunService.Stepped:Connect(function()
    if not antiFling then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end))

-- 2) si ta vitesse devient énorme (signe d'un fling), on la remet à zéro
table.insert(connections, RunService.Heartbeat:Connect(function()
    if not antiFling or state.fly then return end
    local root = getRoot()
    if root then
        if root.AssemblyLinearVelocity.Magnitude > 250
            or root.AssemblyAngularVelocity.Magnitude > 100 then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
end))
Slate:Notify({
    Title = "MM2 Panel",
    Description = "Chargé. Shift droit pour afficher ou cacher.",
    Type = "Success",
    Duration = 6,
})
