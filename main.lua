--// =====================================================
--// LOAD FLUENT UI
--// =====================================================
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()

local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

--// =====================================================
--// WINDOW
--// =====================================================
local Window = Fluent:CreateWindow({
    Title = "Escape Tsunami | Brainrots",
    SubTitle = "By Gzuss",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

--// =====================================================
--// TABS
--// =====================================================
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

--// =====================================================
--// SERVICES & PLAYER
--// =====================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Camera defaults
local DefaultMinZoom = LocalPlayer.CameraMinZoomDistance
local DefaultMaxZoom = LocalPlayer.CameraMaxZoomDistance

-- Initial Player Stats
local InitialSpeed = LocalPlayer:GetAttribute("CurrentSpeed") or 10
local InitialJump  = LocalPlayer:GetAttribute("JumpUpgrade") or 1

-- UI references
local PlayerSpeedSlider
local JumpUpgradeSlider

-- ProximityPrompt
local PromptDefaults = {}
local PromptConnection

--// =====================================================
--// MAIN TAB
--// =====================================================
Tabs.Main:AddParagraph({
    Title = "Discord",
    Content = "https://discord.gg/amybwznh"
})

Tabs.Main:AddSection("Main")

-- 📷 Unlock Zoom
local UnlockZoomToggle = Tabs.Main:AddToggle("UnlockZoom", {
    Title = "📷 Unlock Zoom",
    Description = "ปลดล็อกการซูมแบบไม่จำกัด",
    Default = false
})

UnlockZoomToggle:OnChanged(function(state)
    if state then
        LocalPlayer.CameraMinZoomDistance = 0
        LocalPlayer.CameraMaxZoomDistance = 1e6
    else
        LocalPlayer.CameraMinZoomDistance = DefaultMinZoom
        LocalPlayer.CameraMaxZoomDistance = DefaultMaxZoom
    end
end)

-- 🧱 Remove VIP Wall
Tabs.Main:AddButton({
    Title = "🧱 Remove VIP Wall",
    Description = "ลบกำแพง VIP ออกไป",
    Callback = function()
        local map = workspace:FindFirstChild("DefaultMap_SharedInstances")
        if not map then
            return Fluent:Notify({
                Title = "Error",
                Content = "ไม่พบ DefaultMap_SharedInstances",
                Duration = 4
            })
        end

        local vipWalls = map:FindFirstChild("VIPWalls")
        if vipWalls then
            vipWalls:Destroy()
            Fluent:Notify({
                Title = "Success",
                Content = "ลบ VIP Wall เรียบร้อยแล้ว",
                Duration = 4
            })
        else
            Fluent:Notify({
                Title = "Info",
                Content = "ไม่พบ VIP Wall (อาจถูกลบไปแล้ว)",
                Duration = 4
            })
        end
    end
})

-- ⚡ Instant Prompt
local InstantPromptToggle = Tabs.Main:AddToggle("InstantPrompt", {
    Title = "⚡ Instant Prompt",
    Description = "กดปุ่มทุกอย่างได้ทันที (0 วิ)",
    Default = false
})

local function ApplyPrompt(prompt, enabled)
    if not PromptDefaults[prompt] then
        PromptDefaults[prompt] = prompt.HoldDuration
    end
    prompt.HoldDuration = enabled and 0 or PromptDefaults[prompt]
end

InstantPromptToggle:OnChanged(function(state)
    if state then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                ApplyPrompt(v, true)
            end
        end

        PromptConnection = workspace.DescendantAdded:Connect(function(v)
            if v:IsA("ProximityPrompt") then
                ApplyPrompt(v, true)
            end
        end)
    else
        if PromptConnection then
            PromptConnection:Disconnect()
            PromptConnection = nil
        end

        for prompt, duration in pairs(PromptDefaults) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = duration
            end
        end
    end
end)

--// =====================================================
--// MISC TAB (PLAYER)
--// =====================================================
Tabs.Misc:AddSection("🧍 Player")

PlayerSpeedSlider = Tabs.Misc:AddSlider("PlayerSpeed", {
    Title = "🚀 Player Speed",
    Description = "ปรับความเร็วการเดิน",
    Default = InitialSpeed,
    Min = 0,
    Max = 1200,
    Rounding = 1,
    Callback = function(value)
        LocalPlayer:SetAttribute("CurrentSpeed", value)
    end
})

JumpUpgradeSlider = Tabs.Misc:AddSlider("JumpUpgrade", {
    Title = "🦘 Jump Upgrade",
    Description = "ปรับกระโดดสูง",
    Default = InitialJump,
    Min = 0,
    Max = 1000,
    Rounding = 1,
    Callback = function(value)
        LocalPlayer:SetAttribute("JumpUpgrade", value)
    end
})

Tabs.Misc:AddButton({
    Title = "🔄 Reset Player Stats",
    Description = "รีเซ็ตความเร็วและการกระโดดกลับค่าเริ่มต้น",
    Callback = function()
        LocalPlayer:SetAttribute("CurrentSpeed", InitialSpeed)
        LocalPlayer:SetAttribute("JumpUpgrade", InitialJump)

        PlayerSpeedSlider:SetValue(InitialSpeed)
        JumpUpgradeSlider:SetValue(InitialJump)

        Fluent:Notify({
            Title = "Reset Complete",
            Content = "รีเซ็ตค่าผู้เล่นเรียบร้อยแล้ว",
            Duration = 4
        })
    end
})

--// =====================================================
--// SETTINGS TAB
--// =====================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/EscapeTsunami")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

--// =====================================================
--// STARTUP
--// =====================================================
Window:SelectTab(1)

Fluent:Notify({
    Title = "Loaded",
    Content = "Escape Tsunami script loaded successfully",
    Duration = 6
})

SaveManager:LoadAutoloadConfig()
