--[[
    --------------------------------------------------------------------
    SCRIPT NAME: Auto Farm Wire + Auto Eat & Universal + Aimbot
    AUTHOR: Gzuss
    FRAMEWORK: Fluent UI
    --------------------------------------------------------------------
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "เเมพอะไรไม่รู้ทำๆไปก่อน",
    SubTitle = "By Gzuss",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
	Food = Window:AddTab({ Title = "Food", Icon = "apple" }),
	Teleport = Window:AddTab({ Title = "Teleport", Icon = "activity" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

--[[ 
    --------------------------------------------------------------------
    SECTION: VARIABLES & CONFIG (WIRE FARM & AIMBOT)
    --------------------------------------------------------------------
]]

local WireCFrame = CFrame.new(787.51062, 9.09802723, 227.773956, 0.0442603081, 3.76006142e-08, 0.99902004, -6.2313525e-08, 1, -3.4876777e-08, -0.99902004, -6.07087998e-08, 0.0442603081)
local SafeZoneCFrame = CFrame.new(362.557129, 371.35791, 618.62616, 0.998580813, -0.00436378922, 0.0530778803, 6.40599529e-09, 0.996637404, 0.0819382593, -0.0532569587, -0.0818219781, 0.995223045)
local CementCFrame = CFrame.new(-356.902191, 85.5697861, -344.235657, 0.997619927, 3.93320327e-08, -0.0689524263, -3.97723987e-08, 1, -5.01370145e-09, 0.0689524263, 7.74417241e-09, 0.997619927)
local CementInteractPart = workspace.Robberies.Objects:GetChildren()[5].Interact.Interaction
local InteractPart = workspace:WaitForChild("Robberies"):WaitForChild("Objects"):WaitForChild("Wire"):WaitForChild("Interact")

local AimbotConfig = {
    Enabled = false,
    FOV = 150,
    ShowFOV = true,
    SelectedPlayer = nil
}

--[[ 
    --------------------------------------------------------------------
    SECTION: GUI SETUP FOR AIMBOT (MOBILE FRIENDLY)
    --------------------------------------------------------------------
]]

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "MobileFOV"
FOVGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or (CoreGui:FindFirstChild("RobloxGui") or LocalPlayer.PlayerGui)

local FOVFrame = Instance.new("Frame")
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Parent = FOVGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 50, 50)
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVFrame

local MobileBtnGui = Instance.new("ScreenGui")
MobileBtnGui.Name = "MobileToggleBtn"
MobileBtnGui.Parent = FOVGui.Parent

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 120, 0, 50)
ToggleBtn.Position = UDim2.new(0.8, 0, 0.7, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "AIM: OFF"
ToggleBtn.Parent = MobileBtnGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

-- ฟังก์ชันเมื่อกดปุ่มลอยหน้าจอ
ToggleBtn.MouseButton1Click:Connect(function()
    AimbotConfig.Enabled = not AimbotConfig.Enabled
    if AimbotConfig.Enabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        ToggleBtn.Text = "AIM: ON"
        FOVStroke.Color = Color3.fromRGB(0, 255, 0)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        ToggleBtn.Text = "AIM: OFF"
        FOVStroke.Color = Color3.fromRGB(255, 50, 50)
    end
end)

--[[ 
    --------------------------------------------------------------------
    SECTION: FUNCTIONS
    --------------------------------------------------------------------
]]

local function Micromove(char)
    if char and char:FindFirstChild("Humanoid") then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- ขยับไปข้างหน้านิดนึง แล้วถอยกลับ
            local startPos = hrp.Position
            char.Humanoid:MoveTo(startPos + Vector3.new(0, 0, 1))
            task.wait(0.1)
            char.Humanoid:MoveTo(startPos)
            task.wait(0.1)
        end
    end
end

local function TeleportTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end
end

local function LockCharacter(state)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = state
        end
    end)
end

local function CheckWanted()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        if LocalPlayer.Character.Head:FindFirstChild("Wanted") then
            return true
        end
    end
    return false
end

local function CreateAirRoom()
    local folderName = "Gzuss_SafeZone_Room"
    if workspace:FindFirstChild(folderName) then 
        workspace[folderName]:Destroy()
    end
    local folder = Instance.new("Folder")
    folder.Name = folderName
    folder.Parent = workspace
    
    local function createWall(size, offset)
        local part = Instance.new("Part")
        part.Size = size
        part.CFrame = SafeZoneCFrame * CFrame.new(offset)
        part.Anchored = true
        part.CanCollide = true
        part.Transparency = 1 
        part.Material = Enum.Material.SmoothPlastic
        part.Parent = folder
        return part
    end

    local thickness = 1
    local width = 10
    local height = 10

    createWall(Vector3.new(width, thickness, width), Vector3.new(0, -height/2, 0))
    createWall(Vector3.new(width, thickness, width), Vector3.new(0, height/2, 0))
    createWall(Vector3.new(thickness, height, width), Vector3.new(width/2, 0, 0)) 
    createWall(Vector3.new(thickness, height, width), Vector3.new(-width/2, 0, 0)) 
    createWall(Vector3.new(width, height, thickness), Vector3.new(0, 0, width/2)) 
    createWall(Vector3.new(width, height, thickness), Vector3.new(0, 0, -width/2)) 
end

-- Aimbot: หาคนใกล้เป้า
local function GetClosestPlayerToCenter()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
            if plr.Character.Humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < AimbotConfig.FOV and dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = plr
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Aimbot & FOV Loop
RunService.RenderStepped:Connect(function()
    if AimbotConfig.ShowFOV then
        FOVFrame.Size = UDim2.new(0, AimbotConfig.FOV * 2, 0, AimbotConfig.FOV * 2)
        FOVFrame.Visible = true
    else
        FOVFrame.Visible = false
    end

    if AimbotConfig.Enabled then
        local target = GetClosestPlayerToCenter()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)

--[[ 
    --------------------------------------------------------------------
    SECTION: 1. MAIN TAB (WIRE & POLICE)
    --------------------------------------------------------------------
]]

Tabs.Main:AddSection("⚠️ Criminal")

local StatusLabel = Tabs.Main:AddParagraph({ Title = "Current Status", Content = "ปิดการใช้งาน" })

-- เพิ่ม Dropdown ให้เลือกงาน
local FarmTargetDropdown = Tabs.Main:AddDropdown("FarmTarget", {
    Title = "Farm Target",
    Description = "เลือกว่าจะฟาร์มอะไร 🚷",
    Values = {"ตัดสายไฟ", "จกปูน"},
    Multi = false,
    Default = "ตัดสายไฟ"
})

local ToggleFarm = Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm", 
    Description = "ฟาร์มงานผิดกฎหมายแบบออโต้ ปล่อย AFK ได้ชิลๆ 💸",
    Default = false 
})

-- ==========================================
-- 3. ระบบทำงาน (Loop)
-- ==========================================
ToggleFarm:OnChanged(function()
    if Options.AutoFarm.Value then
        CreateAirRoom()
    end
    
    task.spawn(function()
        while Options.AutoFarm.Value do
            pcall(function()
                if CheckWanted() then
                    -- ===============================
                    -- ระบบหนีตำรวจ (เหมือนเดิม)
                    -- ===============================
                    StatusLabel:SetDesc("Status: ตำรวจกำลังมา! 🚨 กำลังหนี...")
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    LockCharacter(false)
                    
                    TeleportTo(SafeZoneCFrame)
                    task.wait(0.1) 
                    Micromove(LocalPlayer.Character)
                    
                    LockCharacter(true)
                    
                    repeat
                        if not Options.AutoFarm.Value then break end
                        TeleportTo(SafeZoneCFrame)
                        StatusLabel:SetDesc("Status: กำลังซ่อนตัว... ⏳")
                        task.wait(1)
                    until not CheckWanted()
                    
                    LockCharacter(false)
                    StatusLabel:SetDesc("Status: ทางสะดวก! ✅ กำลังกลับไปทำงาน...")
                    task.wait(1)
                else
                    -- ===============================
                    -- ระบบทำงาน (เช็คว่าเลือกอะไรไว้)
                    -- ===============================
                    local selectedJob = Options.FarmTarget.Value
                    local targetCFrame = nil
                    local interactPart = nil
                    local jobName = ""
                    local actionName = ""
                    
                    -- กำหนดค่าตามงานที่เลือก
                    if selectedJob == "ตัดสายไฟ" then
                        targetCFrame = WireCFrame
                        interactPart = InteractPart -- ใช้ตัวแปรเก่าของคุณ
                        jobName = "จุดตัดสายไฟ"
                        actionName = "ตัดสายไฟ"
                    elseif selectedJob == "จกปูน" then
                        targetCFrame = CementCFrame
                        interactPart = CementInteractPart
                        jobName = "กองปูน"
                        actionName = "จกปูน"
                    end
                    
                    if targetCFrame and interactPart then
                        StatusLabel:SetDesc("Status: กำลังไป " .. jobName .. "... 📍")
                        LockCharacter(false)
                        
                        -- วาร์ปไปจุดเป้าหมาย
                        TeleportTo(targetCFrame)
                        task.wait(0.1)
                        Micromove(LocalPlayer.Character)
                        task.wait(0.4) 
                        
                        StatusLabel:SetDesc("Status: กำลัง " .. actionName .. "... ⚡ (ล็อคตัว)")
                        LockCharacter(true)
                        
                        -- กดปุ่ม E ค้างไว้ (Prompt 10 วิ)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        
                        -- Loop รอเวลา 10 วิ (21 * 0.5 = 10.5 วิ เผื่อเวลาไว้หน่อย)
                        for i = 1, 21 do 
                            if not Options.AutoFarm.Value then break end
                            if CheckWanted() then 
                                StatusLabel:SetDesc("Status: เสร็จแล้ว! 💨")
                                break 
                            end
                            task.wait(0.5)
                        end
                        
                        -- ปล่อยปุ่ม E
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        LockCharacter(false)
                        task.wait(0.5)
                    else
                        StatusLabel:SetDesc("Status: ไม่เจอ " .. jobName .. " ❌ ")
                        task.wait(1)
                    end
                end
            end)
            task.wait(0.5)
        end
        -- จบการทำงาน (ปิด Toggle)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        LockCharacter(false)
        StatusLabel:SetDesc("Status: Idle")
    end)
end)

Tabs.Main:AddSection("🧍 Gitizen")

Tabs.Main:AddSection("👮 Police ( Aimbot )")

local AimbotToggle = Tabs.Main:AddToggle("AimbotMenuToggle", {
    Title = "Aimbot",
	Description = "เอาไว้เปิดปิด ล็อก 🎯",
    Default = false 
})

AimbotToggle:OnChanged(function(Value)
    AimbotConfig.Enabled = Value
    if Value then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        ToggleBtn.Text = "AIM: ON"
        FOVStroke.Color = Color3.fromRGB(0, 255, 0)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        ToggleBtn.Text = "AIM: OFF"
        FOVStroke.Color = Color3.fromRGB(255, 50, 50)
    end
end)

Tabs.Main:AddKeybind("AimbotKey", {
    Title = "PC Hotkey",
	Description = "ตั้งค่าปุ่มคีย์ลัดสำหรับคนเล่นในคอม ⌨️",
    Mode = "Toggle",
    Default = "",
    Callback = function(Value)
        AimbotToggle:SetValue(Value)
    end
})

Tabs.Main:AddSlider("FOVSize", {
    Title = "FOV Radius",
	Description = "ปรับขนาดเป้าได้เท่าที่ต้องการ",
    Default = 150, 
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) AimbotConfig.FOV = Value end
})

Tabs.Main:AddToggle("ShowFOV", {
    Title = "Show FOV Circle",
	Description = "เเสดงขอบเขตล็อกเป้า FOV", 
    Default = false 
}):OnChanged(function(Value)
    AimbotConfig.ShowFOV = Value
end)

Tabs.Main:AddToggle("ShowMobileBtn", {
    Title = "Show Floating Button", 
	Description = "เเสดงปุ่มลอย สำหรับคนที่เล่นในมือถือ 📱",
    Default = false 
}):OnChanged(function(Value)
    ToggleBtn.Visible = Value
end)


--[[ 
    --------------------------------------------------------------------
    SECTION: 2. PLAYER TAB (FOOD & EAT & UNIVERSAL)
    --------------------------------------------------------------------
]]

local ShopPayloads = {
    ["หมูปิ้ง"] = "\224\184\171\224\184\161\224\184\185\224\184\155\224\184\180\224\185\137\224\184\135",
    ["ข้าวจี่"] = "\224\184\130\224\185\137\224\184\178\224\184\167\224\184\136\224\184\181\224\185\136",
    ["ข้าวเหนียว"] = "\224\184\130\224\185\137\224\184\178\224\184\167\224\185\128\224\184\171\224\184\153\224\184\181\224\184\162\224\184\167",
    ["น้ำมะพร้าว"] = "\224\184\153\224\185\137\224\184\1กำ\224\184\161\224\184\176\224\184\158\224\184\163\224\185\137\224\184\178\224\184\167",
    ["โค้ก"] = "\224\185\130\224\184\132\224\185\137\224\184\129",
    ["น้ำแดงโซดา"] = "\224\184\153\224\185\141\224\185\137\224\184\178\224\185\129\224\184\148\224\184\135\224\185\130\224\184\139\224\184\148\224\184\178",
    ["น้ำเขียวโซดา"] = "\224\184\153\224\185\141\224\185\137\224\184\178\224\185\128\224\184\130\224\184\181\224\184\162\224\184\167\224\185\130\224\184\139\224\184\148\224\184\178"
}

-- >> อาหาร (Food) <<
Tabs.Food:AddSection("🍔 Buy Food")

local BuyDropdown = Tabs.Food:AddDropdown("BuyFoodList", {
    Title = "เลือกอาหารที่จะซื้อ",
    Description = "สามารถเลือกได้หลายอัน",
    Values = {"หมูปิ้ง", "ข้าวจี่", "ข้าวเหนียว", "น้ำมะพร้าว", "โค้ก", "น้ำแดงโซดา", "น้ำเขียวโซดา"},
    Multi = true,
    Default = {}
})

Tabs.Food:AddButton({
    Title = "Buy",
	Description = "ซื้อของที่เลือก 🛒",
    Callback = function()
        local selected = Options.BuyFoodList.Value
        if not selected then return end
        
        for itemName, isSelected in pairs(selected) do
            if isSelected and ShopPayloads[itemName] then
                pcall(function()
                    local args = { "BuyProduct", ShopPayloads[itemName] }
                    LocalPlayer.PlayerGui:WaitForChild("Interface Group").Network:InvokeServer(unpack(args))
                end)
            end
        end
        Fluent:Notify({ Title = "Success", Content = "สั่งซื้อสำเร็จ!", Duration = 2 })
    end
})

-- >> กินออโต้ (Auto Eat) <<
Tabs.Food:AddSection("🍽️ Auto Eat")

local EatStatus = Tabs.Food:AddParagraph({ Title = "Status", Content = "หิว: --% | น้ำ: --%" })

local EatFoodDrop = Tabs.Food:AddDropdown("AutoEatFood", {
    Title = "เลือกอาหาร (Food)",
    Values = {"หมูปิ้ง", "ข้าวจี่", "ข้าวเหนียว"},
    Multi = false,
    Default = "หมูปิ้ง"
})

local EatWaterDrop = Tabs.Food:AddDropdown("AutoEatWater", {
    Title = "เลือกน้ำ (Water)",
    Values = {"น้ำมะพร้าว", "โค้ก", "น้ำแดงโซดา", "น้ำเขียวโซดา"},
    Multi = false,
    Default = "โค้ก"
})

local FoodLimit = Tabs.Food:AddInput("FoodPercent", {
    Title = "กินเมื่อหิวน้อยกว่า (%)",
    Default = "30",
    Numeric = true,
    Finished = false
})

local WaterLimit = Tabs.Food:AddInput("WaterPercent", {
    Title = "ดื่มเมื่อน้ำน้อยกว่า (%)",
    Default = "30",
    Numeric = true,
    Finished = false
})

local ToggleEat = Tabs.Food:AddToggle("AutoEatToggle", { 
	Title = "Auto Eat", 
	Description = "กินอาหารอ้อโต้ 🍽️",
	Default = false })

local ToggleAutoBuy = Tabs.Food:AddToggle("AutoBuyMissing", { 
    Title = "Auto Buy", 
    Description = "ถ้าถึงเวลากินแต่ของในตัวไม่มี มันจะกดซื้อให้ 1 ชิ้นแล้วกิน 🛒",
    Default = false 
})

local function GetHealthPercent(statType)
    local percent = 100 
    pcall(function()
        local text = ""
        if statType == "Food" then
            text = LocalPlayer.PlayerGui.Health.Food.Percent.Text
        else
            text = LocalPlayer.PlayerGui.Health.Drink.Percent.Text
        end
        
        local num = string.match(text, "%d+")
        if num then
            percent = tonumber(num)
        end
    end)
    return percent
end

local function HasItem(itemName)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild(itemName) then return true end
    if char and char:FindFirstChild(itemName) then return true end
    return false
end

local function BuySingleItem(itemName)
    if ShopPayloads[itemName] then
        pcall(function()
            local args = { "BuyProduct", ShopPayloads[itemName] }
            LocalPlayer.PlayerGui:WaitForChild("Interface Group").Network:InvokeServer(unpack(args))
        end)
    end
end

local function EquipAndEat(itemName)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return end
    
    local tool = backpack:FindFirstChild(itemName) or char:FindFirstChild(itemName)
    if tool and tool:IsA("Tool") then
        char.Humanoid:EquipTool(tool)
        task.wait(0.2)
        tool:Activate()
        task.wait(1) 
    end
end

ToggleEat:OnChanged(function()
    task.spawn(function()
        while Options.AutoEatToggle.Value do
            pcall(function()
                local currentFood = GetHealthPercent("Food")
                local currentWater = GetHealthPercent("Water")
                
                local foodTarget = tonumber(Options.FoodPercent.Value) or 0
                local waterTarget = tonumber(Options.WaterPercent.Value) or 0
                
                local foodName = Options.AutoEatFood.Value
                local waterName = Options.AutoEatWater.Value
                
                EatStatus:SetDesc("🍔 หิว: " .. currentFood .. "% | 💧 น้ำ: " .. currentWater .. "%")
                
                if currentFood <= foodTarget then
                    if not HasItem(foodName) and Options.AutoBuyMissing.Value then
                        BuySingleItem(foodName)
                        task.wait(0.5) 
                    end
                    EquipAndEat(foodName)
                end
                
                if currentWater <= waterTarget then
                    if not HasItem(waterName) and Options.AutoBuyMissing.Value then
                        BuySingleItem(waterName)
                        task.wait(0.5) 
                    end
                    EquipAndEat(waterName)
                end
            end)
            task.wait(2) 
        end
        EatStatus:SetDesc("สถานะ: ปิดใช้งาน")
    end)
end)

-- Tab Teleport
local NpcLocations = {
    ["ตัดกล้วย"] = CFrame.new(166.670654, 9.60753155, 238.960678, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["ก่อสร้าง"] = CFrame.new(275.152039, 9.7319231, 132.781982, 0, -2.91038305e-11, 1.00000012, 0.000488311052, 0.999999881, -2.91038305e-11, -0.99999994, 0.000488311052, 0),
    ["ขนส่ง"] = CFrame.new(364.283295, 11.003438, 144.337234, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["พระ"] = CFrame.new(593.34137, 8.55815315, 302.013214, 0.999982774, 0.00586987333, 0, -0.00586987333, 0.999982774, -0, -0, 0, 1),
    ["ตำรวจ"] = CFrame.new(57.5281067, 11.503459, 161.487122, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    ["พนักงานเซเว่น"] = CFrame.new(193.805405, 10.1315899, 108.863876, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

Tabs.Teleport:AddSection("📍 NPC Teleport")

local NpcDropdown = Tabs.Teleport:AddDropdown("SelectNpc", {
    Title = "Select NPC",
    Description = "เลือกตัวละคร NPC ที่ต้องการวาร์ปไปหา",
    Values = {"ตัดกล้วย", "ก่อสร้าง", "ขนส่ง", "พระ", "ตำรวจ", "พนักงานเซเว่น"},
    Multi = false,
    Default = "ตัดกล้วย"
})

Tabs.Teleport:AddButton({
    Title = "Teleport to NPC",
    Description = "กดยืนยันเพื่อวาร์ปไปยังตำแหน่ง NPC 🧍",
    Callback = function()
        local selectedNpc = Options.SelectNpc.Value
        if selectedNpc and NpcLocations[selectedNpc] then
            TeleportTo(NpcLocations[selectedNpc])
        end
    end
})

-- >> ซีเล็คชั่น 2: Player <<
Tabs.Teleport:AddSection("👤 Player Teleport")

-- ฟังก์ชันดึงชื่อผู้เล่นทั้งหมดในแมพ (ไม่รวมตัวเอง)
local function GetPlayerList()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    return list
end

local PlayerDropdown = Tabs.Teleport:AddDropdown("SelectPlayer", {
    Title = "Select Player",
    Description = "เลือกชื่อผู้เล่นเป้าหมายในเซิร์ฟเวอร์",
    Values = GetPlayerList(),
    Multi = false,
    Default = ""
})

Tabs.Teleport:AddButton({
    Title = "Refresh Player List",
    Description = "อัปเดตรายชื่อผู้เล่นล่าสุดในเซิร์ฟเวอร์",
    Callback = function()
        PlayerDropdown:SetValues(GetPlayerList())
        Fluent:Notify({ Title = "Refreshed", Content = "อัปเดตรายชื่อผู้เล่นแล้ว", Duration = 2 })
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Player",
    Description = "วาร์ปไปด้านหลังของผู้เล่นที่เลือก 👥",
    Callback = function()
        local selectedPlayerName = Options.SelectPlayer.Value
        if selectedPlayerName and selectedPlayerName ~= "" then
            local targetPlayer = Players:FindFirstChild(selectedPlayerName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- วาร์ปไปด้านหลังเป้าหมายนิดนึง จะได้ไม่สิงกัน
                local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                TeleportTo(targetCFrame * CFrame.new(0, 0, 3))
            else
                Fluent:Notify({ Title = "Error", Content = "หาตัวผู้เล่นไม่เจอ (อาจจะตายหรือออกเกมไปแล้ว)", Duration = 3 })
            end
        else
            Fluent:Notify({ Title = "Warning", Content = "กรุณาเลือกผู้เล่นก่อนวาร์ป", Duration = 2 })
        end
    end
})

-- >> ผู้เล่น (Universal) <<
Tabs.Player:AddSection("🏃‍♂️ Universal")

Tabs.Player:AddSlider("WalkSpeed", {
    Title = "ความเร็วเดิน (WalkSpeed)",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "กระโดดสูง (JumpPower)",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

local InfJump = Tabs.Player:AddToggle("InfJump", { Title = "กระโดดไม่จำกัด (Infinite Jump)", Default = false })
UserInputService.JumpRequest:Connect(function()
    if Options.InfJump.Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Tabs.Player:AddSection("👁️ ESP")

-- ตั้งค่าทีมและสี
if _G.ClearOldESP then
    _G.ClearOldESP()
end

local ESP_Cache = {} -- ตารางสำหรับจำค่า ESP จะได้ไม่กระพริบ
local EspConnection = nil

-- ฟังก์ชันเคลียร์ ESP รายบุคคล
local function RemoveESP(plr)
    if ESP_Cache[plr] then
        if ESP_Cache[plr].Highlight then ESP_Cache[plr].Highlight:Destroy() end
        if ESP_Cache[plr].NameTag then ESP_Cache[plr].NameTag:Destroy() end
        ESP_Cache[plr] = nil
    end
    -- ดักจับเผื่อมีของเก่าหลงเหลืออยู่ในตัวละคร
    if plr.Character then
        local oldH = plr.Character:FindFirstChild("ESPHighlight")
        local oldN = plr.Character:FindFirstChild("ESPNameTag")
        if oldH then oldH:Destroy() end
        if oldN then oldN:Destroy() end
    end
end

-- ฟังก์ชันสำหรับล้างทุกอย่าง (ใช้ตอนปิด Toggle หรือตอนรันสคริปต์ใหม่)
_G.ClearOldESP = function()
    if EspConnection then
        EspConnection:Disconnect()
        EspConnection = nil
    end
    for _, plr in pairs(Players:GetPlayers()) do
        RemoveESP(plr)
    end
end

-- ==========================================
-- 2. การตั้งค่า UI
-- ==========================================
local EspSettings = {
    ["โจร"] = { TeamName = "Criminal", Color = Color3.fromRGB(255, 0, 0) }, -- แดง
    ["ตำรวจ"] = { TeamName = "ตำรวจ", Color = Color3.fromRGB(0, 0, 255) }, -- น้ำเงิน
    ["พนักงานขนส่ง"] = { TeamName = "พนักงานขนส่ง", Color = Color3.fromRGB(255, 128, 0) }, -- ส้ม
    ["คนงานก่อสร้าง"] = { TeamName = "คนงานก่อสร้าง", Color = Color3.fromRGB(128, 128, 128) }, -- เทา
    ["คนตัดกล้วย"] = { TeamName = "คนตัดกล้วย", Color = Color3.fromRGB(255, 255, 0) }, -- เหลือง
    ["พนักงานเซเว่น"] = { TeamName = "พนักงานเซเว่น", Color = Color3.fromRGB(0, 255, 255) }, -- ฟ้าสว่าง
    ["ประชาชน"] = { TeamName = "Citizen", Color = Color3.fromRGB(0, 255, 0) }, -- เขียว
    ["นักโทษ"] = { TeamName = "Prisoner", Color = Color3.fromRGB(128, 0, 128) } -- ม่วง
}

local EspDropdown = Tabs.Player:AddDropdown("ESPTargets", {
    Title = "Select Teams",
    Description = "สามารถเลือกได้หลายอันพร้อมกัน 👫",
    Values = {"โจร", "ตำรวจ", "พนักงานขนส่ง", "คนงานก่อสร้าง", "คนตัดกล้วย", "พนักงานเซเว่น", "ประชาชน", "นักโทษ"},
    Multi = true,
    Default = {}
})

local ToggleESP = Tabs.Player:AddToggle("ESPToggle", { 
    Title = "ESP ", 
    Description = "เปิดมองทะลุ 👁️",
    Default = false 
})

-- ==========================================
-- 3. ระบบอัปเดต ESP (ไม่กระพริบ & สีไม่ตีกัน)
-- ==========================================
local function UpdateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        
        -- ถ้าตัวละครยังไม่โหลด หรือตาย ให้ลบ ESP ซ่อนไปก่อน
        if not char or not root or not head then
            RemoveESP(plr)
            continue
        end

        local isTarget = false
        local targetColor = Color3.new(1, 1, 1)
        local teamName = "Unknown"

        -- เช็คเงื่อนไขทีมที่เลือก
        if Options.ESPTargets.Value and plr.Team then
            for name, isSelected in pairs(Options.ESPTargets.Value) do
                if isSelected and EspSettings[name] and plr.Team.Name == EspSettings[name].TeamName then
                    isTarget = true
                    targetColor = EspSettings[name].Color
                    teamName = name
                    break -- เจอทีมปุ๊บ หยุดหาเลย (แก้ปัญหาสีแทรกกัน)
                end
            end
        end

        if isTarget then
            -- ถ้ายังไม่มี ESP ใน Cache ให้สร้างใหม่แค่ครั้งเดียว
            if not ESP_Cache[plr] then
                ESP_Cache[plr] = {}
                
                -- สร้าง Highlight
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillTransparency = 0.3
                highlight.OutlineTransparency = 0 
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = char
                ESP_Cache[plr].Highlight = highlight

                -- สร้าง NameTag
                local nameTag = Instance.new("BillboardGui")
                nameTag.Name = "ESPNameTag"
                nameTag.Size = UDim2.new(0, 200, 0, 50)
                nameTag.StudsOffset = Vector3.new(0, -3.5, 0)
                nameTag.AlwaysOnTop = true 
                nameTag.Parent = char
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "NameText"
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextScaled = false
                textLabel.TextSize = 13
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextStrokeTransparency = 0 
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0) 
                textLabel.RichText = true 
                textLabel.Parent = nameTag
                
                ESP_Cache[plr].NameTag = nameTag
            end

            local cache = ESP_Cache[plr]
            
            -- อัปเดต Parent กรณีผู้เล่นรีเซ็ตตัวละคร
            if cache.Highlight.Parent ~= char then cache.Highlight.Parent = char end
            if cache.NameTag.Parent ~= char then cache.NameTag.Parent = char end

            -- อัปเดตสี
            cache.Highlight.FillColor = targetColor
            cache.Highlight.OutlineColor = targetColor

            -- คำนวณระยะทาง
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = 0
            if myRoot then
                dist = math.floor((myRoot.Position - root.Position).Magnitude)
            end

            -- แปลงสีและใส่ข้อมูลลง NameTag
            local r = math.floor(targetColor.R * 255)
            local g = math.floor(targetColor.G * 255)
            local b = math.floor(targetColor.B * 255)
            local hexTeamColor = string.format("#%02X%02X%02X", r, g, b)
            local hexPlayerColor = "#FFFFFF"
            local hexDistColor = "#FFFF00"
            
            if cache.NameTag:FindFirstChild("NameText") then
                cache.NameTag.NameText.Text = string.format(
                    '<font color="%s">[%s]</font> <font color="%s">%s</font>\n<font color="%s">%d M.</font>', 
                    hexTeamColor, teamName, hexPlayerColor, plr.Name, hexDistColor, dist
                )
            end
        else
            -- ถ้าไม่ได้เลือกทีมนั้นแล้ว ให้ลบ ESP ทิ้ง
            RemoveESP(plr)
        end
    end
end

-- ==========================================
-- 4. ควบคุมปุ่มเปิดปิด
-- ==========================================
ToggleESP:OnChanged(function()
    local enabled = Options.ESPToggle.Value

    -- เรียกล้างค่าทุกครั้งก่อนสลับโหมด
    _G.ClearOldESP()

    if enabled then
        -- ใช้ RenderStepped เรียก UpdateESP
        EspConnection = RunService.RenderStepped:Connect(UpdateESP)
    end
end)

--[[ 
    --------------------------------------------------------------------
    SECTION: FINAL SETUP
    --------------------------------------------------------------------
]]

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

Fluent:Notify({ Title = "Script Loaded", Content = "Enjoy Auto Farm & Eat!", Duration = 5 })
