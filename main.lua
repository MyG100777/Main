--// Load MacLib
local MacLib = loadstring(game:HttpGet(
    "https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"
))()

-------------------------------------------------
--// SERVICES
-------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-------------------------------------------------
--// GLOBAL CONFIG & VARIABLES
-------------------------------------------------
getgenv().AutoUpgrade = false
getgenv().AutoRebirth = false
getgenv().AutoCollectMoney = false
getgenv().CollectDelay = 5
getgenv().MaxDistance = 150

-- AutoFarm Variables
local SelectedRarities = {}
local SelectedMutations = {}
local AutoFarm = false
local Farming = false
local ReturnCFrame = CFrame.new(31.68, 3, -156.56)

-- Trait Machine Variables
local AutoTrait = false
local LastItemName = nil
local TraitMachineCF = CFrame.new(33.6139984, 510.191956, 352.480988, -1, 0, 0, 0, 1, 0, 0, 0, -1)

-------------------------------------------------
--// UTILITY FUNCTIONS
-------------------------------------------------
local function GetHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function SmartTeleport(cf)
    local hrp = GetHRP()
    if hrp then
        hrp.CFrame = cf
        task.wait(0.25) -- Wait for server replication
    end
end

local function PressPrompt(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
            fireproximityprompt(v)
            return true
        end
    end
end

-------------------------------------------------
--// WINDOW SETUP
-------------------------------------------------
local Window = MacLib:Window({
    Title = "[🧬] Jump for Brainrots!",
    Subtitle = "By Gzuss",
    Size = UDim2.fromOffset(860, 620),
    DragStyle = 1,
    AcrylicBlur = true,
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl
})

local TabGroup = Window:TabGroup()
local MainTab = TabGroup:Tab({
    Name = "Main",
    Image = "rbxassetid://18821914323"
})

-- UI Sections
local LeftSection = MainTab:Section({ Side = "Left" })
local RightSection = MainTab:Section({ Side = "Right" }) -- For Farm
local TraitSection = MainTab:Section({ Side = "Right" }) -- For Trait (Stack below Farm)

-------------------------------------------------
--// [LEFT] MAIN FEATURES
-------------------------------------------------
LeftSection:Header({ Name = "Main Features" })

local InstantPrompt = false
local function ApplyAllPrompts(enabled)
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            if not v:GetAttribute("OriginalHold") then
                v:SetAttribute("OriginalHold", v.HoldDuration)
            end
            v.HoldDuration = enabled and 0 or v:GetAttribute("OriginalHold")
        end
    end
end

game.DescendantAdded:Connect(function(obj)
    if InstantPrompt and obj:IsA("ProximityPrompt") then
        task.wait()
        obj.HoldDuration = 0
    end
end)

LeftSection:Toggle({
    Name = "⚡ Instant Prompt",
    Default = false,
    Callback = function(v)
        InstantPrompt = v
        Window:Notify({ Title = "System", Description = (v and "Enabled" or "Disabled").." Instant Prompt", Lifetime = 3 })
        ApplyAllPrompts(v)
    end
})

-------------------------------------------------
--// [LEFT] PROGRESSION
-------------------------------------------------
local ProgSection = MainTab:Section({ Side = "Left" })
ProgSection:Header({ Name = "Progression" })

ProgSection:Toggle({
    Name = "💪 AutoBuy JumpPower (+10)",
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
    Name = "Auto Rebirth",
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
                    local attrReady = player:GetAttribute("RebirthReady")
                    
                    if (readyValue and readyValue.Value == true) or (attrReady == true) then
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RebirthRemote"):FireServer()
                        Window:Notify({ Title = "System", Description = "Rebirth Success!", Lifetime = 2 })
                        task.wait(1)
                    elseif (readyValue and readyValue.Value == false) or (attrReady == false) then
                        Window:Notify({ Title = "System", Description = "Not Ready! Stopping...", Lifetime = 3 })
                        getgenv().AutoRebirth = false
                        break
                    end
                end
            end)
        end
    end
})

-------------------------------------------------
--// [LEFT] MONEY COLLECTION
-------------------------------------------------
local MoneySection = MainTab:Section({ Side = "Left" })
MoneySection:Header({ Name = "Money Collection" })

local function GetMyPlot()
    for _, plot in ipairs(Workspace.Plots:GetChildren()) do
        local owner = plot:FindFirstChild("Owner")
        if owner and tostring(owner.Value) == LocalPlayer.Name then return plot end
    end
    return nil
end

local function CollectFromFolder(folder)
    if not folder then return end
    local hrp = GetHRP()
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
                    local myPlot = GetMyPlot()
                    local hrp = GetHRP()
                    
                    if myPlot and hrp then
                        local plotPos = myPlot:GetPivot().Position
                        if myPlot:FindFirstChild("Floor") then plotPos = myPlot.Floor.Position end
                        
                        if (hrp.Position - plotPos).Magnitude <= getgenv().MaxDistance then
                            local originalPos = hrp.CFrame
                            
                            -- Collect all floors
                            if myPlot:FindFirstChild("CollectButtons") then CollectFromFolder(myPlot.CollectButtons) end
                            if getgenv().AutoCollectMoney and myPlot:FindFirstChild("SecondFloor") then
                                local b = myPlot.SecondFloor:FindFirstChild("CollectButtons")
                                if b then CollectFromFolder(b) end
                            end
                            if getgenv().AutoCollectMoney and myPlot:FindFirstChild("ThirdFloor") then
                                local b = myPlot.ThirdFloor:FindFirstChild("CollectButtons")
                                if b then CollectFromFolder(b) end
                            end
                            
                            -- Return
                            if LocalPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = originalPos end
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
--// [RIGHT] AUTO FARM BRAINROTS
-------------------------------------------------
RightSection:Header({ Name = "AutoFarm Brainrots" })

-- Farm Logic
task.spawn(function()
    while task.wait(0.25) do
        if not AutoFarm or Farming then continue end
        local foundTarget = false
        
        for _, brainrot in ipairs(Workspace.Brainrots:GetChildren()) do
            if not AutoFarm then break end
            
            local gui = brainrot:FindFirstChild("Gui", true)
            local rarityLabel = gui and gui:FindFirstChild("Rarity", true)
            local variantLabel = gui and gui:FindFirstChild("Variant")
            local variantText = variantLabel and variantLabel.Text
            
            local mesh = brainrot:FindFirstChild("Mesh")
            local carried = mesh and mesh:FindFirstChild("CarryBrainrotWeld")

            -- Check Mutation
            local isMutationMatch = (#SelectedMutations == 0) or (variantText and table.find(SelectedMutations, variantText))

            if rarityLabel and mesh and not carried 
               and table.find(SelectedRarities, rarityLabel.Text) 
               and isMutationMatch then
               
                local part = brainrot:FindFirstChildWhichIsA("BasePart")
                if part and part.Parent then
                    Farming = true
                    foundTarget = true
                    
                    SmartTeleport(part.CFrame * CFrame.new(0, -3, 0))
                    
                    if not brainrot or not brainrot.Parent or not part or not part.Parent then
                        Farming = false; break
                    end
                    
                    task.wait(0.1)
                    PressPrompt(brainrot)
                    
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

RightSection:Dropdown({
    Name = "Select Rarity",
    Multi = true, Required = false,
    Options = { "Basic", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Celestial", "Divine" },
    Default = {},
    Callback = function(v)
        SelectedRarities = {}
        for rarity, enabled in pairs(v) do if enabled then table.insert(SelectedRarities, rarity) end end
    end
})

RightSection:Dropdown({
    Name = "Select Mutation",
    Multi = true, Required = false,
    Options = { "Golden", "Diamond", "UFO" },
    Default = {},
    Callback = function(v)
        SelectedMutations = {}
        for mut, enabled in pairs(v) do if enabled then table.insert(SelectedMutations, mut) end end
    end
})

RightSection:Toggle({
    Name = "🤖 AutoFarm",
    Default = false,
    Callback = function(v)
        AutoFarm = v
        Window:Notify({ Title = "System", Description = (v and "Enabled" or "Disabled").." 🤖 AutoFarm", Lifetime = 3 })
    end
})

RightSection:Paragraph({ Header = "Info", Body = "Select rarity/mutation then enable AutoFarm." })

-------------------------------------------------
--// [RIGHT] TRAIT MACHINE
-------------------------------------------------
TraitSection:Header({ Name = "Trait Machine" })

TraitSection:Paragraph({
    Header = "How to use",
    Body = "1. Equip the item you want to trait (Do not hold 'Bat').\n2. Enable Auto Trait.\n3. The script will process the held item and automatically continue with others of the same name."
})

TraitSection:Toggle({
    Name = "Auto Trait",
    Default = false,
    Callback = function(v)
        AutoTrait = v
        Window:Notify({ Title = "System", Description = (v and "Enabled" or "Disabled") .. " Auto Trait", Lifetime = 3 })
        
        if not v then LastItemName = nil end

        if v then
            task.spawn(function()
                while AutoTrait do
                    task.wait(1)
                    local hrp = GetHRP()
                    if not hrp then continue end
                    local char = LocalPlayer.Character

                    local success, timerPart = pcall(function() 
                        return Workspace["Trait Machine"].Billboard.BillboardGui.InUseTimer 
                    end)
                    
                    if success and timerPart then
                        local text = timerPart.Text
                        
                        -- CASE 1: READY
                        if text:find("READY TO COLLECT") then
                            local savePos = hrp.CFrame
                            SmartTeleport(TraitMachineCF)
                            task.wait(0.5)
                            SmartTeleport(savePos)
                            Window:Notify({ Title = "Trait Machine", Description = "Collected!", Lifetime = 3 })
                            task.wait(1)
                            
                        -- CASE 2: WAITING
                        elseif text:find("TIME LEFT") then
                            -- Wait
                            
                        -- CASE 3: IDLE
                        else
                            local toolToEquip = nil
                            
                            -- Check hand first
                            local heldTool = char:FindFirstChildWhichIsA("Tool")
                            if heldTool and heldTool.Name ~= "Bat" then
                                toolToEquip = heldTool
                                LastItemName = heldTool.Name
                            end
                            
                            -- Check backpack if hand empty
                            if not toolToEquip and LastItemName then
                                local nextTool = LocalPlayer.Backpack:FindFirstChild(LastItemName)
                                if nextTool then
                                    char.Humanoid:EquipTool(nextTool)
                                    toolToEquip = nextTool
                                    task.wait(0.5)
                                end
                            end
                            
                            if toolToEquip then
                                local savePos = hrp.CFrame
                                SmartTeleport(TraitMachineCF)
                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TraitMachineStart"):FireServer()
                                task.wait(0.5)
                                SmartTeleport(savePos)
                                Window:Notify({ Title = "Trait Machine", Description = "Processing: " .. toolToEquip.Name, Lifetime = 3 })
                                task.wait(2)
                            end
                        end
                    end
                end
            end)
        end
    end
})

-------------------------------------------------
--// INIT
-------------------------------------------------
MacLib:SetFolder("JumpForBrainrots")
MainTab:Select()
MacLib:LoadAutoLoadConfig()
