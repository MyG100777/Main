--// Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--// Window
local Window = Fluent:CreateWindow({
    Title = "Escape Tsunami | Brainrots",
    SubTitle = "Gzuss",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

--// Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Save default zoom
local DefaultMinZoom = LocalPlayer.CameraMinZoomDistance
local DefaultMaxZoom = LocalPlayer.CameraMaxZoomDistance

--// ===== MAIN TAB =====
Tabs.Main:AddSection("Config")

local UnlockZoomToggle = Tabs.Main:AddToggle("UnlockZoom", {
    Title = " 📷 Unlock Zoom ",
    Description = "ปลดล็อกการซูมแบบไม่จำกัด",
    Default = false
})

UnlockZoomToggle:OnChanged(function(Value)
    if Value then
        LocalPlayer.CameraMinZoomDistance = 0
        LocalPlayer.CameraMaxZoomDistance = 1e6
    else
        LocalPlayer.CameraMinZoomDistance = DefaultMinZoom
        LocalPlayer.CameraMaxZoomDistance = DefaultMaxZoom
    end
end)

--// Remove VIP Wall
Tabs.Main:AddButton({
    Title = "🧱 Remove VIP Wall",
    Description = "ลบกำแพง VIP ออกไป",
    Callback = function()
        local map = workspace:FindFirstChild("DefaultMap_SharedInstances")
        if not map then
            Fluent:Notify({
                Title = "Error",
                Content = "ไม่พบ DefaultMap_SharedInstances",
                Duration = 4
            })
            return
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

local InstantPromptToggle = Tabs.Main:AddToggle("InstantPrompt", {
    Title = "⚡ Instant Prompt",
    Description = "กดปุ่มทุกอย่างได้ทันที (0 วิ)",
    Default = false
})

-- เก็บค่าเดิม
local PromptDefaults = {}
local PromptConnection

local function SetPrompt(prompt, enabled)
    if not PromptDefaults[prompt] then
        PromptDefaults[prompt] = prompt.HoldDuration
    end

    if enabled then
        prompt.HoldDuration = 0
    else
        prompt.HoldDuration = PromptDefaults[prompt] or prompt.HoldDuration
    end
end

InstantPromptToggle:OnChanged(function(Value)
    if Value then
        -- ของที่มีอยู่แล้ว
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                SetPrompt(v, true)
            end
        end

        -- ของที่เกิดใหม่
        PromptConnection = workspace.DescendantAdded:Connect(function(v)
            if v:IsA("ProximityPrompt") then
                SetPrompt(v, true)
            end
        end)
    else
        -- คืนค่าเดิม
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

--// ===== SETTINGS TAB =====
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/EscapeTsunami")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

--// Default Tab
Window:SelectTab(1)

--// Notify
Fluent:Notify({
    Title = "Loaded",
    Content = "Escape Tsunami script loaded successfully",
    Duration = 6
})

--// Auto Load Config
SaveManager:LoadAutoloadConfig()
