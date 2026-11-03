-- MonHub MM2 : tous les fichiers viennent de mon dépôt
print("[MonHub] démarré | GameId:", game.GameId, "PlaceId:", game.PlaceId)

local SLATE_URL = "https://raw.githubusercontent.com/lnothingltherel/MM2hub/refs/heads/main/slate.lua"

local MM2 = {
    Key = "mm2",
    Name = "Murder Mystery 2",
    Places = { 142823291 },
    Universe = 66654135,
    Loader = "https://raw.githubusercontent.com/lnothingltherel/MM2hub/refs/heads/main/mm2.lua",
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

local inMM2 = isMM2()
print("[MonHub] inMM2 =", inMM2)

-- Nettoyage d'une ancienne fenêtre
if type(_G.MonHubMM2) == "table" and _G.MonHubMM2.Window then
    pcall(function()
        _G.MonHubMM2.Window:Destroy()
    end)
end
_G.MonHubMM2 = {}

-- Chargement de Slate
local okSlate, Slate = pcall(function()
    return loadstring(game:HttpGet(SLATE_URL), "@Slate")()
end)
if not okSlate or not Slate then
    warn("[MonHub] Slate n'a pas pu se charger : " .. tostring(Slate))
    return
end
print("[MonHub] Slate chargé")

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
