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
    SubTitle = "Gzuss",
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
--// SERVICES & PLAYER CACHE
--// =====================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Camera defaults
local DefaultMinZoom = LocalPlayer.CameraMinZoomDistance
local DefaultMaxZoom = LocalPlayer.CameraMaxZoomDistance

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

local PromptDefaults = {}
local PromptConnection

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

local SpeedValue
local JumpValue

local function FindPlayerValues()
    SpeedValue = LocalPlayer:FindFirstChild("CurrentSpeed", true)
    JumpValue = LocalPlayer:FindFirstChild("JumpUpgrade", true)
end

FindPlayerValues()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    FindPlayerValues()
end)

local DefaultSpeed = SpeedValue and SpeedValue.Value or 10
local DefaultJump  = JumpValue and JumpValue.Value or 1

-- 🚀 Speed
Tabs.Misc:AddSlider("PlayerSpeed", {
    Title = "🚀 Player Speed",
    Description = "ปรับค่า CurrentSpeed",
    Default = DefaultSpeed,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Callback = function(value)
        if SpeedValue then
            SpeedValue.Value = value
        end
    end
})

-- 🦘 Jump
Tabs.Misc:AddSlider("JumpUpgrade", {
    Title = "🦘 Jump Upgrade",
    Description = "ปรับค่า JumpUpgrade",
    Default = DefaultJump,
    Min = 0,
    Max = 200,
    Rounding = 1,
    Callback = function(value)
        if JumpValue then
            JumpValue.Value = value
        end
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
