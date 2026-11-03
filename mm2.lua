--[[
>info of this Mm2 Script<
So this script make for testing and example for some function of part for beginner or even advanced,
This is Open source Script is free to modify or edit and you guys don't need to give me credit for this work too even if you steal it or you are skid so I will anyway don't care
___________
I only learn Lua for 2-3 years and have some other knowledge like Luau, LuaJit, Lua FiveM and some other,
forgot to say that I'm only just 15 year old
___________
This Mm2 Script is just a simple code and function and I don't have some ideas too so I only make just a simple function and thank you for use this open source script, Thanks for support <3
-- https://github.com/Backlostunking/Open-Source/tree/main
--> free webhooks script: https://github.com/Backlostunking/Open-Source/blob/main/Webhooks
Enjoy using this open source script and my discord username: scriptermrbacon
]]
--[[
ignore free Hidden properties
-- on everywhere (I think):
RobloxLocked,
FindFirstDescendant, FindFirstAncestor, FindFirstAncestorOfClass, FindFirstAncestorWhichIsA
-- on Player only (Not Service Players):
SetAccountAge,
GetNetworkPing,
SetMembershipType,
SimulationRadius,
MaxSimulationRadius,
MaximumSimulationRadius,
SimulationRadiusChanged,
AddReplicationFocus,
AddReplicationFocusPosition,
RemoveReplicationFocus,
RemoveReplicationFocusPosition,
ScriptSecurityError,
Guest,
IsFriendsWith, isFriendsWith, IsBestFriendsWith, GetFriendStatus, GetFriendsOnline, FriendStatusChanged, RemoteFriendRequestSignal, RequestFriendship, RevokeFriendship
--DM me on discord if you need more
]]
--[[
Free cloneref script project by ScripterMrbacon
This for some advanced exploit who need this function for some executor that don't have function cloneref in environment (don't support cloneref function if say as understand)
local cloneref = function(instance)
	if typeof(instance) ~= "Instance" then return instance end
	local proxy = newproxy(true)
	local mt = getmetatable(proxy)
	local function safeCall(func, ...)
		local ok, result = pcall(func, ...)
		return ok and result or nil
	end
	mt.__index = function(_, key)
		local value = safeCall(function() return instance[key] end)
		if typeof(value) == "function" then
			return function(_, ...) return instance[key](instance, ...) end
		end
		return value
	end
	mt.__newindex = function(_, key, value)
		safeCall(function() instance[key] = value end)
	end
	mt.__tostring = function()
		return instance:GetFullName()
	end
	mt.__metatable = "cloneref_protected"
	mt.__eq = function(_, other) return other == instance end
	mt.__call = function(_, ...) return instance(...) end
	return proxy
end
local Players = cloneref(game:GetService("Players"))
print(Players)
print(Players.LocalPlayer.Name) -- work even call a method/function or use method
--Players.LocalPlayer:Kick() -- work
--Players.LocalPlayer.Backpack:Destroy() -- Work on Child too and call a method/function to remove it as work like normal
-- I hope you guys like this function that I make for 8 minutes
]]
-- free tutorial of Lua:
--[[
Example: Using the `do` keyword to create a block scope

The `do` keyword starts a new block of code.  
Any variables declared inside this block using `local`  
will only exist inside that block.

Example:
do -- Start a new scope block
	local variable = "string" -- This variable only exists inside here
	print(variable) -- Output: "string"
end -- End of block

print(variable) -- Output: nil (variable is not accessible outside the block)
]]
--[[
My Tip for chaining variables and conditions in Lua:

Lua checks values **from left to right**, stopping at the first `false` or `nil`.
This is useful for checking multiple conditions in one line:

Example:
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
print(Root) -- Output: HumanoidRootPart

Explanation:
1. Lua checks if `LocalPlayer.Character` exists.
2. If it's not nil, it continues to `FindFirstChild("HumanoidRootPart")`.
3. If both exist, it sets `Root` to the part.
If any part of the chain is nil, the result will be nil (no error).
]]
--game:SetIsLoaded(true) > boolean true/false
--game:Load() -- maybe make the game Load
if not game:IsLoaded() then
local s = pcall(function()
game.Loaded:Wait()
end)
if not s then repeat task.wait() until game:IsLoaded() end
end
if game.PlaceId ~= 142823291 then return end -- only one game support ahh script
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Backlostunking/ScriptLua/refs/heads/main/Orion-GB-V2.Lua"))()
local executor = identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "Unknow"
local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local Window = OrionLib:MakeWindow({IntroText = "Script Made By ScripterMrbacon",IntroIcon = "rbxassetid://7733955511",Name = ("SourceHub • "..GameName.." ✓ Executor "..executor),IntroToggleIcon = "rbxassetid://4335489011",HidePremium = false,SaveConfig = false,IntroEnabled = true,ConfigFolder = "Mm2SHub"})
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local PlayerTab = Window:MakeTab({Name = "Local", Icon = "rbxassetid://4335489011", PremiumOnly = false})
local env = getgenv and getgenv() or getrenv and getrenv() or getfenv and getfenv(0) or _G
local cloneref = cloneref or (function()
local s, func = pcall(function()
return loadstring(game:HttpGet("https://raw.githubusercontent.com/Backlostunking/Open-Source/refs/heads/main/cloneref-TheCloneVM"))()
end)
return s and func or function(s) return s end
end)()
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Tween = cloneref(game:GetService("TweenService"))
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() -- should clone this localplayer method if the game have anticlient modified
local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack")
local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() --and LocalPlayer.CharacterAppearanceLoaded:Wait()
local Hum = Char and Char:FindFirstChildWhichIsA("Humanoid")
local Root = (Hum and Hum.RootPart) or Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("Torso") or Char:FindFirstChild("UpperTorso")
LocalPlayer.CharacterAdded:Connect(function()
	repeat task.wait()
	LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack")
    Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Hum = Char and Char:FindFirstChildWhichIsA("Humanoid")
    Root = (Hum and Hum.RootPart) or Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("Torso") or Char:FindFirstChild("UpperTorso")
until LocalPlayer and backpack and Char and Hum and Root
end)
local function SHubFling(TargetPlayer)
    if not (Char and Hum and Root) then return end
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    env.OldPos = Root.CFrame
     repeat task.wait()
    Workspace.CurrentCamera.CameraSubject = THead or Handle or THumanoid
     until Workspace.CurrentCamera.CameraSubject == THead or Handle or THumanoid
    local function FPos(BasePart, Pos, Ang)
        local targetCF = CFrame.new(BasePart.Position) * Pos * Ang
        Root.CFrame = targetCF
        Char:SetPrimaryPartCFrame(targetCF)
        Root.Velocity = Vector3.new(9e7, 9e8, 9e7)
        Root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end
    local function SFBasePart(BasePart)
        local start = tick()
        local angle = 0
        env.timeout = env.timeout or 2.5
        repeat
            if Root and THumanoid then
                angle += 100
                for _, offset in ipairs{CFrame.new(0, 1.5, 0),CFrame.new(0, -1.5, 0),CFrame.new(2.25, 1.5, -2.25),CFrame.new(-2.25, -1.5, 2.25)} do
                    FPos(BasePart, offset + THumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                end
            end
        until BasePart.Velocity.Magnitude > 500 or tick() - start > env.timeout
    end
    --Workspace.FallenPartsDestroyHeight = 1000
    local BV = Instance.new("BodyVelocity")
    BV.Name = "SeYyyVel!?"
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BV.Parent = Root
    Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    local target = TRootPart or THead or Handle
    if target then SFBasePart(target) end
    BV:Destroy()
   Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
   repeat task.wait()
    Workspace.CurrentCamera.CameraSubject = Hum
   until Workspace.CurrentCamera.CameraSubject == Hum
    repeat
        local cf = env.OldPos * CFrame.new(0, .5, 0)
        Root.CFrame = cf
        Char:SetPrimaryPartCFrame(cf)
        Hum:ChangeState("GettingUp")
        for _, part in ipairs(Char:GetChildren()) do
            if part:IsA("BasePart") then
                part.Velocity, part.RotVelocity = Vector3.zero, Vector3.zero
            end
        end
        task.wait()
    until (Root.Position - env.OldPos.p).Magnitude < 25
end
local function getRoles()
    local data = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    local roles = {}
    for plr, plrData in pairs(data) do
         if not plrData.Dead then
        roles[plr] = plrData.Role
     end
    end
    return roles
end
MainTab:AddToggle({
	Name = "Esp Player (Role&Name)",
	Default = false,
	Callback = function(Value)
env.ESP_ENABLED = Value
local updateLoop = nil
local roleColors = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Hero = Color3.fromRGB(255, 255, 0),
    Innocent = Color3.fromRGB(0, 255, 0),
    Default = Color3.fromRGB(200, 200, 200)
}
local function clearESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local esp = head:FindFirstChild("RoleESP")
                if esp then esp:Destroy() end
            end
            local hl = player.Character:FindFirstChild("RoleHighlight")
            if hl then hl:Destroy() end
        end
    end
end
local function applyHighlight(character, role)
    local existing = character:FindFirstChild("RoleHighlight")
    if existing then existing:Destroy() end
    local hl = Instance.new("Highlight")
    hl.Name = "RoleHighlight"
    hl.FillColor = roleColors[role] or roleColors.Default
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.Parent = character
end
local function createBillboard(head, role, playerName)
    local esp = Instance.new("BillboardGui")
    esp.Name = "RoleESP"
    esp.Adornee = head
    esp.Size = UDim2.new(5, 0, 5, 0)
    esp.AlwaysOnTop = true
    esp.Parent = head
    local label = Instance.new("TextLabel")
    label.Name = "RoleLabel"
    label.Parent = esp
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.TextColor3 = roleColors[role] or roleColors.Default
    label.Font = Enum.Font.FredokaOne
    label.Text = ("Role: %s • Name: %s"):format(role, playerName)
-- Example: If you don't know what this means
-- The () around the string allow us to immediately call a string method (like :format, :match, etc).
-- It works the same as writing:
-- string.format("Role: %s • Name: %s", role, playerName)
-- But this version is cleaner and faster to type (I think)
end
local function updateESP()
    local roles = getRoles()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local role = roles[player.Name] or "Default"
                if not head:FindFirstChild("RoleESP") then
                    createBillboard(head, role, player.Name)
                else
                    local label = head.RoleESP:FindFirstChild("RoleLabel")
                    if label then
                        label.Text = ("Role: %s • Name: %s"):format(role, player.Name)
                        label.TextColor3 = roleColors[role] or roleColors.Default
                    end
                end
              local light = player.Character:FindFirstChild("RoleHighlight")
              if not light then
                applyHighlight(player.Character, role)
                 else
                 light.FillColor = roleColors[role] or roleColors.Default
                end
            end
        end
    end
end
local function startESP()
    if updateLoop then return end
    updateLoop = task.spawn(function()
        while env.ESP_ENABLED do
            pcall(updateESP)
            task.wait(0.25)
        end
        clearESP()
        updateLoop = nil
    end)
end
if Value then
        startESP()
    else
        clearESP()
    end
end
})
MainTab:AddToggle({
	Name = "Esp Gun",
	Default = false,
	Callback = function(Value)
env.GunEsp = Value
local gun = Workspace:FindFirstChild("GunDrop", true)
if not env.GunEsp then
if gun then
if gun:FindFirstChild("GunHighlight") then
gun:FindFirstChild("GunHighlight"):Destroy()
end
if gun:FindFirstChild("GunEsp") then
gun:FindFirstChild("GunEsp"):Destroy()
end
end
end
while env.GunEsp do
gun = Workspace:FindFirstChild("GunDrop", true)
if gun then
if not gun:FindFirstChild("GunHighlight") then
    local gunh = Instance.new("Highlight", gun)
    gunh.Name = "GunHighlight"
    gunh.FillColor = Color3.new(1, 1, 0)
    gunh.OutlineColor = Color3.new(1, 1, 1)
    gunh.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    gunh.FillTransparency = 0.4
    gunh.OutlineTransparency = 0.5
end
    if not gun:FindFirstChild("GunEsp") then
        local esp = Instance.new("BillboardGui")
        esp.Name = "GunEsp"
        esp.Adornee = gun
        esp.Size = UDim2.new(5, 0, 5, 0)
        esp.AlwaysOnTop = true
        esp.Parent = gun
        local text = Instance.new("TextLabel", esp)
        text.Name = "GunLabel"
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextStrokeTransparency = 0
        text.TextColor3 = Color3.fromRGB(255, 255, 0)
        text.Font = Enum.Font.FredokaOne
        text.TextSize = 16
        text.Text = "Gun Drop"
    end
end
task.wait(0.1)
end
	end    
})
MainTab:AddButton({
	Name = "Grab Gun",
	Callback = function()
if Char and Char ~= nil and Root then
local gun = Workspace:FindFirstChild("GunDrop",true)
if gun then
if firetouchinterest then
firetouchinterest(Root, gun, 0)
firetouchinterest(Root, gun, 1)
else
gun.CFrame = Root.CFrame
end
end
end
  	end    
})
MainTab:AddToggle({
	Name = "Auto Grab Gun",
	Default = false,
	Callback = function(Value)
env.AGG = Value
while env.AGG do
if Char and Char ~= nil and Root then
gun = Workspace:FindFirstChild("GunDrop",true)
 if gun then
if firetouchinterest then
firetouchinterest(Root, gun, 0)
firetouchinterest(Root, gun, 1)
else
gun.CFrame = Root.CFrame
end
end
end
task.wait(0.1)
end
	end    
})
MainTab:AddButton({
	Name = "Steal Gun (From Sheriff&Hero)",
	Callback = function()
if Char and Char ~= nil and Hum and backpack then
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer then
if p.Character and p.Character:FindFirstChild("Gun") then
p.Character:FindFirstChild("Gun").Parent = Char
Hum:EquipTool(Char:FindFirstChild("Gun"))
Hum:UnequipTools()
elseif p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun") then
p.Backpack:FindFirstChild("Gun").Parent = backpack
Hum:EquipTool(backpack:FindFirstChild("Gun"))
Hum:UnequipTools()
end
end
end
end
  	end    
})
local function getMurdererTarget()
local data = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
for plr, plrData in pairs(data) do
if plrData.Role == "Murderer" then
local player = Players:FindFirstChild(plr)
if player then
if player == LocalPlayer then return nil, true end
local char = player.Character
if char then
local hrp = char:FindFirstChild("HumanoidRootPart")
if hrp then return hrp.Position, false end
local head = char:FindFirstChild("Head")
if head then return head.Position, false end
end
end
end
end
return nil, false
end
MainTab:AddToggle({
	Name = "Shoot Murder Button",
	Default = false,
	Callback = function(Value)
local guip, CoreGui = nil, game:FindService("CoreGui")
if gethui then
guip = gethui()
elseif CoreGui and CoreGui:FindFirstChild("RobloxGui") then
guip = CoreGui.RobloxGui
elseif CoreGui then
guip = CoreGui
else
guip = LocalPlayer:FindFirstChild("PlayerGui")
end
 if Value then
if not guip:FindFirstChild("GunW") then
local GunGui = Instance.new("ScreenGui", guip)
GunGui.Name = "GunW"
local TextButton = Instance.new("TextButton", GunGui)
TextButton.Draggable = true
TextButton.Position = UDim2.new(0.5, 187, 0.5, -176)
TextButton.Size = UDim2.new(0, 50, 0, 40)
TextButton.TextStrokeTransparency = 0
TextButton.BackgroundTransparency = 0.2
TextButton.BackgroundColor3 = Color3.fromRGB(44, 44, 45)
TextButton.BorderColor3 = Color3.new(1, 1, 1)
TextButton.Text = "Shoot Murder"
TextButton.TextColor3 = Color3.new(1, 1, 1)
TextButton.TextSize = 8
TextButton.Visible = true
TextButton.AnchorPoint = Vector2.new(0.4, 0.2)
TextButton.Active = true
TextButton.TextWrapped = true
local corner = Instance.new("UICorner", TextButton)
local UIStroke = Instance.new("UIStroke", TextButton)
UIStroke.Color = Color3.new(0, 0, 0)
UIStroke.Thickness = 4
UIStroke.Transparency = 0.4
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint", TextButton)
UIAspectRatioConstraint.AspectRatio = 1.5
local UIGradient = Instance.new("UIGradient", TextButton)
UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(0.3, 0.3, 0.3)),ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))}
    local function rotateGradient()
    local tween = Tween:Create(UIGradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = UIGradient.Rotation + 360})
    tween:Play()
    tween.Completed:Connect(rotateGradient)
end
rotateGradient()
TextButton.MouseButton1Click:Connect(function()
if Char:FindFirstChild("Gun") then
pcall(function()
Char.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1, (getMurdererTarget()), "AH2")
end)
end
end)
end
else
if guip:FindFirstChild("GunW") then
guip:FindFirstChild("GunW"):Destroy()
end
end
	end    
})
local function check()
	local success, hookFunc = false, nil
        if not getnamecallmethod or not checkcaller then return success end
	local mt = getrawmetatable and getrawmetatable(game) or debug.getmetatable and debug.getmetatable(game)
	local function handleNamecall(self, ...)
		local method = getnamecallmethod and getnamecallmethod()
		local args = {...}
		if not checkcaller() then
			if method == "InvokeServer" and tostring(self) == "RemoteFunction" and env.enabledGunBot then
				return nil
			end
		end
		return hookFunc(self, unpack(args))
	end
	if hookmetamethod and newcclosure then
		hookFunc = hookmetamethod(game, "__namecall", newcclosure(handleNamecall))
		success = true
	elseif mt and setreadonly and newcclosure then
		setreadonly(mt, false)
		hookFunc = mt.__namecall
		mt.__namecall = newcclosure(handleNamecall)
		setreadonly(mt, true)
		success = true
	elseif hookmetamethod then
		hookFunc = hookmetamethod(game, "__namecall", handleNamecall)
		success = true
	elseif mt and setreadonly then
		setreadonly(mt, false)
		hookFunc = mt.__namecall
		mt.__namecall = handleNamecall
		setreadonly(mt, true)
		success = true
	elseif mt and (makewriteable or make_writeable) then
		(makewriteable or make_writeable)(mt)
		hookFunc = mt.__namecall
		mt.__namecall = handleNamecall
		success = true
	end
	return success
end
local isUseHook = check()
local AimbotMem = MainTab:AddToggle({
	Name = "Gun Aimbot",
	Default = false,
	Callback = function(Value)
if isUseHook then
env.enabledGunBot = Value
env.GunBotConnection = env.GunBotConnection or {}
local function setupGunBot(character)
	if not character then return end
	local gun = character:FindFirstChild("Gun")
	if not gun then
		if env.GunBotConnection.Connection then
			env.GunBotConnection.Connection:Disconnect()
			env.GunBotConnection.Connection = nil
		end
		return
	end
	local knifeScript = gun:FindFirstChild("KnifeLocal")
	local cb = knifeScript and knifeScript:FindFirstChild("CreateBeam")
	local remote = cb and cb:FindFirstChild("RemoteFunction")
	if not knifeScript or not cb or not remote then return end
	if env.enabledGunBot then
		if env.GunBotConnection.Connection then
			env.GunBotConnection.Connection:Disconnect()
			env.GunBotConnection.Connection = nil
		end
		env.GunBotConnection.Connection = gun.Activated:Connect(function()
			local targetPos, isSelf = getMurdererTarget()
			if not targetPos or isSelf or not remote then return end
			remote:InvokeServer(1, targetPos, "AH2")
		end)
	else
		if env.GunBotConnection.Connection then
			env.GunBotConnection.Connection:Disconnect()
			env.GunBotConnection.Connection = nil
		end
	end
end
while env.enabledGunBot do
	if Char and Char:FindFirstChild("Gun") then
		setupGunBot(Char)
	end
	task.wait(0.25)
end
if not env.enabledGunBot then
	if env.GunBotConnection.Connection then
		env.GunBotConnection.Connection:Disconnect()
		env.GunBotConnection.Connection = nil
	end
end
else
if not env.AsChange then return end
if env.AsChange.Value then
env.AsChange:Set(false)
OrionLib:MakeNotification({Name = "Your Executor Is Not Support This Function",Content = "Sorry, use a better one",Image = "rbxassetid://7733658504",Time = 3})
end
end
	end    
})
env.AsChange = AimbotMem
MainTab:AddToggle({
	Name = "Seconds Life",
	Default = false,
	Callback = function(Value)
local godcon, deathcon
env.enableGodmode = Value
local function IsGodmode()
    return env.enableGodmode
end
local function UpdateGod()
    if godcon then
        godcon:Disconnect()
        godcon = nil
    end
    if Hum then
        godcon = Hum.HealthChanged:Connect(function()
            if IsGodmode() and Hum.Health < Hum.MaxHealth then
                Hum.Health = Hum.MaxHealth
            end
        end)
    end
end
local function OnCharacterAdded(newChar)
    Char = newChar
    Hum = Char:WaitForChild("Humanoid")
    UpdateGod()
end
if deathcon then deathcon:Disconnect() end
deathcon = LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
UpdateGod()
task.spawn(function()
        if not env.enableGodmode then
            if godcon then
                godcon:Disconnect()
                godcon = nil
             end
        else
            if not godcon then
                UpdateGod()
            end
        end
end)
	end    
})
MainTab:AddToggle({
	Name = "Touch Fling",
	Default = false,
	Callback = function(Value)
env.isTouchfling = Value
local vel, movel = nil, 0.1
while env.isTouchfling do
RunService.Heartbeat:Wait()
vel = Root.Velocity
Root.Velocity = vel * 9e8 + Vector3.new(0, 9e8, 0)
RunService.RenderStepped:Wait()
if Char and Char.Parent and Root and Root.Parent then
Root.Velocity = vel
end
RunService.Stepped:Wait()
if Char and Char.Parent and Root and Root.Parent then
Root.Velocity = vel + Vector3.new(0, movel, 0)
movel = movel * -1
end
end
end
})
MainTab:AddToggle({
    Name = "Noclip Players (AntiFling)",
    Default = false,
    Callback = function(value)
        env.NoclipPlr = value
if not env.NoclipPlr then
for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
        end
end
while env.NoclipPlr do
for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end
          task.wait()
        end
    end
})
MainTab:AddButton({
	Name = "Teleport To Map",
	Callback = function()
local map = Workspace:FindFirstChild("CoinContainer", true)
if map and map.Parent then
local part = map:FindFirstChildWhichIsA("BasePart", true)
local parts = map.Parent:FindFirstChildWhichIsA("BasePart", true)
if Char and part and part.CFrame then
Char:PivotTo(part.CFrame * CFrame.new(0, 2, 0))
elseif Char and parts and parts.CFrame then
Char:PivotTo(parts.CFrame * CFrame.new(0, 2, 0))
elseif Root and part and part.CFrame then
Root.CFrame = part.CFrame * CFrame.new(0, 2, 0)
elseif Root and parts and parts.CFrame then
Root.CFrame = parts.CFrame * CFrame.new(0, 2, 0)
end
end
  	end    
})
MainTab:AddButton({
	Name = "Teleport To Lobby",
	Callback = function()
local lobby = Workspace:FindFirstChild("Lobby", true)
if lobby and lobby.Parent then
local part = lobby:FindFirstChildWhichIsA("BasePart", true)
local parts = lobby.Parent:FindFirstChildWhichIsA("BasePart", true)
if Char and part and part.CFrame then
Char:PivotTo(part.CFrame * CFrame.new(0, 2, 0))
elseif Char and parts and parts.CFrame then
Char:PivotTo(parts.CFrame * CFrame.new(0, 2, 0))
elseif Root and part and part.CFrame then
Root.CFrame = part.CFrame * CFrame.new(0, 2, 0)
elseif Root and parts and parts.CFrame then
Root.CFrame = parts.CFrame * CFrame.new(0, 2, 0)
end
end
  	end    
})
MainTab:AddSlider({
	Name = "Set Timeout Fling",
	Min = 0.5,
	Max = 10,
	Default = 2.5,
	Color = Color3.fromRGB(255, 255, 255),
	Increment = 0.1,
	ValueName = "Timeout",
	Callback = function(Value)
		env.timeout = Value
	end    
})
MainTab:AddButton({
	Name = "Fling Murderer",
	Callback = function()
local Murderer = nil
for plr, role in getRoles() do
if role == "Murderer" then
Murderer = Players:FindFirstChild(plr)
break
end
end
if Murderer and Murderer ~= LocalPlayer then
    SHubFling(Murderer)
end
	end    
})
MainTab:AddButton({
	Name = "Fling Sheriff/Hero",
	Callback = function()
local Target = nil
for plr, role in getRoles() do
if role == "Sheriff" or role == "Hero" then
Target = Players:FindFirstChild(plr)
break
end
end
if Target and Target ~= LocalPlayer then
    SHubFling(Target)
end
	end    
})
local function getPlayerNames()
    local name = {}
    for _, player in ipairs(Players:GetPlayers()) do
         if player ~= LocalPlayer then
            table.insert(name, player.Name)
      end
    end
    return name
end
local TargetPlayer = nil
local PlayerDropdown = MainTab:AddDropdown({
    Name = "Select Player",
    Default = nil,
    Options = getPlayerNames(),
    Callback = function(Value)
        TargetPlayer = Value
    end
})
local function updateDropdown()
    PlayerDropdown:Refresh(getPlayerNames(), true)
    PlayerDropdown:Set(TargetPlayer)
end
Players.PlayerAdded:Connect(updateDropdown)
Players.PlayerRemoving:Connect(updateDropdown)
MainTab:AddButton({
	Name = "Fling Select Player",
	Callback = function()
if TargetPlayer then
local get = Players:FindFirstChild(TargetPlayer)
if get and get ~= LocalPlayer then
    SHubFling(get)
end
end
	end    
})
PlayerTab:AddToggle({
	Name = "Infinity Jump",
	Default = false,
	Callback = function(Value)
env.InfiniteJump = Value
game:GetService("UserInputService").JumpRequest:Connect(function()
if env.InfiniteJump then
if Char and Char ~= nil and Hum then
Hum:ChangeState("Jumping")
end
end
end)
	end    
})
PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(value)
        env.Noclip = value
if not env.Noclip then
     if Char and Char ~= nil then
             for _, c in pairs(Char:GetChildren()) do
                    if c:IsA("BasePart") and not c.CanCollide then
                        c.CanCollide = true
                    end
                end
            end
    end
while env.Noclip do
        if Char and Char ~= nil then
               for _, c in pairs(Char:GetChildren()) do
                    if c:IsA("BasePart") and c.CanCollide then
                        c.CanCollide = false
                    end
                end
            end
          task.wait()
        end
    end
})
PlayerTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 350,
    Default = env.Walkspeed or 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "WalkSpeed",
    Callback = function(Value)
if Char and Char ~= nil and Hum then
Hum.WalkSpeed = Value or 16
end
env.Walkspeed = Value or 16
    end    
})
PlayerTab:AddTextbox({
    Name = "WalkSpeed",
    Default = env.Walkspeed or "16",
    TextDisappear = false,
    Callback = function(Value)
if Char and Char ~= nil and Hum then
Hum.WalkSpeed = tonumber(Value) or 16
end
env.Walkspeed = tonumber(Value) or 16
    end	  
})
PlayerTab:AddToggle({
    Name = "WalkSpeed Set Auto",
    Default = false,
    Callback = function(Value)
env.KeepWalkspeed = Value
while env.KeepWalkspeed do
if Char and Char ~= nil and Hum then
      if Hum.WalkSpeed ~= env.Walkspeed then
        Hum.WalkSpeed = env.Walkspeed
      end
end
            task.wait()
        end
    end    
})
PlayerTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 500,
    Default = env.Jumppower or 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "JumpPower",
    Callback = function(Value)
if Char and Char ~= nil and Hum then
    Hum.JumpPower = Value or 50
end
        env.Jumppower = Value or 50
    end    
})
PlayerTab:AddTextbox({
    Name = "JumpPower",
    Default = env.Jumppower or "50",
    TextDisappear = false,
    Callback = function(Value)
if Char and Char ~= nil and Hum then
   Hum.JumpPower = tonumber(Value) or 50
  end
        env.Jumppower = tonumber(Value) or 50
    end	  
})
PlayerTab:AddToggle({
    Name = "JumpPower Set Auto",
    Default = false,
    Callback = function(Value)
env.KeepJumppower = Value
while env.KeepJumppower do
if Char and Char ~= nil and Hum then
            if Hum.JumpPower ~= env.Jumppower then
                Hum.JumpPower = env.Jumppower
            end
       end
            task.wait()
        end
    end    
})
