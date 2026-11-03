print("[MonHub] démarré | GameId:", game.GameId, "PlaceId:", game.PlaceId)

local BASE = "https://raw.githubusercontent.com/lnothingltherel/MM2hub/refs/heads/main/"
local SLATE_URL = BASE .. "slate.lua"

local MM2 = {
    Key = "mm2",
    Name = "Murder Mystery 2",
    Places = { 142823291 },
    Universe = 66654135,
    Loader = BASE .. "mm2.lua",
}

local function fetch(url, label)
    return pcall(function()
        return loadstring(game:HttpGet(url), "@" .. label)()
    end)
end

local function isMM2()
    if game.GameId == MM2.Universe then return true end
    return table.find(MM2.Places, game.PlaceId) ~= nil
end
local inMM2 = isMM2()

if type(_G.MonHubMM2) == "table" and _G.MonHubMM2.Window then
    pcall(function() _G.MonHubMM2.Window:Destroy() end)
    if _G.MonHubMM2.Shaders then pcall(_G.MonHubMM2.Shaders.Clear) end
end
_G.MonHubMM2 = {}

local okSlate, Slate = fetch(SLATE_URL, "Slate")
if not okSlate or type(Slate) ~= "table" then
    warn("[MonHub] Slate n'a pas pu se charger : " .. tostring(Slate))
    return
end
pcall(function() Slate.Cleanup() end)
pcall(function() Slate:PreloadIcons({ "lucide" }) end)

local Window = Slate:CreateWindow({
    Name = "MonHub",
    Subtitle = inMM2 and "Murder Mystery 2" or "Jeu non supporté",
    Icon = "zap",
    Logo = true,
    Size = UDim2.fromOffset(640, 420),
    ToggleKey = Enum.KeyCode.LeftControl,
    Backdrop = "aurora",
})
if not Window then return end
pcall(function() Slate.Theme.Preset("Violet") end)
_G.MonHubMM2.Window = Window

local function notify(title, desc, kind, icon)
    Slate:Notify({ Title = title, Description = desc, Type = kind or "Info", Icon = icon, Duration = 5 })
end

-- Onglet Scripts
local tabScripts = Window:CreateTab({ Name = "Scripts", Icon = "layout-grid" })

if not inMM2 then
    local warnSec = tabScripts:CreateSection({ Name = "Attention" })
    warnSec:Paragraph({
        Name = "Jeu non supporté",
        Description = "Ce hub est prévu pour Murder Mystery 2. Le script risque de ne pas marcher ici.",
    })
end

local sec = tabScripts:CreateSection({ Name = "Script disponible" })
sec:Card({ Name = "Jeu", Value = MM2.Name, Icon = "gamepad-2", Tone = "Accent" })
sec:Action({
    Name = "Lancer " .. MM2.Name,
    Icon = "play",
    Callback = function()
        notify("MonHub", "Lancement de " .. MM2.Name, "Info", "play")
        task.spawn(function()
            local ok, err = fetch(MM2.Loader, MM2.Key)
            if ok then notify("MonHub", MM2.Name .. " lancé", "Success", "circle-check")
            else notify("MonHub", "Échec : " .. tostring(err), "Error", "circle-alert") end
        end)
    end,
})

-- Onglet Shaders
local tabShaders = Window:CreateTab({ Name = "Shaders", Icon = "sparkles" })
local okSh, Shaders = fetch(BASE .. "shaders.lua", "Shaders")

local shSec = tabShaders:CreateSection({ Name = "Ambiance visuelle" })
if okSh and type(Shaders) == "table" then
    _G.MonHubMM2.Shaders = Shaders
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
        Callback = function() enabled = false Shaders.Clear() notify("Shaders", "Effets retirés", "Info") end,
    })
else
    shSec:Paragraph({
        Name = "Shaders indisponibles",
        Description = "Ajoute shaders.lua à ton dépôt MM2hub.",
    })
end

-- Onglet Infos
local tabInfo = Window:CreateTab({ Name = "Infos", Icon = "info" })
local info = tabInfo:CreateSection({ Name = "Session" })
info:Stat({ Name = "Jeu supporté", Value = inMM2 and "Oui" or "Non" })
info:Stat({ Name = "PlaceId", Value = tostring(game.PlaceId) })
info:Stat({ Name = "Touche menu", Value = "Ctrl gauche" })

local menu = tabInfo:CreateSection({ Name = "Menu" })
menu:Button({
    Name = "Fermer le menu",
    Icon = "x",
    Callback = function()
        if _G.MonHubMM2 and _G.MonHubMM2.Shaders then pcall(_G.MonHubMM2.Shaders.Clear) end
        pcall(function() Window:Destroy() end)
        _G.MonHubMM2 = nil
    end,
})

notify("MonHub", inMM2 and "Hub chargé." or "Pas dans MM2.", inMM2 and "Success" or "Warning")
