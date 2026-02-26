--// Load MacLib
local MacLib = loadstring(game:HttpGet(
    "https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"
))()

-------------------------------------------------
--// SERVICES & VARIABLES
-------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

getgenv().AutoUpgrade = false
getgenv().AutoRebirth = false
getgenv().AutoCollectMoney = false
getgenv().CollectDelay = 5
getgenv().MaxDistance = 150

-------------------------------------------------
--// WINDOW SETUP
-------------------------------------------------
local Window = MacLib:Window({
    Title = "[🧬] Jump for Brainrots!",
    Subtitle = "By Gzuss",
    Size = UDim2.fromOffset(860, 620),
    DragStyle = 1,
    AcrylicBlur = false,
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl
})

local TabGroup = Window:TabGroup()
local MainTab = TabGroup:Tab({
    Name = "Main",
    Image = "rbxassetid://18821914323"
})

-------------------------------------------------
--// [LEFT COLUMN] UI SECTIONS
-------------------------------------------------

-- [[ SECTION 1: MAIN FEATURES ]] --
local MainSection = MainTab:Section({ Side = "Left" })
MainSection:Header({ Name = "Main Features" })

local PromptDefaults = {}
local InstantPrompt = false

local function ApplyPrompt(prompt, enabled)
    if not PromptDefaults[prompt] then PromptDefaults[prompt] = prompt.HoldDuration end
    prompt.HoldDuration = enabled and 0 or PromptDefaults[prompt]
end

local function ApplyAllPrompts(enabled)
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("ProximityPrompt") then pcall(function() ApplyPrompt(v, enabled) end) end
    end
end

game.DescendantAdded:Connect(function(obj)
    if InstantPrompt and obj:IsA("ProximityPrompt") then
        task.wait()
        pcall(function() ApplyPrompt(obj, true) end)
    end
end)

MainSection:Toggle({
    Name = "⚡ Instant Prompt",
    Default = false,
    Callback = function(v)
        InstantPrompt = v
        Window:Notify({ Title = "System", Description = (v and "Enabled" or "Disabled").." Instant Prompt", Lifetime = 3 })
        ApplyAllPrompts(v)
    end
})

-- [[ SECTION 2: PROGRESSION ]] --
local ProgSection = MainTab:Section({ Side = "Left" })
ProgSection:Header({ Name = "Progression" })

ProgSection:Toggle({
    Name = "Auto Buy Jump Power (+10)",
    Default = false,
    Callback = function(v)
        getgenv().AutoUpgrade = v
        if v then
            task.spawn(function()
                while getgenv().AutoUpgrade do
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeJumpBulk"):FireServer()
                    task.wait(0.1)
                end
            end)
        end
    end
})

ProgSection:Toggle({
    Name = "Auto Rebirth (Smart Check)",
    Default = false,
    Callback = function(v)
        getgenv().AutoRebirth = v
        if v then
            task.spawn(function()
                while getgenv().AutoRebirth do
                    task.wait(1)
                    local player = Players.LocalPlayer
                    if not player then break end
                    local readyValue = player:FindFirstChild("RebirthReady")
                    
                    if readyValue and readyValue:IsA("BoolValue") then
                        if readyValue.Value == true then
                            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RebirthRemote"):FireServer()
                            Window:Notify({ Title = "System", Description = "Rebirth Success!", Lifetime = 2 })
                            task.wait(1)
                        else
                            Window:Notify({ Title = "System", Description = "Not Ready! Stopping...", Lifetime = 3 })
                            getgenv().AutoRebirth = false
                            break
                        end
                    else
                         -- Attribute Fallback Logic Here
                         local attrReady = player:GetAttribute("RebirthReady")
                         if attrReady == true then
                             ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RebirthRemote"):FireServer()
                             task.wait(1)
                         elseif attrReady == false then
                             Window:Notify({ Title = "System", Description = "Not Ready (Attr)! Stopping.", Lifetime = 3 })
                             getgenv().AutoRebirth = false
                             break
                         end
                    end
                end
            end)
        end
    end
})

-- [[ SECTION 3: MONEY COLLECTION ]] --
local MoneySection = MainTab:Section({ Side = "Left" })
MoneySection:Header({ Name = "Money Collection" })

-- Money Logic Functions
local function GetMyPlot()
    for _, plot in ipairs(workspace.Plots:GetChildren()) do
        local ownerValue = plot:FindFirstChild("Owner")
        if ownerValue and tostring(ownerValue.Value) == LocalPlayer.Name then return plot end
    end
    return nil
end

local function GetPlotPosition(plotModel)
    if plotModel:IsA("Model") then return plotModel:GetPivot().Position
    elseif plotModel:FindFirstChild("Floor") then return plotModel.Floor.Position
    else return plotModel:FindFirstChildWhichIsA("BasePart", true).Position end
end

local function CollectFromFolder(folder)
    if not folder then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, part in ipairs(folder:GetChildren()) do
            if not getgenv().AutoCollectMoney then break end
            if part:IsA("BasePart") and part.Name:match("%d+") then
                hrp.CFrame = part.CFrame
                task.wait(0.15)
            end
        end
    end
end

MoneySection:Slider({
    Name = "Loop Delay (Seconds)",
    Default = 5, Minimum = 1, Maximum = 60,
    DisplayMethod = "Value", Precision = 0,
    Callback = function(v) getgenv().CollectDelay = v end
}, "CollectDelaySlider")

MoneySection:Slider({
    Name = "Max Distance (Studs)",
    Default = 150, Minimum = 50, Maximum = 500,
    DisplayMethod = "Value", Precision = 0,
    Callback = function(v) getgenv().MaxDistance = v end
}, "MaxDistanceSlider")

MoneySection:Toggle({
    Name = "💰 Auto Collect",
    Default = false,
    Callback = function(v)
        getgenv().AutoCollectMoney = v
        Window:Notify({ Title = "System", Description = (v and "Enabled" or "Disabled").." Auto Collect", Lifetime = 3 })
        
        if v then
            task.spawn(function()
                while getgenv().AutoCollectMoney do
                    task.wait(1)
                    local player = Players.LocalPlayer
                    local myPlot = GetMyPlot()
                    
                    if myPlot and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart
                        local plotPos = GetPlotPosition(myPlot)
                        local distance = (hrp.Position - plotPos).Magnitude
                        
                        if distance <= getgenv().MaxDistance then
                            local originalPos = hrp.CFrame
                            -- Floor 1
                            if myPlot:FindFirstChild("CollectButtons") then CollectFromFolder(myPlot.CollectButtons) end
                            -- Floor 2
                            if getgenv().AutoCollectMoney and myPlot:FindFirstChild("SecondFloor") then
                                local b = myPlot.SecondFloor:FindFirstChild("CollectButtons")
                                if b then CollectFromFolder(b) end
                            end
                            -- Floor 3
                            if getgenv().AutoCollectMoney and myPlot:FindFirstChild("ThirdFloor") then
                                local b = myPlot.ThirdFloor:FindFirstChild("CollectButtons")
                                if b then CollectFromFolder(b) end
                            end
                            -- Return
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                player.Character.HumanoidRootPart.CFrame = originalPos
                            end
                            task.wait(getgenv().CollectDelay)
                        else
                            task.wait(2) -- Too far
                        end
                    end
                end
            end)
        end
    end
}, "AutoCollectSafeToggle")


-------------------------------------------------
--// [RIGHT COLUMN] AUTO FARM
-------------------------------------------------
local FarmSection = MainTab:Section({ Side = "Right" })
FarmSection:Header({ Name = "AutoFarm Brainrots" })

local SelectedRarities = {}
local AutoFarm = false
local Farming = false
local ReturnCFrame = CFrame.new(31.68, 3, -156.56)
local RarityList = { "Basic", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Celestial", "Divine" }

local function GetHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function SmartTeleport(cf)
    local hrp = GetHRP()
    if hrp then hrp.CFrame = cf; task.wait(0.25) end
end

local function PressPrompt(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0; fireproximityprompt(v); return true
        end
    end
end

-- Farm Loop Logic
task.spawn(function()
    while task.wait(0.25) do
        if not AutoFarm or Farming then continue end
        local foundTarget = false
        for _, brainrot in ipairs(workspace.Brainrots:GetChildren()) do
            if not AutoFarm then break end
            local gui = brainrot:FindFirstChild("Gui", true)
            local rarityLabel = gui and gui:FindFirstChild("Rarity", true)
            local mesh = brainrot:FindFirstChild("Mesh")
            local carried = mesh and mesh:FindFirstChild("CarryBrainrotWeld")

            if rarityLabel and mesh and not carried and table.find(SelectedRarities, rarityLabel.Text) then
                local part = brainrot:FindFirstChildWhichIsA("BasePart")
                if part and part.Parent then
                    Farming = true
                    foundTarget = true
                    SmartTeleport(part.CFrame * CFrame.new(0, -3, 0))
                    
                    if not brainrot or not brainrot.Parent or not part or not part.Parent then
                        Farming = false; break
                    end
                    
                    task.wait(0.1); PressPrompt(brainrot)
                    
                    local timeout = 0
                    repeat task.wait(0.1); timeout = timeout + 0.1
                    until (mesh:FindFirstChild("CarryBrainrotWeld")) or not AutoFarm or not brainrot.Parent or timeout > 2
                    
                    SmartTeleport(ReturnCFrame)
                    Farming = false; break
                end
            end
        end
        if not foundTarget then Farming = false end
    end
end)

FarmSection:Dropdown({
    Name = "Select Rarity",
    Multi = true, Required = false,
    Options = RarityList, Default = {},
    Callback = function(v)
        SelectedRarities = {}
        for rarity, enabled in pairs(v) do if enabled then table.insert(SelectedRarities, rarity) end end
    end
})

FarmSection:Toggle({
    Name = "AutoFarm",
    Default = false,
    Callback = function(v)
        AutoFarm = v
        Window:Notify({ Title = "System", Description = (v and "Enabled" or "Disabled").." AutoFarm", Lifetime = 3 })
    end
})

FarmSection:Paragraph({ Header = "Info", Body = "Select rarity then enable AutoFarm." })

-------------------------------------------------
--// INITIALIZATION
-------------------------------------------------
MacLib:SetFolder("JumpForBrainrots")
MainTab:Select()
MacLib:LoadAutoLoadConfig()
