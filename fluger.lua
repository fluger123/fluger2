local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
if not Rayfield then error("❌ Failed to load Rayfield.") end

-- ====================== KEY SYSTEM ======================
-- 1. Открываем ссылку / копируем
pcall(function()
    game:GetService("GuiService"):OpenBrowserWindow("https://link-center.net/5036727/X8zBeXk36e5F")
end)
pcall(function()
    setclipboard("https://link-center.net/5036727/X8zBeXk36e5F")
end)

-- 2. Загружаем Rayfield ОДИН РАЗ
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- 3. Создаём окно ОДИН РАЗ
local Window = Rayfield:CreateWindow({
    Name = "Example Hub",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Example",
    ConfigurationSaving = { Enabled = true, FileName = "ExampleConfig" },
    KeySystem = true,
    KeySettings = {
        Title = "Activation",
        Subtitle = "Enter your key",
        Note = "Link copied to clipboard!",
        FileName = "MyHubKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"dW3inAtzI6qtC8fyO7zjP9hk"}
    }
})

-- 4. Уведомление с ссылкой
task.wait(1)
Rayfield:Notify({
    Title = "Get your key",
    Content = "https://link-center.net/5036727/X8zBeXk36e5F",
    Duration = 8
})

-- ====================== VARIABLES ======================
local flyActive = false
local flySpeed = 60
local velObj, att, flyConn = nil, nil, nil

local espEnabled = false
local espHighlights = {}

local killAllActive = false
local killAllRadius = 300
local killAllHitboxSize = 350
local killAllThread = nil

local hitboxActive = false
local hitboxSize = 10

-- ====================== FUNCTIONS ======================
local function getHRP()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function enableFly()
    local hrp = getHRP()
    if not hrp then return end
    if att then att:Destroy() end
    if velObj then velObj:Destroy() end

    att = Instance.new("Attachment") att.Parent = hrp
    velObj = Instance.new("LinearVelocity")
    velObj.Attachment0 = att
    velObj.MaxForce = 80000
    velObj.RelativeTo = Enum.ActuatorRelativeTo.World
    velObj.Parent = hrp
    flyActive = true

    flyConn = RunService.RenderStepped:Connect(function()
        if not flyActive then return end
        local move = Vector3.new()
        local look = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
        local right = Vector3.new(Camera.CFrame.RightVector.X, 0, Camera.CFrame.RightVector.Z).Unit

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += look end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= look end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

        velObj.VectorVelocity = move.Magnitude > 0.1 and move.Unit * flySpeed or Vector3.zero
    end)
end

local function disableFly()
    flyActive = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if velObj then velObj:Destroy() velObj = nil end
    if att then att:Destroy() att = nil end
end

local function attachESP(plr)
    if espHighlights[plr] then espHighlights[plr]:Destroy() end
    local char = plr.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0.2
    hl.Adornee = char
    hl.Parent = char
    espHighlights[plr] = hl
end

local function detachESP(plr)
    if espHighlights[plr] then espHighlights[plr]:Destroy() espHighlights[plr] = nil end
end

local function updateESP()
    for plr in pairs(espHighlights) do detachESP(plr) end
    if not espEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then attachESP(plr) end
    end
end

local function getFirstTool()
    local char = LocalPlayer.Character
    if char then local t = char:FindFirstChildOfClass("Tool") if t then return t end end
    return LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
end

local function simulateClick()
    pcall(function()
        local vm = game:GetService("VirtualInputManager")
        vm:SendMouseButtonEvent(0,0,0,true,Workspace,0)
        task.wait(0.10)
        vm:SendMouseButtonEvent(0,0,0,false,Workspace,0)
    end)
end

local function startKillAllLoop()
    if killAllThread then task.cancel(killAllThread) end
    killAllThread = task.spawn(function()
        while killAllActive do
            task.wait(0.07)
            local myHRP = getHRP()
            if not myHRP then continue end

            local equipped = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                local char = plr.Character
                if not char then continue end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                local dist = (myHRP.Position - hrp.Position).Magnitude
                if dist <= killAllRadius then
                    local front = myHRP.CFrame * CFrame.new(0, 0, -2.0)
                    hrp.CFrame = CFrame.new(front.Position)

                    hrp.Size = Vector3.new(killAllHitboxSize, killAllHitboxSize, killAllHitboxSize)
                    hrp.CanCollide = false

                    if not equipped then
                        local tool = getFirstTool()
                        if tool then
                            if tool.Parent ~= LocalPlayer.Character then 
                                tool.Parent = LocalPlayer.Character 
                                task.wait(0.05)
                            end
                            simulateClick()
                            equipped = true
                        end
                    end
                end
            end
        end
    end)
end

local function stopKillAllLoop()
    killAllActive = false
    if killAllThread then task.cancel(killAllThread) killAllThread = nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = Vector3.new(2,2,2) hrp.CanCollide = true end
        end
    end
end

local function updateHitbox()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        if hitboxActive then
            hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            hrp.CanCollide = false
        else
            hrp.Size = Vector3.new(2,2,2)
            hrp.CanCollide = true
        end
    end
end

-- Respawn Fix
local function setupPlayer(plr)
    if plr == LocalPlayer then return end
    local function onCharAdded(char)
        task.wait(0.4)
        if espEnabled then attachESP(plr) end
        if hitboxActive then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                hrp.CanCollide = false
            end
        end
    end
    plr.CharacterAdded:Connect(onCharAdded)
    if plr.Character then onCharAdded(plr.Character) end
end

for _, plr in ipairs(Players:GetPlayers()) do setupPlayer(plr) end
Players.PlayerAdded:Connect(setupPlayer)

-- ====================== TABS ======================
local MovementTab = Window:CreateTab("🚀 Movement", "move")
local RenderTab   = Window:CreateTab("👁️ Render", "eye")
local CombatTab   = Window:CreateTab("⚔️ Combat", "swords")

-- Movement Tab
local FlyToggle = MovementTab:CreateToggle({Name = "Fly", CurrentValue = false, Flag = "FlyToggle", Callback = function(v) flyActive = v if v then enableFly() else disableFly() end end})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {10,150}, Increment = 5, Suffix = " Stud/s", CurrentValue = 60, Callback = function(v) flySpeed = v end})

-- Render Tab
local ESPToggle = RenderTab:CreateToggle({Name = "ESP (All Players)", CurrentValue = false, Flag = "ESPToggle", Callback = function(v) espEnabled = v updateESP() end})

-- Combat Tab
local KillAllToggle = CombatTab:CreateToggle({Name = "💀 Kill All (Teleport)", CurrentValue = false, Flag = "KillAllToggle", Callback = function(v) killAllActive = v if v then startKillAllLoop() else stopKillAllLoop() end end})

CombatTab:CreateSlider({Name = "Kill All Radius", Range = {50,500}, Increment = 10, Suffix = " Studs", CurrentValue = 300, Callback = function(v) killAllRadius = v end})
CombatTab:CreateSlider({Name = "Kill All Hitbox Size", Range = {50,500}, Increment = 10, Suffix = " Studs", CurrentValue = 350, Callback = function(v) killAllHitboxSize = v end})

local HitboxToggle = CombatTab:CreateToggle({Name = "Hitbox Expander", CurrentValue = false, Flag = "HitboxToggle", Callback = function(v) hitboxActive = v updateHitbox() end})
CombatTab:CreateSlider({Name = "Hitbox Size", Range = {2,100}, Increment = 1, Suffix = " Studs", CurrentValue = 10, Callback = function(v) hitboxSize = v if hitboxActive then updateHitbox() end end})

-- ====================== KEYBINDS ======================
MovementTab:CreateKeybind({Name = "Fly Keybind", CurrentKeybind = "F", HoldToInteract = false, Flag = "FlyKeybind", Callback = function() flyActive = not flyActive if flyActive then enableFly() else disableFly() end FlyToggle:Set(flyActive) end})
RenderTab:CreateKeybind({Name = "ESP Keybind", CurrentKeybind = "B", HoldToInteract = false, Flag = "ESPKeybind", Callback = function() espEnabled = not espEnabled updateESP() ESPToggle:Set(espEnabled) end})
CombatTab:CreateKeybind({Name = "Kill All Keybind", CurrentKeybind = "X", HoldToInteract = false, Flag = "KillAllKeybind", Callback = function() killAllActive = not killAllActive if killAllActive then startKillAllLoop() else stopKillAllLoop() end KillAllToggle:Set(killAllActive) end})
CombatTab:CreateKeybind({Name = "Hitbox Keybind", CurrentKeybind = "Z", HoldToInteract = false, Flag = "HitboxKeybind", Callback = function() hitboxActive = not hitboxActive updateHitbox() HitboxToggle:Set(hitboxActive) end})

task.delay(2, function() Rayfield:LoadConfiguration() end)