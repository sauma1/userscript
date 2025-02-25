-- Fishing Automation Script
-- UI Libraries
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Knuxy92/Ui-linoria/main/Fluent/Fluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Initialize Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Anti-Kick Protection
game.Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Streamer Mode (Hides Username)
local function enableStreamerMode()
    _G.StreamerMode = true
    
    local function hidePlayerName(textLabel)
        if not textLabel or textLabel.ClassName ~= "TextLabel" then return end
        
        if string.find(textLabel.Text, LocalPlayer.Name) then
            textLabel.Text = string.gsub(textLabel.Text, LocalPlayer.Name, "[Hidden]")
            textLabel.Changed:Connect(function()
                textLabel.Text = string.gsub(textLabel.Text, LocalPlayer.Name, "[Hidden]")
            end)
        end
        
        if string.find(textLabel.Text, LocalPlayer.DisplayName) then
            textLabel.Text = string.gsub(textLabel.Text, LocalPlayer.DisplayName, "[Hidden]")
            textLabel.Changed:Connect(function()
                textLabel.Text = string.gsub(textLabel.Text, LocalPlayer.DisplayName, "[Hidden]")
            end)
        end
    end
    
    -- Process existing labels
    pcall(function()
        for _, instance in pairs(game:GetDescendants()) do
            if instance.ClassName == "TextLabel" then
                hidePlayerName(instance)
            end
        end
        
        -- Handle new labels
        game.DescendantAdded:Connect(function(descendant)
            if descendant.ClassName == "TextLabel" then
                hidePlayerName(descendant)
            end
        end)
    end)
    
    print("[Streamer Mode] - Enabled successfully")
end

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

-- Fishing Functions
local FishingSystem = {}

function FishingSystem.instantLure(rodTool)
    pcall(function()
        if rodTool and rodTool.values and rodTool.values.lure then
            rodTool.values.lure.Value = 100
        end
    end)
end

function FishingSystem.autoReel()
    local reel = LocalPlayer.PlayerGui:FindFirstChild("reel")
    if not reel then return end
    
    local bar = reel:FindFirstChild("bar")
    local playerbar = bar and bar:FindFirstChild("playerbar")
    local fish = bar and bar:FindFirstChild("fish")
    
    if playerbar and fish then
        playerbar.Position = fish.Position
    end
end

function FishingSystem.noPerfect()
    local reel = LocalPlayer.PlayerGui:FindFirstChild("reel")
    if not reel then return end
    
    local bar = reel:FindFirstChild("bar")
    local playerbar = bar and bar:FindFirstChild("playerbar")
    
    if playerbar then
        playerbar.Position = UDim2.new(0, 0, -35, 0)
        task.wait(0.2)
    end
end

local autoReelConnection = nil
local autoReelEnabled = false
local ReelMode = "Legit"

function FishingSystem.startAutoReel()
    if ReelMode == "Legit" then
        if autoReelConnection or not autoReelEnabled then return end
        FishingSystem.noPerfect()
        task.wait(1)
        autoReelConnection = RunService.RenderStepped:Connect(FishingSystem.autoReel)
    end
end

function FishingSystem.stopAutoReel()
    if autoReelConnection then
        autoReelConnection:Disconnect()
        autoReelConnection = nil
    end
end

-- Automatic Fishing Function
if not _G.AllFuncs then
    _G.AllFuncs = {}
end

_G.AllFuncs['Farm Fish'] = function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local Backpack = LocalPlayer:WaitForChild("Backpack")
    
    local reelfinished = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished")
    local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
    
    -- Main fishing loop
    while _G.Config['Farm Fish'] do
        if PlayerGui:FindFirstChild("reel") then
            -- Handle reeling
            LocalPlayer.Character.Humanoid:EquipTool(Backpack:FindFirstChild(RodName))
            
            local ShakeGui = PlayerGui:FindFirstChild("shakeui")
            if ShakeGui then
                repeat wait(0.1)
                until not ShakeGui:FindFirstChild("safezone")
                or not ShakeGui.safezone:FindFirstChild("button")
                or not ShakeGui.safezone.button.Visible
            end
            
            -- Check for Reel UI
            local ReelUI = PlayerGui:FindFirstChild("reel")
            if not ReelUI then 
                wait(0.1)
                continue 
            end
            
            while true do
                RunService.RenderStepped:Wait()
                
                local ReelUI = LocalPlayer.PlayerGui:FindFirstChild("reel")
                if not ReelUI then break end
                
                -- Handle instant reel feature
                if _G.Config.InstantReel then
                    local Bar = ReelUI:FindFirstChild("bar")
                    
                    if not Bar then break end
                    
                    local ReelScript = Bar:FindFirstChild("reel")
                    if ReelScript and ReelScript.Enabled == true then
                        -- This was empty in original code
                    end
                    
                    local reelGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("reel")
                    if reelGui then
                        wait(1)
                        while reelGui do
                            local reelArgs = { [1] = 100, [2] = true }
                            reelfinished:FireServer(unpack(reelArgs))
                            wait(0.1)
                            reelGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("reel")
                        end
                    end
                    wait(1)
                     game:GetService("Players").LocalPlayer.Character:FindFirstChild("No-Life Rod").events.reset:FireServer()
                end
            end
        else
            -- Handle casting
            if _G.Config.AutoCast then
                if LocalPlayer.Character:FindFirstChild(RodName) then
                    LocalPlayer.Character[RodName].events.cast:FireServer(100,1)
                end
            else
                if LocalPlayer.Character:FindFirstChild(RodName) then
                    -- Cast with maximum power
                    LocalPlayer.Character[RodName].events.cast:FireServer(999999999)
                end
            end
        end
        task.wait()
    end
end

-- Create GUI
local function setupGUI()
    -- Create Window
    local Window = Fluent:CreateWindow({
        Title = "Fishing Automation",
        SubTitle = "By FishingPro",
        TabWidth = 160,
        Size = UDim2.new(0, 450, 0, 300),
        Acrylic = true,
        Theme = "Dark"
    })
    
    -- Create Tabs
    local FishingTab = Window:AddTab({ Title = "Fishing", Icon = "🎣" })
    local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "⚙️" })
    
    -- Main Fishing Section
    local MainSection = FishingTab:AddSection("Fishing Controls")
    
    -- Add controls
    local AutoCastToggle = MainSection:AddToggle("AutoCast", {Title = "Instant Bobber", Default = false})
    AutoCastToggle:OnChanged(function()
        _G.Config.AutoCast = AutoCastToggle.Value
        print("Auto Cast:", AutoCastToggle.Value)
    end)
    
    local AutoReelToggle = MainSection:AddToggle("AutoReel", {Title = "Auto Reel", Default = false})
    AutoReelToggle:OnChanged(function()
        _G.Config.AutoReel = AutoReelToggle.Value
        autoReelEnabled = AutoReelToggle.Value
        
        if autoReelEnabled then
            FishingSystem.startAutoReel()
        else
            FishingSystem.stopAutoReel()
        end
        
        print("Auto Reel:", AutoReelToggle.Value)
    end)
    
    local SuperReelToggle = MainSection:AddToggle("SuperReel", {Title = "Super Reel", Default = false})
    SuperReelToggle:OnChanged(function()
        _G.Config.InstantReel = SuperReelToggle.Value
        print("Super Reel:", SuperReelToggle.Value)
    end)
    
    local StartButton = MainSection:AddButton({
        Title = "Start/Stop Fishing",
        Description = "Toggle fishing automation",
        Callback = function()
            _G.Config['Farm Fish'] = not _G.Config['Farm Fish']
            
            if _G.Config['Farm Fish'] then
                if _G.AllFuncs and _G.AllFuncs['Farm Fish'] then
                    spawn(_G.AllFuncs['Farm Fish'])
                    StartButton:SetTitle("Stop Fishing")
                end
            else
                StartButton:SetTitle("Start Fishing")
            end
            
            if SuperReelToggle.Value then
                spawn(function()
                    while _G.Config['Farm Fish'] do
                        task.wait(1)
                        LocalPlayer.Character.Humanoid:UnequipTools()
                    end
                end)
            end
        end
    })
    
    -- Stats Section
    local StatsSection = FishingTab:AddSection("Fishing Stats")
    
    local CatchCounter = 0
    local StartTime = 0
    
    local CatchesLabel = StatsSection:AddLabel("Total Catches: 0")
    local TimeLabel = StatsSection:AddLabel("Time Elapsed: 00:00:00")
    local RateLabel = StatsSection:AddLabel("Catch Rate: 0/hr")
    
    -- Update stats
    spawn(function()
        while wait(1) do
            if _G.Config['Farm Fish'] then
                if StartTime == 0 then
                    StartTime = tick()
                end
                
                local elapsed = tick() - StartTime
                local hours = math.floor(elapsed / 3600)
                local minutes = math.floor((elapsed % 3600) / 60)
                local seconds = math.floor(elapsed % 60)
                
                local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                TimeLabel:SetText("Time Elapsed: " .. timeString)
                
                if elapsed > 0 then
                    local rate = math.floor((CatchCounter / elapsed) * 3600)
                    RateLabel:SetText("Catch Rate: " .. rate .. "/hr")
                end
            else
                if StartTime ~= 0 then
                    StartTime = 0
                    CatchCounter = 0
                    CatchesLabel:SetText("Total Catches: 0")
                    TimeLabel:SetText("Time Elapsed: 00:00:00")
                    RateLabel:SetText("Catch Rate: 0/hr")
                end
            end
        end
    end)
    
    -- Settings
    local SettingsSection = SettingsTab:AddSection("Settings")
    
    -- Add streamer mode
    local StreamerModeToggle = SettingsSection:AddToggle("StreamerMode", {Title = "Streamer Mode", Default = false})
    StreamerModeToggle:OnChanged(function()
        _G.StreamerMode = StreamerModeToggle.Value
        
        if _G.StreamerMode then
            enableStreamerMode()
        end
    end)
    
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
    
    -- Credits Section
    local CreditsSection = SettingsTab:AddSection("Credits")
    CreditsSection:AddLabel("Created by: FishingPro")
    CreditsSection:AddLabel("UI: Fluent Library")
    
    -- Initialize Save Manager
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:SetFolder("FishingAutomation")
    InterfaceManager:SetFolder("FishingAutomation")
    
    -- Try to load previous settings
    SaveManager:Load("config")
end

setupGUI()

print("Fishing Automation Loaded Successfully!")
