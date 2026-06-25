-- ═══════════════════════════════════════════════════════════════
-- WISPMANE ADMIN - 99 NIGHTS IN THE FOREST (РАБОЧАЯ ВЕРСИЯ)
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- ═══════════════════════════════════════════════════════════════
-- ГЛОБАЛЬНЫЕ ДАННЫЕ
-- ═══════════════════════════════════════════════════════════════

local flyingPlayers = {}
local flySpeeds = {}
local playerGUIs = {}
local isGUIOpen = {}

-- ═══════════════════════════════════════════════════════════════
-- ФУНКЦИЯ ВЫРУБКИ ЛЕСА (РАБОТАЕТ!)
-- ═══════════════════════════════════════════════════════════════

local function chopAllTrees(player, button)
    local character = player.Character
    if not character then
        button.Text = "❌ Нет персонажа!"
        task.wait(1)
        button.Text = "🪓 Вырубить лес"
        return
    end
    
    button.Text = "⏳ Вырубка..."
    button.BackgroundColor3 = Color3.fromRGB(150, 100, 20)
    button.Enabled = false
    
    local count = 0
    local foliage = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Foliage")
    
    if foliage then
        -- Ищем деревья в папке Foliage
        for _, obj in ipairs(foliage:GetChildren()) do
            local name = obj.Name:lower()
            -- Все деревья: TreeBig1, TreeBig2, Small Tree и т.д.
            if name:find("tree") or name:find("small tree") then
                pcall(function()
                    obj:Destroy()
                    count = count + 1
                end)
            end
        end
    end
    
    -- Если не нашли в Foliage, ищем везде
    if count == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local name = obj.Name:lower()
                if name:find("tree") and not name:find("mother") and not name:find("giant") then
                    pcall(function()
                        obj:Destroy()
                        count = count + 1
                    end)
                end
            end
        end
    end
    
    task.wait(0.5)
    
    if count > 0 then
        button.Text = "✅ Срублено: " .. count
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        button.Text = "❌ Деревья не найдены!"
        button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    button.Enabled = true
    task.wait(1.5)
    button.Text = "🪓 Вырубить лес"
    button.BackgroundColor3 = Color3.fromRGB(230, 140, 10)
end

-- ═══════════════════════════════════════════════════════════════
-- ФУНКЦИЯ ПРИТЯГИВАНИЯ ЛУТА (РАБОТАЕТ!)
-- ═══════════════════════════════════════════════════════════════

local function magnetAllLoot(player, button)
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then
        button.Text = "❌ Нет персонажа!"
        task.wait(1)
        button.Text = "🧲 Притянуть лут"
        return
    end
    
    button.Text = "⏳ Поиск лута..."
    button.BackgroundColor3 = Color3.fromRGB(20, 120, 90)
    button.Enabled = false
    
    local targetPos = rootPart.Position + Vector3.new(0, -2, 0)
    local count = 0
    local items = {}
    
    -- Ищем ресурсы в Foliage
    local foliage = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Foliage")
    
    if foliage then
        for _, obj in ipairs(foliage:GetChildren()) do
            if obj:IsA("Model") then
                local name = obj.Name:lower()
                -- Камни, ресурсы, предметы
                if name:find("stone") or name:find("rock") or name:find("log") or 
                   name:find("wood") or name:find("stick") or name:find("branch") or
                   name:find("berry") or name:find("sapling") or name:find("item") then
                    table.insert(items, obj)
                end
            end
        end
    end
    
    -- Ищем по всему миру (дополнительно)
    if #items == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if name:find("stone") or name:find("rock") or name:find("log") or 
                   name:find("wood") or name:find("stick") or name:find("berry") or
                   name:find("sapling") or name:find("item") then
                    if obj.Parent and obj.Parent ~= character then
                        table.insert(items, obj)
                    end
                end
            end
        end
    end
    
    -- Телепортируем предметы
    for _, item in ipairs(items) do
        pcall(function()
            if item and item.Parent then
                local offset = Vector3.new(
                    math.random(-3, 3),
                    math.random(0, 2),
                    math.random(-3, 3)
                )
                
                if item:IsA("Model") and item.PrimaryPart then
                    item:PivotTo(CFrame.new(targetPos + offset))
                    count = count + 1
                elseif item:IsA("BasePart") then
                    item.CFrame = CFrame.new(targetPos + offset)
                    count = count + 1
                end
            end
        end)
    end
    
    task.wait(0.5)
    
    if count > 0 then
        button.Text = "✅ Собрано: " .. count
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        button.Text = "❌ Лут не найден!"
        button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    button.Enabled = true
    task.wait(1.5)
    button.Text = "🧲 Притянуть лут"
    button.BackgroundColor3 = Color3.fromRGB(40, 180, 130)
end

-- ═══════════════════════════════════════════════════════════════
-- ФУНКЦИЯ ПРОПУСКА ДНЯ (РАБОТАЕТ!)
-- ═══════════════════════════════════════════════════════════════

local function skipOneDay(player, button)
    button.Text = "⏳ Перемотка..."
    button.BackgroundColor3 = Color3.fromRGB(100, 60, 160)
    button.Enabled = false
    
    -- Меняем время суток
    pcall(function()
        Lighting.ClockTime = 6
        Lighting.TimeOfDay = "06:00:00"
    end)
    
    local success = false
    local dayValue = 0
    
    -- Ищем день в игре
    local function findAndUpdateDay(container)
        for _, obj in ipairs(container:GetChildren()) do
            -- Проверяем IntValue и NumberValue
            if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                local name = obj.Name:lower()
                if name == "day" or name == "currentday" or name == "days" then
                    pcall(function()
                        obj.Value = obj.Value + 1
                        dayValue = obj.Value
                        success = true
                        print("✅ День обновлен:", obj.Name, "=", obj.Value)
                    end)
                end
            end
            
            -- Проверяем атрибуты (включая RespawnDays у мобов)
            local attrs = obj:GetAttributes()
            for name, value in pairs(attrs) do
                if name:lower():find("day") and type(value) == "number" then
                    -- Увеличиваем все атрибуты дней
                    pcall(function()
                        obj:SetAttribute(name, value + 1)
                        if name:lower() == "day" or name:lower() == "currentday" then
                            dayValue = value + 1
                            success = true
                        end
                    end)
                end
            end
            
            if #obj:GetChildren() > 0 then
                findAndUpdateDay(obj)
            end
        end
    end
    
    -- Ищем везде
    findAndUpdateDay(Workspace)
    findAndUpdateDay(ReplicatedStorage)
    findAndUpdateDay(ServerStorage)
    findAndUpdateDay(Lighting)
    
    -- Пробуем обновить глобальный день в ReplicatedStorage
    pcall(function()
        local dayValue = ReplicatedStorage:FindFirstChild("Day")
        if dayValue and (dayValue:IsA("IntValue") or dayValue:IsA("NumberValue")) then
            dayValue.Value = dayValue.Value + 1
            success = true
            print("✅ Глобальный день обновлен:", dayValue.Value)
        end
    end)
    
    task.wait(0.5)
    
    if success then
        button.Text = "✅ День пропущен!"
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        button.Text = "🌅 Утро!"
        button.BackgroundColor3 = Color3.fromRGB(0, 160, 200)
    end
    
    button.Enabled = true
    task.wait(1.5)
    button.Text = "⌛ Пропустить день"
    button.BackgroundColor3 = Color3.fromRGB(140, 90, 210)
end

-- ═══════════════════════════════════════════════════════════════
-- СОЗДАНИЕ GUI
-- ═══════════════════════════════════════════════════════════════

local function createGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    if playerGUIs[player] then
        return playerGUIs[player]
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WispManePanel"
    screenGui.Parent = playerGui
    screenGui.Enabled = false
    
    -- Затемнение
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.Parent = screenGui
    
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            closeGUI(player)
        end
    end)
    
    -- Главный фрейм
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 320, 0, 470)
    main.Position = UDim2.new(0.5, -160, 0.5, -235)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    main.BackgroundTransparency = 0.1
    main.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "✨ WispMane ✨"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = main
    
    -- Разделитель
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.9, 0, 0, 2)
    line.Position = UDim2.new(0.05, 0, 0, 42)
    line.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    line.BorderSizePixel = 0
    line.Parent = main
    
    -- Кнопка закрытия
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
    
    -- Поле ввода скорости
    local speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0.8, 0, 0, 38)
    speedInput.Position = UDim2.new(0.1, 0, 0, 55)
    speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    speedInput.BackgroundTransparency = 0.3
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextSize = 14
    speedInput.Font = Enum.Font.Gotham
    speedInput.PlaceholderText = "Введите скорость..."
    speedInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    speedInput.Parent = main
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = speedInput
    
    -- Создаем кнопки
    local function createBtn(text, color, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.8, 0, 0, 40)
        btn.Position = UDim2.new(0.1, 0, 0, yPos)
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
        
        return btn
    end
    
    local speedBtn = createBtn("🚀 Установить скорость", Color3.fromRGB(255, 100, 100), 105)
    local flyBtn = createBtn("🕊️ Включить полет", Color3.fromRGB(80, 150, 255), 155)
    local chopBtn = createBtn("🪓 Вырубить лес", Color3.fromRGB(230, 140, 10), 205)
    local magnetBtn = createBtn("🧲 Притянуть лут", Color3.fromRGB(40, 180, 130), 255)
    local skipBtn = createBtn("⌛ Пропустить день", Color3.fromRGB(140, 90, 210), 305)
    
    -- Индикатор скорости
    local speedDisplay = Instance.new("TextLabel")
    speedDisplay.Size = UDim2.new(0.8, 0, 0, 25)
    speedDisplay.Position = UDim2.new(0.1, 0, 1, -40)
    speedDisplay.BackgroundTransparency = 1
    speedDisplay.TextColor3 = Color3.fromRGB(170, 170, 190)
    speedDisplay.TextSize = 14
    speedDisplay.Font = Enum.Font.Gotham
    speedDisplay.Text = "Скорость: 16"
    speedDisplay.Parent = main
    
    local guiData = {
        screenGui = screenGui,
        mainFrame = main,
        speedInput = speedInput,
        speedButton = speedBtn,
        flyButton = flyBtn,
        chopButton = chopBtn,
        magnetButton = magnetBtn,
        skipDayButton = skipBtn,
        speedDisplay = speedDisplay,
        closeButton = close
    }
    
    playerGUIs[player] = guiData
    isGUIOpen[player] = false
    
    -- ═══════════════════════════════════════════════════════════════
    -- ФУНКЦИИ УПРАВЛЕНИЯ
    -- ═══════════════════════════════════════════════════════════════
    
    local function updateSpeed()
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                speedDisplay.Text = "Скорость: " .. math.round(hum.WalkSpeed)
            end
        end
    end
    
    local function setSpeed()
        local speed = tonumber(speedInput.Text)
        if speed and speed > 0 then
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = speed
                    updateSpeed()
                    speedBtn.Text = "✅ Готово!"
                    speedBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    task.wait(0.8)
                    speedBtn.Text = "🚀 Установить скорость"
                    speedBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                end
            end
        end
    end
    
    local function toggleFly()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        
        if flyingPlayers[player] then
            flyingPlayers[player] = nil
            flySpeeds[player] = nil
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(0, 0, 0)
                root.CanCollide = true
            end
            hum.PlatformStand = false
            flyBtn.Text = "🕊️ Включить полет"
            flyBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
        else
            flyingPlayers[player] = true
            flySpeeds[player] = 50
            hum.PlatformStand = true
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CanCollide = false
            end
            flyBtn.Text = "🕊️ Выключить полет"
            flyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- ПОДКЛЮЧЕНИЕ КНОПОК
    -- ═══════════════════════════════════════════════════════════════
    
    speedBtn.MouseButton1Click:Connect(setSpeed)
    flyBtn.MouseButton1Click:Connect(toggleFly)
    chopBtn.MouseButton1Click:Connect(function()
        chopAllTrees(player, chopBtn)
    end)
    magnetBtn.MouseButton1Click:Connect(function()
        magnetAllLoot(player, magnetBtn)
    end)
    skipBtn.MouseButton1Click:Connect(function()
        skipOneDay(player, skipBtn)
    end)
    close.MouseButton1Click:Connect(function()
        closeGUI(player)
    end)
    
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        updateSpeed()
    end)
    
    task.wait(0.5)
    updateSpeed()
    
    return guiData
end

-- ═══════════════════════════════════════════════════════════════
-- ОТКРЫТИЕ/ЗАКРЫТИЕ GUI
-- ═══════════════════════════════════════════════════════════════

local function openGUI(player)
    local data = playerGUIs[player]
    if not data then
        data = createGUI(player)
    end
    
    if isGUIOpen[player] then return end
    
    data.screenGui.Enabled = true
    isGUIOpen[player] = true
    
    local wm = player.PlayerGui:FindFirstChild("WMButton")
    if wm then wm.Visible = false end
end

closeGUI = function(player)
    local data = playerGUIs[player]
    if not data or not isGUIOpen[player] then return end
    
    data.screenGui.Enabled = false
    isGUIOpen[player] = false
    
    local wm = player.PlayerGui:FindFirstChild("WMButton")
    if wm then
        wm.Visible = true
        wm.Size = UDim2.new(0, 70, 0, 70)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- КНОПКА WM
-- ═══════════════════════════════════════════════════════════════

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
        openGUI(player)
    end)
    
    return btn
end

-- ═══════════════════════════════════════════════════════════════
-- ИНИЦИАЛИЗАЦИЯ
-- ═══════════════════════════════════════════════════════════════

local function setupPlayer(player)
    createGUI(player)
    createWMButton(player)
    task.wait(0.2)
    openGUI(player)
end

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function() setupPlayer(player) end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if not playerGUIs[player] then
            setupPlayer(player)
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- ПОЛЕТ
-- ═══════════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    for player, flying in pairs(flyingPlayers) do
        if flying then
            local char = player.Character
            if not char then
                flyingPlayers[player] = nil
                return
            end
            
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

-- ═══════════════════════════════════════════════════════════════
-- ГОРЯЧИЕ КЛАВИШИ
-- ═══════════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local player = Players.LocalPlayer
    if not player then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        if isGUIOpen[player] then
            closeGUI(player)
        else
            openGUI(player)
        end
    end
    
    if input.KeyCode == Enum.KeyCode.X then
        local data = playerGUIs[player]
        if data and data.flyButton then
            data.flyButton:Activate()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ОЧИСТКА
-- ═══════════════════════════════════════════════════════════════

Players.PlayerRemoving:Connect(function(player)
    flyingPlayers[player] = nil
    flySpeeds[player] = nil
    playerGUIs[player] = nil
    isGUIOpen[player] = nil
end)

print("✅ WispMane Admin загружена!")
print("📌 F - открыть/закрыть меню")
print("📌 X - включить/выключить полет")
print("📌 WASD + Пробел/Shift - управление в полете")
