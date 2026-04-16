--[[
██╗   ██╗ ██████╗ ██╗██████╗ ██╗    ██╗ █████╗ ██████╗ ███████╗
██║   ██║██╔═══██╗██║██╔══██╗██║    ██║██╔══██╗██╔══██╗██╔════╝
██║   ██║██║   ██║██║██║  ██║██║ █╗██║███████║██████╔╝█████╗  
╚██╗ ██╔╝██║   ██║██║██║  ██║██║███╗██║██╔══██║██╔═══╝ ██╔══╝  
 ╚████╔╝ ╚██████╔╝██║██████╔╝╚███╔███╔╝██║  ██║██║     ███████╗
  ╚═══╝   ╚═════╝ ╚═╝╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚══════╝

                🚀 ZUENFIELD-HUB — 99 Nights In The Forest 🚀
----------------------------------------------------------------------------
]]

-- ==================== VARIABLES ====================
local OrionLib = nil
local Rayfield = nil
local CheatEngineMode = false
local IsLoaded = false
local OriginalMaxHealth = 100
local SharedData = shared.ZuenwareHub or {}
shared.ZuenwareHub = SharedData

-- ==================== LIBRARY LOAD ====================
-- Kumuha ng service ng ligtas
local function getService(name)
    local service = nil
    pcall(function()
        service = game:GetService(name)
    end)
    return service or nil
end

-- I-load ang Rayfield (pangunahing GUI)
pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

-- Backup na GUI: Orion (kung hindi gumana ang Rayfield)
if not Rayfield then
    pcall(function()
        OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
    end)
end

-- ==================== SERVICES ====================
local Players = getService("Players") or game.Players
local StarterGui = getService("StarterGui") or game.StarterGui
local TextChatService = getService("TextChatService")
local RunService = getService("RunService")

-- ==================== HELPER FUNCTIONS ====================
-- Kumuha ng character at humanoid ng player
local function getValidHumanoid()
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return nil end

    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not Character then return nil end

    local Humanoid = Character:WaitForChild("Humanoid", 5)
    return Humanoid
end

-- ==================== CHECK EXECUTOR ====================
local function checkExecutor()
    local ExecutorName = "Unknown"
    if identifyexecutor then
        pcall(function()
            ExecutorName = identifyexecutor() or "Unknown"
        end)
    end

    -- Blacklist ng mga hindi secure na executor
    local Blacklisted = {"solara", "cryptic", "xeno", "ember", "ronix"}
    for _, bad in pairs(Blacklisted) do
        if string.find(string.lower(ExecutorName), bad) then
            CheatEngineMode = true
            return false
        end
    end
    return true
end

-- ==================== NOTIFICATIONS ====================
local function sendNotify(title, text, time)
    if StarterGui then
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = time or 5
            })
        end)
    end
end

-- ==================== CHAT TAGS FEATURE ====================
local function loadChatTags()
    if not TextChatService then return end

    -- I-customize ang chat messages ng mga player
    TextChatService.OnIncomingMessage = function(data)
        local Properties = Instance.new("TextChatMessageProperties")
        local TextSource = data.TextSource
        local PrefixText = data.PrefixText or ""

        if TextSource then
            local Player = Players:GetPlayerByUserId(TextSource.UserId)
            if Player then
                local CustomPrefix = ""

                -- Dagdag ng tag para sa VIP
                if Player and Player:GetAttribute("__OwnsVIPGamepass") then
                    CustomPrefix = CustomPrefix .. "<font color='#FFD24B'>[VIP]</font> "
                end

                -- Dagdag ng level ng player
                local PlayerLevel = Player:GetAttribute("_CurrentLevel")
                if PlayerLevel then
                    CustomPrefix = CustomPrefix .. string.format("<font color='#ADD8E6'>[</font><font color='#FFFFFF'>%s</font><font color='#ADD8E6'>]</font> ", PlayerLevel)
                end

                -- Dagdag ng custom tag ng player
                local PlayerTag = Player:FindFirstChild("PlayerTagValue")
                if PlayerTag and PlayerTag.Value then
                    CustomPrefix = CustomPrefix .. string.format("<font color='#ADD8E6'>[</font><font color='#FFFFFF'>#%s</font><font color='#ADD8E6'>]</font> ", PlayerTag.Value)
                end

                -- Pagsamahin ang lahat ng prefix
                Properties.PrefixText = string.format("<font color='#FFFFFF'>%s%s</font>", CustomPrefix, PrefixText)
            end
        end

        return Properties
    end
    sendNotify("CHAT TAGS", "Enabled - Custom chat prefixes active!", 3)
end

-- ==================== GOD MODE FEATURE ====================
local GodModeActive = false
local function toggleGodMode(state)
    GodModeActive = state
    local Humanoid = getValidHumanoid()

    if Humanoid then
        if state then
            -- I-ON ANG GOD MODE
            OriginalMaxHealth = Humanoid.MaxHealth
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = Humanoid.MaxHealth
            
            -- Panatilihin ang infinite health
            if not SharedData.GodModeLoop then
                SharedData.GodModeLoop = RunService.Heartbeat:Connect(function()
                    if GodModeActive and Humanoid then
                        Humanoid.Health = Humanoid.MaxHealth
                    end
                end)
            end
            sendNotify("GOD MODE", "✅ Activated - Immortal!", 3)
        else
            -- I-OFF ANG GOD MODE
            Humanoid.MaxHealth = OriginalMaxHealth
            Humanoid.Health = OriginalMaxHealth
            
            -- Itigil ang loop
            if SharedData.GodModeLoop then
                SharedData.GodModeLoop:Disconnect()
                SharedData.GodModeLoop = nil
            end
            sendNotify("GOD MODE", "❌ Deactivated - Health restored!", 3)
        end
    else
        sendNotify("ERROR", "Character not found!", 3)
    end
end

-- ==================== GUI SETUP ====================
local function loadGUI()
    if not IsLoaded then return end

    -- GAMITIN ANG RAYFIELD GUI
    if Rayfield then
        local MainWindow = Rayfield:CreateWindow({
            Name = "Zuenfield Hub",
            Theme = "Dark",
            ConfigFolder = "VoidwareConfig",
            SaveConfig = false
        })

        -- MAIN TAB
        local MainTab = MainWindow:CreateTab("Main Features", "rbxassetid://4483345998")
        MainTab:CreateSection("Player Modifiers")
        
        -- GOD MODE TOGGLE
        MainTab:CreateToggle({
            Name = "God Mode (Invincible)",
            Default = false,
            Callback = function(state)
                toggleGodMode(state)
            end
        })

        -- SPEED BOOST SLIDER
        MainTab:CreateSlider({
            Name = "Walk Speed Multiplier",
            Min = 1,
            Max = 5,
            Increment = 0.5,
            Default = 1,
            Callback = function(value)
                local Humanoid = getValidHumanoid()
                if Humanoid then
                    Humanoid.WalkSpeed = 16 * value
                    sendNotify("SPEED", "Set to " .. value .. "x!", 2)
                end
            end
        })

        -- JUMP BOOST SLIDER
        MainTab:CreateSlider({
            Name = "Jump Power Multiplier",
            Min = 1,
            Max = 10,
            Increment = 0.5,
            Default = 1,
            Callback = function(value)
                local Humanoid = getValidHumanoid()
                if Humanoid then
                    -- Support both old at new games
                    if Humanoid:FindFirstChild("JumpHeight") or pcall(function() return Humanoid.JumpHeight end) then
                        Humanoid.JumpHeight = 7.2 * value
                    else
                        Humanoid.JumpPower = 50 * value
                    end
                    sendNotify("JUMP", "Set to " .. value .. "x!", 2)
                end
            end
        })

        -- ABOUT TAB
        local AboutTab = MainWindow:CreateTab("About", "rbxassetid://4483346000")
        AboutTab:CreateSection("Voidware Hub")
        AboutTab:CreateLabel("Made for 99 Nights In The Forest")
        AboutTab:CreateLabel("Version: 1.0.0")

    -- GAMITIN ANG ORION GUI (BACKUP)
    elseif OrionLib then
        local MainWindow = OrionLib:Init({
            Name = "Zuenfield Hub",
            SaveConfig = false,
            ConfigFolder = "VoidwareConfig"
        })

        local MainTab = MainWindow:MakeTab("Main Features", "rbxassetid://4483345998")
        
        MainTab:AddToggle({
            Name = "God Mode (Invincible)",
            Default = false,
            Callback = function(state)
                toggleGodMode(state)
            end
        })

        MainTab:AddSlider({
            Name = "Walk Speed Multiplier",
            Min = 1,
            Max = 5,
            Increment = 0.5,
            Default = 1,
            Callback = function(value)
                local Humanoid = getValidHumanoid()
                if Humanoid then
                    Humanoid.WalkSpeed = 16 * value
                    sendNotify("SPEED", "Set to " .. value .. "x!", 2)
                end
            end
        })

        MainTab:AddSlider({
            Name = "Jump Power Multiplier",
            Min = 1,
            Max = 10,
            Increment = 0.5,
            Default = 1,
            Callback = function(value)
                local Humanoid = getValidHumanoid()
                if Humanoid then
                    if Humanoid:FindFirstChild("JumpHeight") or pcall(function() return Humanoid.JumpHeight end) then
                        Humanoid.JumpHeight = 7.2 * value
                    else
                        Humanoid.JumpPower = 50 * value
                    end
                    sendNotify("JUMP", "Set to " .. value .. "x!", 2)
                end
            end
        })
    end
end

-- ==================== MAIN LOAD ====================
if checkExecutor() then
    sendNotify("LOADING", "Zuenfield Hub Is Starting...", 3)
    
    -- I-load ang lahat ng features
    loadChatTags()
    IsLoaded = true
    
    -- I-load ang GUI
    loadGUI()
    sendNotify("SUCCESS", "Hub Loaded! Enjoy Playing!", 5)
else
    sendNotify("ERROR", "Unsupported Executor! Use a trusted executor.", 5)
end
