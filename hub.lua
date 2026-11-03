-- MonHub MM2 (structure inspirée de Pulse Hub)
print("[MonHub] démarré | GameId:", game.GameId, "PlaceId:", game.PlaceId)

local SLATE_URL = "https://raw.githubusercontent.com/PulseZax/Slate/refs/heads/main/.lua"

local MM2 = {
    Key = "mm2",
    Name = "Murder Mystery 2",
    Places = { 142823291 },
    Universe = 66654135,
    -- COLLE ICI TON LIEN RAW DE mm2.lua
    Loader = "https://raw.githubusercontent.com/lnothingltherel/MM2hub/refs/heads/main/mm2.lua",
    Tone = Color3.fromRGB(214, 68, 88),
}

local function isMM2()
    if game.GameId == MM2.Universe then
        return true
    end
    for _, id in ipairs(MM2.Places) do
        if id == game.PlaceId then
            return true
        end
    end
    return false
end

local function launch()
    return pcall(function()
        return loadstring(game:HttpGet(MM2.Loader), "@" .. MM2.Key)()
    end)
end

-- Dans MM2 : lancement direct, sans fenêtre
if isMM2() then
    local ok, err = launch()
    if not ok then
        warn("[MonHub] " .. MM2.Name .. " a échoué : " .. tostring(err))
    end
    return
end

-- Ailleurs : on affiche la fenêtre
if type(_G.MonHubMM2) == "table" then
    pcall(function()
        _G.MonHubMM2.Window:Destroy()
    end)
end
_G.MonHubMM2 = {}

local okSlate, Slate = pcall(function()
    return loadstring(game:HttpGet(SLATE_URL), "@Slate")()
end)
if not okSlate or not Slate then
    warn("[MonHub] Slate n'a pas pu se charger : " .. tostring(Slate))
    return
end

pcall(function() Slate.Cleanup() end)
pcall(function() Slate:PreloadIcons({ "lucide" }) end)

local Window = Slate:CreateWindow({
    Name = "MonHub",
    Subtitle = "MM2 loader",
    Icon = "zap",
    Logo = true,
    Size = UDim2.fromOffset(560, 380),
    ToggleKey = Enum.KeyCode.LeftControl,
})

pcall(function() Slate.Theme.Preset("Ash") end)
pcall(function() Window:SetBackdrop("aurora") end)

_G.MonHubMM2.Window = Window

local Tab = Window:CreateTab({ Name = "Scripts", Icon = "layout-grid" })

local placeName = "ce jeu"
pcall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if info and info.Name then
        placeName = info.Name
    end
end)

do
    local notice = Tab:CreateSection({ Name = "Jeu non supporté" })
    notice:Paragraph({
        Name = "Tu es dans : " .. placeName,
        Description = "Ce hub est fait pour Murder Mystery 2. Le script risque de ne pas marcher ici.",
    })
end

do
    local list = Tab:CreateSection({ Name = "Script disponible" })
    list:Button({
        Name = "Lancer " .. MM2.Name,
        Icon = "play",
        Callback = function()
            Slate:Notify({
                Title = "MonHub",
                Description = "Lancement de " .. MM2.Name,
                Icon = "play",
                Duration = 5,
            })
            task.spawn(function()
                local finished, ok, err = false, nil, nil
                task.spawn(function()
                    ok, err = launch()
                    finished = true
                end)
                local waited = 0
                while not finished and waited < 6 do
                    task.wait(0.25)
                    waited += 0.25
                end
                if not finished then
                    Slate:Notify({
                        Title = "MonHub",
                        Description = MM2.Name .. " met du temps à répondre",
                        Icon = "triangle-alert",
                        Tone = "Warning",
                        Duration = 10,
                    })
                elseif not ok then
                    Slate:Notify({
                        Title = "MonHub",
                        Description = "Échec : " .. tostring(err),
                        Icon = "circle-alert",
                        Tone = "Danger",
                        Duration = 10,
                    })
                else
                    Slate:Notify({
                        Title = "MonHub",
                        Description = MM2.Name .. " lancé",
                        Icon = "circle-check",
                        Tone = "Success",
                        Duration = 8,
                    })
                end
            end)
        end,
    })
end

do
    local close = Tab:CreateSection({ Name = "Menu" })
    close:Button({
        Name = "Fermer le menu",
        Icon = "x",
        Callback = function()
            pcall(function() Window:Destroy() end)
            _G.MonHubMM2 = nil
        end,
    })
end

Slate:Notify({
    Title = "MonHub",
    Description = "Pas dans MM2. Clique sur Lancer pour l'exécuter quand même.",
    Icon = "triangle-alert",
    Tone = "Warning",
    Duration = 10,
})
