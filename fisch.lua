local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Knuxy92/Ui-linoria/main/Fluent/Fluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Initialize Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

game.Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Initialize Config
if not _G.Config then
    _G.Config = {
        ['Farm Fish'] = false,
        AutoCast = false,
        InstantCast = false,
        AutoReel = false,
        InstantReel = false,
        ReelMode = "Legit"
    }
end

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "Fishing ShielD",
    SubTitle = "SHIELD TEAM",
    TabWidth = 160,
    Size = UDim2.new(0, 450, 0, 300),
    Acrylic = true,
    Theme = "Dark"
})

-- Create Tabs
local FishingTab = Window:AddTab({ Title = "Fishing", Icon = "🎣" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "⚙️" })
local MainSection = FishingTab:AddSection()

local AutoCastToggle = MainSection:AddToggle("MyToggle", {Title = "Instant Bobber", Default = false})
AutoCastToggle:OnChanged(function()
    print("Perfect Catch", AutoCastToggle.Value)
end)
AutoCastToggle:SetValue(false)

local AutoReel = MainSection:AddToggle("AutoReel", {Title = "Auto Reel", Default = false})
AutoReel:OnChanged(function()
    print("AutoReel", AutoReel.Value)
end)
AutoReel:SetValue(false)

local BugReel = MainSection:AddToggle("BugReel", {Title = "Super Reel", Default = false})
BugReel:OnChanged(function()
    print("BugReel", BugReel.Value)
end)
BugReel:SetValue(false)

local ToggleButton = MainSection:AddButton({
    Title = "Start Fishing",
    Description = "Toggle fishing automation",
        Callback = function()
            _G.Config['Farm Fish'] = not _G.Config['Farm Fish']
            if _G.Config['Farm Fish'] then
                if _G.AllFuncs and _G.AllFuncs['Farm Fish'] then
                    spawn(_G.AllFuncs['Farm Fish'])
                end
                else
            end
        if BugReel.Value then
            while true do
                task.wait(1.2)
                LocalPlayer.Character.Humanoid:UnequipTools()
            end
        else
        end
    end
})

local function autoReel()
    local reel = LocalPlayer.PlayerGui:FindFirstChild("reel")
    if not reel then return end
    local bar = reel:FindFirstChild("bar")
    local playerbar = bar and bar:FindFirstChild("playerbar")
    local fish = bar and bar:FindFirstChild("fish")
    if playerbar and fish then
        playerbar.Position = fish.Position
    end
end


local function noPerfect()
    local reel = LocalPlayer.PlayerGui:FindFirstChild("reel")
    if not reel then return end
    local bar = reel:FindFirstChild("bar")
    local playerbar = bar and bar:FindFirstChild("playerbar")
    if playerbar then
        playerbar.Position = UDim2.new(0, 0, -35, 0)
        task.wait(0.2)
    end
end

local function startAutoReel()
    if ReelMode == "Legit" then
        if autoReelConnection or not autoReelEnabled then return end
        noPerfect()
        task.wait(2)
        autoReelConnection = RunService.RenderStepped:Connect(autoReel)
    end
end

local function stopAutoReel()
    if autoReelConnection then
        autoReelConnection:Disconnect()
        autoReelConnection = nil
    end
end

-- Initialize Fishing Functions
if not _G.AllFuncs then
    _G.AllFuncs = {}
end

_G.AllFuncs['Farm Fish'] = function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local Backpack = LocalPlayer:WaitForChild("Backpack")
    local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
    LocalPlayer.Character.Humanoid:EquipTool(Backpack:FindFirstChild(RodName))
    local function ExportValue(value, decimals)
        if tonumber(value) then
            return string.format("%." .. (decimals or 0) .. "f", tonumber(value))
        end
        return value
    end
    
    -- Function for instant bobber drop
    local function instantLure(rodTool)
        pcall(function()
            if rodTool and rodTool.values and rodTool.values.lure then
                rodTool.values.lure.Value = 100
            end
        end)
    end
    
    while _G.Config['Farm Fish'] and task.wait() do
        LocalPlayer.Character.Humanoid:EquipTool(Backpack:FindFirstChild(RodName))
        if LocalPlayer.Character:FindFirstChild(RodName) and LocalPlayer.Character:FindFirstChild(RodName):FindFirstChild("bobber") then
            local XyzClone = game:GetService("ReplicatedStorage").resources.items.items.GPS.GPS.gpsMain.xyz:Clone()
            XyzClone.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("backpack")
            XyzClone.Name = "Lure"
            XyzClone.Text = "<font color='#ff4949'>Lure </font>: Instant"
            
            -- Apply instant bobber drop
            instantLure(LocalPlayer.Character:FindFirstChild(RodName))
            task.wait(0.01)
            
            pcall(function()
                if LocalPlayer.Character:FindFirstChild(RodName) and LocalPlayer.Character:FindFirstChild(RodName).values.bite then
                    LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value = true
                end
            end)
            
            pcall(function()
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if PlayerGui then
                    local shakeUI = PlayerGui:FindFirstChild("shakeui")
                    if shakeUI and shakeUI:FindFirstChild("safezone") then
                        local button = shakeUI.safezone:FindFirstChild("button")
                        if button then
                            button.Size = UDim2.new(1001, 0, 1001, 0)
                            button.BackgroundTransparency = 1
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(1, 1))
                            game:GetService("VirtualUser"):Button1Up(Vector2.new(1, 1))
                        end
                    end
                end
            end)
            pcall(function()
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if PlayerGui then
                    local reelUI = PlayerGui:FindFirstChild("reel")
                    if reelUI then
                        reelUI:Destroy()
                    end
                end
            end)
            pcall(function()
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if PlayerGui then
                    local reelUI = PlayerGui:FindFirstChild("reel")
                    if reelUI then
                        reelUI:Destroy()
                    end
                end
            end)
            XyzClone.Text = "<font color='#ff4949'>Lure </font>: 100%"
            task.wait(0.01)
            local biteWaitStart = tick()
            repeat
                RunService.Heartbeat:Wait()
            until not LocalPlayer.Character:FindFirstChild(RodName) or 
                  LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value or 
                  not _G.Config['Farm Fish'] or
                  (tick() - biteWaitStart > 0.01) 
            
            XyzClone.Text = "<font color='#ff4949'>FISHING!</font>"
            delay(0.1, function()
                XyzClone:Destroy()
            end)
                repeat
                    if AutoReel.Value then
                        for i = 1,2 do
                            ReplicatedStorage.events.reelfinished:FireServer(9999999, true)
                            task.wait(0.01)
                        end
                        stopAutoReel()
                    else
                    end
                until not LocalPlayer.Character:FindFirstChild(RodName) or not LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value or not _G.Config['Farm Fish']
        else
            if AutoCastToggle.Value then
                if LocalPlayer.Character:FindFirstChild(RodName) then
                    LocalPlayer.Character[RodName].events.cast:FireServer(0.01)
                else
                end
            else
                if LocalPlayer.Character:FindFirstChild(RodName) then
                    LocalPlayer.Character[RodName].events.cast:FireServer(999999999)
                else
                end
            end
        end
    end
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Save/Load Configuration
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetFolder("FishingAutomation")
InterfaceManager:SetFolder("FishingAutomation")

-- Settings
local SettingsSection = SettingsTab:AddSection("Settings")

SettingsSection:AddButton({
    Title = "Save Settings",
    Callback = function()
        SaveManager:Save("config")
    end
})

SettingsSection:AddButton({
    Title = "Load Settings",
    Callback = function()
        SaveManager:Load("config")
    end
})

-- Initialize
SaveManager:LoadAutoloadConfig()
UpdateRodInfo()
