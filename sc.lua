-- ═══════════════════════════════════════════════════════════════
-- WISPMANE - ДЛЯ XENO (РАБОЧАЯ ВЕРСИЯ)
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local flyingPlayers = {}
local flySpeeds = {}
local isGUIOpen = {}

-- ВЫРУБКА ЛЕСА
local function chopTrees(btn)
    btn.Text = "⏳..."
    btn.Enabled = false
    local count = 0
    local foliage = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Foliage")
    if foliage then
        for _, obj in ipairs(foliage:GetChildren()) do
            if obj:IsA("Model") and (obj.Name:find("Tree") or obj.Name:find("tree")) then
                pcall(function() 
                    obj:Destroy() 
                    count = count + 1 
                end)
            end
        end
    end
    task.wait(0.5)
    btn.Text = count > 0 and "✅ " .. count or "❌ 0"
    btn.BackgroundColor3 = count > 0 and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    btn.Enabled = true
    task.wait(1.5)
    btn.Text = "🪓 Вырубить лес"
    btn.BackgroundColor3 = Color3.fromRGB(230, 140, 10)
end

-- ПРИТЯГИВАНИЕ ЛУТА
local function magnetLoot(btn, player)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        btn.Text = "❌ Нет персонажа"
        task.wait(1)
        btn.Text = "🧲 Притянуть лут"
        return
    end
    btn.Text = "⏳..."
    btn.Enabled = false
    local target = root.Position + Vector3.new(0, -2, 0)
    local count = 0
    local foliage = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Foliage")
    if foliage then
        for _, obj in ipairs(foliage:GetChildren()) do
            if obj:IsA("Model") and obj.Name:find("Stone") then
                pcall(function()
                    if obj.PrimaryPart then
                        obj:PivotTo(CFrame.new(target + Vector3.new(math.random(-3,3), 0, math.random(-3,3))))
                        count = count + 1
                    end
                end)
            end
        end
    end
    task.wait(0.5)
    btn.Text = count > 0 and "✅ " .. count or "❌ 0"
    btn.BackgroundColor3 = count > 0 and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    btn.Enabled = true
    task.wait(1.5)
    btn.Text = "🧲 Притянуть лут"
    btn.BackgroundColor3 = Color3.fromRGB(40, 180, 130)
end

-- ПРОПУСК ДНЯ
local function skipDay(btn)
    btn.Text = "⏳..."
    btn.Enabled = false
    pcall(function() Lighting.ClockTime = 6 end)
    local function updateDay(container)
        for _, obj in ipairs(container:GetChildren()) do
            for name, value in pairs(obj:GetAttributes()) do
                if name:lower():find("day") and type(value) == "number" then
                    pcall(function() obj:SetAttribute(name, value + 1) end)
                end
            end
            if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                local name = obj.Name:lower()
                if name:find("day") then
                    pcall(function() obj.Value = obj.Value + 1 end)
                end
            end
            if #obj:GetChildren() > 0 then updateDay(obj) end
        end
    end
    updateDay(Workspace)
    updateDay(game:GetService("ReplicatedStorage"))
    updateDay(game:GetService("ServerStorage"))
    task.wait(0.5)
    btn.Text = "✅ Готово!"
    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    btn.Enabled = true
    task.wait(1.5)
    btn.Text = "⌛ Пропустить день"
    btn.BackgroundColor3 = Color3.fromRGB(140, 90, 210)
end

-- СОЗДАНИЕ GUI
local function createGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    local oldGui = playerGui:FindFirstChild("WispManePanel")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WispManePanel"
    screenGui.Parent = playerGui
    screenGui.Enabled = true
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.Parent = screenGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 450)
    main.Position = UDim2.new(0.5, -150, 0.5, -225)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    main.BackgroundTransparency = 0.1
    main.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "✨ WispMane ✨"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = main
    
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -38, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    close.BackgroundTransparency = 0.2
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.TextSize = 16
    close.Font = Enum.Font.GothamBold
    close.Parent = main
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = close
    
    local speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0.8, 0, 0, 35)
    speedInput.Position = UDim2.new(0.1, 0, 0, 55)
    speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    speedInput.BackgroundTransparency = 0.3
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextSize = 14
    speedInput.Font = Enum.Font.Gotham
    speedInput.PlaceholderText = "Скорость..."
    speedInput.Parent = main
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = speedInput
    
    -- Кнопки
    local function createBtn(text, color, y, action)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.8, 0, 0, 40)
        btn.Position = UDim2.new(0.1, 0, 0, y)
        btn.BackgroundColor3 = color
        btn.BackgroundTransparency = 0.15
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.Parent = main
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(action)
        return btn
    end
    
    local speedBtn = createBtn("🚀 Установить скорость", Color3.fromRGB(255, 100, 100), 105, function()
        local speed = tonumber(speedInput.Text)
        if speed and speed > 0 then
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = speed
                    speedDisplay.Text = "Скорость: " .. speed
                    speedBtn.Text = "✅ Готово!"
                    speedBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    task.wait(0.8)
                    speedBtn.Text = "🚀 Установить скорость"
                    speedBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                end
            end
        end
    end)
    
    local flyBtn = createBtn("🕊️ Полет", Color3.fromRGB(80, 150, 255), 155, function()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        if flyingPlayers[player] then
            flyingPlayers[player] = nil
            flySpeeds[player] = nil
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.Velocity = Vector3.new(0, 0, 0) root.CanCollide = true end
            hum.PlatformStand = false
            flyBtn.Text = "🕊️ Полет"
            flyBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
        else
            flyingPlayers[player] = true
            flySpeeds[player] = 50
            hum.PlatformStand = true
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.CanCollide = false end
            flyBtn.Text = "🕊️ Выкл"
            flyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)
    
    local chopBtn = createBtn("🪓 Вырубить лес", Color3.fromRGB(230, 140, 10), 205, function()
        chopTrees(chopBtn)
    end)
    
    local magnetBtn = createBtn("🧲 Притянуть лут", Color3.fromRGB(40, 180, 130), 255, function()
        magnetLoot(magnetBtn, player)
    end)
    
    local skipBtn = createBtn("⌛ Пропустить день", Color3.fromRGB(140, 90, 210), 305, function()
        skipDay(skipBtn)
    end)
    
    local speedDisplay = Instance.new("TextLabel")
    speedDisplay.Size = UDim2.new(0.8, 0, 0, 25)
    speedDisplay.Position = UDim2.new(0.1, 0, 1, -35)
    speedDisplay.BackgroundTransparency = 1
    speedDisplay.TextColor3 = Color3.fromRGB(170, 170, 190)
    speedDisplay.TextSize = 14
    speedDisplay.Font = Enum.Font.Gotham
    speedDisplay.Text = "Скорость: 16"
    speedDisplay.Parent = main
    
    close.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
        isGUIOpen[player] = false
        local wm = playerGui:FindFirstChild("WMButton")
        if wm then wm.Visible = true end
    end)
    
    return screenGui
end

-- КНОПКА WM
local function createWMButton(player)
    local playerGui = player:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild("WMButton")
    if old then old:Destroy() end
    
    local btn = Instance.new("ImageButton")
    btn.Name = "WMButton"
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0.5, -35, 0.5, -35)
    btn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    btn.BackgroundTransparency = 0.2
    btn.Visible = true
    btn.Parent = playerGui
    btn.ZIndex = 100
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "WM"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 24
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        local gui = playerGui:FindFirstChild("WispManePanel")
        if not gui then gui = createGUI(player) end
        gui.Enabled = true
        isGUIOpen[player] = true
        btn.Visible = false
    end)
    
    return btn
end

-- ЗАПУСК
local function setupPlayer(player)
    createGUI(player)
    createWMButton(player)
end

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function() setupPlayer(player) end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not player.PlayerGui:FindFirstChild("WispManePanel") then
            setupPlayer(player)
        end
    end)
end)

-- ПОЛЕТ
RunService.Heartbeat:Connect(function()
    for player, flying in pairs(flyingPlayers) do
        if flying then
            local char = player.Character
            if not char then flyingPlayers[player] = nil return end
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                hum.PlatformStand = true
                root.CanCollide = false
                local speed = flySpeeds[player] or 50
                local dir = Vector3.new(0, 0, 0)
                local cam = Workspace.CurrentCamera
                if cam then
                    local fwd = cam.CFrame.LookVector
                    local rgt = cam.CFrame.RightVector
                    fwd = Vector3.new(fwd.X, 0, fwd.Z).Unit
                    rgt = Vector3.new(rgt.X, 0, rgt.Z).Unit
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + fwd end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - fwd end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - rgt end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + rgt end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                end
                if dir.Magnitude > 0 then
                    dir = dir.Unit * speed
                    root.Velocity = dir
                else
                    root.Velocity = Vector3.new(0, 0.1, 0)
                end
            end
        end
    end
end)

-- ГОРЯЧИЕ КЛАВИШИ
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local player = Players.LocalPlayer
    if not player then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        local gui = player.PlayerGui:FindFirstChild("WispManePanel")
        local wm = player.PlayerGui:FindFirstChild("WMButton")
        if gui and gui.Enabled then
            gui.Enabled = false
            isGUIOpen[player] = false
            if wm then wm.Visible = true end
        else
            if not gui then gui = createGUI(player) end
            gui.Enabled = true
            isGUIOpen[player] = true
            if wm then wm.Visible = false end
        end
    end
end)

print("✅ WispMane загружена!")
print("📌 Кнопка WM или F - открыть меню")
print("📌 X - включить/выключить полет")
print("📌 WASD + Пробел/Shift - управление в полете")
