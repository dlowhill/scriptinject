-- ═══════════════════════════════════════════════════════════════
-- УЛЬТИМАТИВНАЯ АДМИН-ПАНЕЛЬ WISPMANE (РАБОЧАЯ ВЕРСИЯ)
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- ═══════════════════════════════════════════════════════════════
-- ГЛОБАЛЬНЫЕ ДАННЫЕ
-- ═══════════════════════════════════════════════════════════════

local flyingPlayers = {}     
local flySpeeds = {}         
local playerGUIs = {}        
local isGUIOpen = {}         

-- ═══════════════════════════════════════════════════════════════
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ═══════════════════════════════════════════════════════════════

local function createRoundedButton(parent, text, color, size, position)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0, 200, 0, 40)
    button.Position = position or UDim2.new(0.5, -100, 0, 0)
    button.BackgroundColor3 = color or Color3.fromRGB(255, 80, 80)
    button.BackgroundTransparency = 0.15
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Text = text or "Кнопка"
    button.Parent = parent
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

local function createRoundedFrame(parent, size, position)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(0, 350, 0, 550)
    frame.Position = position or UDim2.new(0.5, -175, 0.5, -275)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    return frame
end

-- ═══════════════════════════════════════════════════════════════
-- ФУНКЦИЯ ВЫРУБКИ ЛЕСА (РАБОЧАЯ)
-- ═══════════════════════════════════════════════════════════════

local function chopAllTrees(player, button)
    local character = player.Character
    if not character then
        button.Text = "❌ Нет персонажа!"
        task.wait(1)
        button.Text = "🪓 Вырубить весь лес"
        return
    end
    
    button.Text = "⏳ Поиск деревьев..."
    button.BackgroundColor3 = Color3.fromRGB(150, 100, 20)
    button.Enabled = false
    
    local treesFound = 0
    local treesDestroyed = 0
    
    -- Ищем деревья по всему миру
    local function findAndDestroyTrees(container)
        for _, obj in ipairs(container:GetChildren()) do
            if obj:IsA("Model") then
                local name = obj.Name:lower()
                -- Проверяем, что это дерево
                if (name:find("tree") or name:find("wood") or name:find("log")) and not name:find("leaf") and not name:find("stump") then
                    -- Исключаем важные объекты
                    if not name:find("mother") and not name:find("giant") and not name:find("fairy") then
                        treesFound = treesFound + 1
                        
                        -- Удаляем дерево
                        pcall(function()
                            -- Пробуем сломать через модули игры
                            local module = ServerStorage:FindFirstChild("LandmarkModules")
                            if module then
                                local treeModule = module:FindFirstChild(obj.Name)
                                if treeModule then
                                    pcall(function()
                                        local moduleFunc = require(treeModule)
                                        if type(moduleFunc) == "function" then
                                            moduleFunc(obj, 999999)
                                        end
                                    end)
                                end
                            end
                            
                            -- Удаляем объект
                            obj:Destroy()
                            treesDestroyed = treesDestroyed + 1
                        end)
                    end
                end
            end
            
            -- Рекурсивно ищем в дочерних объектах
            if #obj:GetChildren() > 0 then
                findAndDestroyTrees(obj)
            end
        end
    end
    
    -- Начинаем поиск с карты
    local map = Workspace:FindFirstChild("Map")
    if map then
        findAndDestroyTrees(map)
    end
    
    -- Ищем деревья в корне Workspace
    findAndDestroyTrees(Workspace)
    
    task.wait(0.5)
    
    if treesDestroyed > 0 then
        button.Text = "✅ Срублено деревьев: " .. treesDestroyed
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        button.Text = "❌ Деревья не найдены!"
        button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    button.Enabled = true
    
    task.wait(1.5)
    button.Text = "🪓 Вырубить весь лес"
    button.BackgroundColor3 = Color3.fromRGB(230, 140, 10)
end

-- ═══════════════════════════════════════════════════════════════
-- ФУНКЦИЯ ПРИТЯГИВАНИЯ ЛУТА (РАБОЧАЯ)
-- ═══════════════════════════════════════════════════════════════

local function magnetAllLoot(player, button)
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then
        button.Text = "❌ Нет персонажа!"
        task.wait(1)
        button.Text = "🧲 Притянуть весь лут"
        return
    end
    
    button.Text = "⏳ Поиск лута..."
    button.BackgroundColor3 = Color3.fromRGB(20, 120, 90)
    button.Enabled = false
    
    local targetPosition = rootPart.Position + Vector3.new(0, -2, 0)
    local count = 0
    local itemsFound = {}
    
    -- Функция поиска предметов
    local function findItems(container)
        for _, obj in ipairs(container:GetChildren()) do
            -- Проверяем BasePart
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                -- Список ресурсов
                local isResource = name:find("log") or name:find("wood") or name:find("stick") or 
                                  name:find("sapling") or name:find("berry") or name:find("item") or
                                  name:find("stone") or name:find("rock") or name:find("branch") or
                                  name:find("ore") or name:find("herb") or name:find("flower") or
                                  name:find("fruit") or name:find("seed")
                
                if isResource and obj.Parent and obj.Parent ~= character then
                    if not obj:FindFirstChild("Leave") and not obj:FindFirstChild("Trunk") then
                        table.insert(itemsFound, obj)
                    end
                end
            end
            
            -- Проверяем Model
            if obj:IsA("Model") then
                local name = obj.Name:lower()
                local isResource = name:find("log") or name:find("wood") or name:find("stick") or 
                                  name:find("sapling") or name:find("berry") or name:find("item") or
                                  name:find("stone") or name:find("rock") or name:find("branch") or
                                  name:find("ore") or name:find("herb")
                
                if isResource and obj ~= character and not obj:IsDescendantOf(character) then
                    if obj.PrimaryPart then
                        table.insert(itemsFound, obj)
                    end
                end
            end
        end
    end
    
    -- Ищем по всему миру
    findItems(Workspace)
    
    -- Ищем в Map
    local map = Workspace:FindFirstChild("Map")
    if map then
        findItems(map)
    end
    
    -- Телепортируем предметы
    for _, item in ipairs(itemsFound) do
        pcall(function()
            if item and item.Parent then
                local offset = Vector3.new(
                    math.random(-2, 2),
                    math.random(0, 1),
                    math.random(-2, 2)
                )
                
                if item:IsA("BasePart") then
                    item.CFrame = CFrame.new(targetPosition + offset)
                    count = count + 1
                elseif item:IsA("Model") and item.PrimaryPart then
                    item:PivotTo(CFrame.new(targetPosition + offset))
                    count = count + 1
                end
            end
        end)
    end
    
    task.wait(0.5)
    
    if count > 0 then
        button.Text = "✅ Собрано предметов: " .. count
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        button.Text = "❌ Лут не найден!"
        button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    button.Enabled = true
    
    task.wait(1.5)
    button.Text = "🧲 Притянуть весь лут"
    button.BackgroundColor3 = Color3.fromRGB(40, 180, 130)
end

-- ═══════════════════════════════════════════════════════════════
-- ФУНКЦИЯ ПРОПУСКА ДНЯ (РАБОЧАЯ)
-- ═══════════════════════════════════════════════════════════════

local function skipOneDay(player, button)
    button.Text = "⏳ Перемотка времени..."
    button.BackgroundColor3 = Color3.fromRGB(100, 60, 160)
    button.Enabled = false
    
    local success = false
    local dayValue = 0
    
    -- 1. Меняем время
    pcall(function()
        Lighting.ClockTime = 6
        Lighting.TimeOfDay = "06:00:00"
    end)
    
    -- 2. Ищем и увеличиваем день
    local function findAndUpdateDay(container)
        for _, child in ipairs(container:GetChildren()) do
            -- Проверяем IntValue и NumberValue
            if child:IsA("IntValue") or child:IsA("NumberValue") then
                local name = child.Name:lower()
                if name == "day" or name == "currentday" or name == "days" or name == "daycount" then
                    pcall(function()
                        child.Value = child.Value + 1
                        dayValue = child.Value
                        success = true
                        print("✅ День обновлен:", child.Name, "->", child.Value)
                    end)
                end
            end
            
            -- Проверяем атрибуты
            local attrs = child:GetAttributes()
            for name, value in pairs(attrs) do
                if name:lower():find("day") and type(value) == "number" then
                    pcall(function()
                        child:SetAttribute(name, value + 1)
                        dayValue = value + 1
                        success = true
                        print("✅ Атрибут дня обновлен:", name, "->", value + 1)
                    end)
                end
            end
            
            -- Рекурсия
            if #child:GetChildren() > 0 then
                findAndUpdateDay(child)
            end
        end
    end
    
    -- Проверяем все хранилища
    findAndUpdateDay(Workspace)
    findAndUpdateDay(ReplicatedStorage)
    findAndUpdateDay(ServerStorage)
    findAndUpdateDay(Lighting)
    
    -- 3. Пробуем вызвать системную функцию
    pcall(function()
        local dayModule = ServerStorage:FindFirstChild("DayManager")
        if dayModule then
            local module = require(dayModule)
            if type(module) == "function" then
                module()
                success = true
            elseif type(module) == "table" and module.SkipDay then
                module:SkipDay()
                success = true
            end
        end
    end)
    
    task.wait(0.5)
    
    if success then
        button.Text = "✅ День пропущен! (День " .. dayValue .. ")"
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        button.Text = "🌅 Время перемотано на утро!"
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
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    screenGui.Enabled = false 
    
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.Parent = screenGui
    
    background.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            closeGUI(player)
        end
    end)
    
    local mainFrame = createRoundedFrame(screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundTransparency = 1 
    mainFrame.ClipsDescendants = true
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "✨ WispMane Admin ✨"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0.9, 0, 0, 2)
    divider.Position = UDim2.new(0.05, 0, 0, 42)
    divider.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    divider.BorderSizePixel = 0
    divider.Parent = mainFrame
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 8)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.BackgroundTransparency = 0.2
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
    
    -- Поле ввода скорости
    local speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0.8, 0, 0, 38)
    speedInput.Position = UDim2.new(0.1, 0, 0, 60)
    speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    speedInput.BackgroundTransparency = 0.3
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextSize = 14
    speedInput.Font = Enum.Font.Gotham
    speedInput.PlaceholderText = "Введите скорость..."
    speedInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    speedInput.TextXAlignment = Enum.TextXAlignment.Center
    speedInput.Parent = mainFrame
    speedInput.ClearTextOnFocus = false
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = speedInput
    
    -- Кнопки
    local speedButton = createRoundedButton(mainFrame, "🚀 Установить скорость", Color3.fromRGB(255, 100, 100), 
        UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0, 110))
    
    local flyButton = createRoundedButton(mainFrame, "🕊️ Включить полет", Color3.fromRGB(80, 150, 255),
        UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0, 165))
        
    local chopButton = createRoundedButton(mainFrame, "🪓 Вырубить весь лес", Color3.fromRGB(230, 140, 10),
        UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0, 220))
        
    local magnetButton = createRoundedButton(mainFrame, "🧲 Притянуть весь лут", Color3.fromRGB(40, 180, 130),
        UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0, 275))

    local skipDayButton = createRoundedButton(mainFrame, "⌛ Пропустить день", Color3.fromRGB(140, 90, 210),
        UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0, 330))
    
    local speedDisplay = Instance.new("TextLabel")
    speedDisplay.Size = UDim2.new(0.8, 0, 0, 25)
    speedDisplay.Position = UDim2.new(0.1, 0, 1, -40)
    speedDisplay.BackgroundTransparency = 1
    speedDisplay.TextColor3 = Color3.fromRGB(170, 170, 190)
    speedDisplay.TextSize = 14
    speedDisplay.Font = Enum.Font.Gotham
    speedDisplay.Text = "Текущая скорость: 16"
    speedDisplay.TextXAlignment = Enum.TextXAlignment.Center
    speedDisplay.Parent = mainFrame
    
    local guiData = {
        screenGui = screenGui,
        mainFrame = mainFrame,
        speedInput = speedInput,
        speedButton = speedButton,
        flyButton = flyButton,
        chopButton = chopButton,
        magnetButton = magnetButton,
        skipDayButton = skipDayButton,
        speedDisplay = speedDisplay,
        closeButton = closeButton,
        background = background
    }
    
    playerGUIs[player] = guiData
    isGUIOpen[player] = false
    
    -- ═══════════════════════════════════════════════════════════════
    -- ФУНКЦИИ УПРАВЛЕНИЯ
    -- ═══════════════════════════════════════════════════════════════
    
    local function updateSpeedDisplay()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and speedDisplay and speedDisplay.Parent then
                speedDisplay.Text = "Текущая скорость: " .. tostring(math.round(humanoid.WalkSpeed))
            end
        end
    end
    
    local function setSpeed(speed)
        local character = player.Character
        if not character then return false end
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return false end
        
        local newSpeed = tonumber(speed)
        if not newSpeed or newSpeed < 0 then return false end
        
        humanoid.WalkSpeed = newSpeed
        updateSpeedDisplay()
        return true
    end
    
    local function toggleFly()
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        if flyingPlayers[player] then
            flyingPlayers[player] = nil
            flySpeeds[player] = nil
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.CanCollide = true
            end
            
            humanoid.PlatformStand = false
            humanoid.Sit = false
            
            flyButton.Text = "🕊️ Включить полет"
            flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
        else
            flyingPlayers[player] = true
            flySpeeds[player] = 40
            
            humanoid.PlatformStand = true
            
            flyButton.Text = "🕊️ Выключить полет"
            flyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- ПОДКЛЮЧЕНИЕ КНОПОК
    -- ═══════════════════════════════════════════════════════════════
    
    speedButton.MouseButton1Click:Connect(function()
        local speedValue = speedInput.Text
        
        if setSpeed(speedValue) then
            speedButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            speedButton.Text = "✅ Скорость изменена!"
            task.wait(0.8)
            speedButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            speedButton.Text = "🚀 Установить скорость"
        else
            speedButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            speedButton.Text = "❌ Ошибка!"
            task.wait(0.8)
            speedButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            speedButton.Text = "🚀 Установить скорость"
        end
    end)
    
    flyButton.MouseButton1Click:Connect(toggleFly)
    
    -- 🔥 Исправленные кнопки с передачей player
    chopButton.MouseButton1Click:Connect(function()
        chopAllTrees(player, chopButton)
    end)
    
    magnetButton.MouseButton1Click:Connect(function()
        magnetAllLoot(player, magnetButton)
    end)
    
    skipDayButton.MouseButton1Click:Connect(function()
        skipOneDay(player, skipDayButton)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        closeGUI(player)
    end)
    
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        updateSpeedDisplay()
        
        if flyingPlayers[player] then
            task.wait(0.5)
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = true
                end
            end
        end
    end)
    
    task.wait(0.5)
    updateSpeedDisplay()
    
    return guiData
end

-- ═══════════════════════════════════════════════════════════════
-- ФУНКЦИИ ОТКРЫТИЯ/ЗАКРЫТИЯ GUI
-- ═══════════════════════════════════════════════════════════════

local function openGUI(player)
    local guiData = playerGUIs[player]
    
    if not guiData then
        guiData = createGUI(player)
    end
    
    if isGUIOpen[player] then
        return
    end
    
    local screenGui = guiData.screenGui
    local mainFrame = guiData.mainFrame
    local wmButton = player.PlayerGui:FindFirstChild("WMButton")
    
    if not screenGui or not mainFrame then return end
    
    screenGui.Enabled = true
    isGUIOpen[player] = true
    
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    
    TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15,
        Size = UDim2.new(0, 350, 0, 550)
    }):Play()
    
    if wmButton then
        wmButton.Visible = false
    end
end

closeGUI = function(player)
    local guiData = playerGUIs[player]
    
    if not guiData then
        return
    end
    
    if not isGUIOpen[player] then
        return
    end
    
    local screenGui = guiData.screenGui
    local mainFrame = guiData.mainFrame
    local wmButton = player.PlayerGui:FindFirstChild("WMButton")
    
    if not screenGui or not mainFrame then return end
    
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    isGUIOpen[player] = false
    
    task.delay(0.25, function()
        if screenGui then
            screenGui.Enabled = false
        end
    end)
    
    if wmButton then
        wmButton.Visible = true
        wmButton.Size = UDim2.new(0, 70, 0, 70)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- СОЗДАНИЕ КНОПКИ WM
-- ═══════════════════════════════════════════════════════════════

local function createWMButton(player)
    local playerGui = player:WaitForChild("PlayerGui")
    local oldButton = playerGui:FindFirstChild("WMButton")
    
    if oldButton then
        oldButton:Destroy()
    end
    
    local wmButton = Instance.new("ImageButton")
    wmButton.Name = "WMButton"
    wmButton.Size = UDim2.new(0, 70, 0, 70)
    wmButton.Position = UDim2.new(0.5, -35, 0.5, -35)
    wmButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    wmButton.BackgroundTransparency = 0.2
    wmButton.ZIndex = 100
    wmButton.Visible = true
    wmButton.Parent = playerGui
    
    local wmCorner = Instance.new("UICorner")
    wmCorner.CornerRadius = UDim.new(1, 0)
    wmCorner.Parent = wmButton
    
    local wmText = Instance.new("TextLabel")
    wmText.Size = UDim2.new(1, 0, 1, 0)
    wmText.BackgroundTransparency = 1
    wmText.Text = "WM"
    wmText.TextColor3 = Color3.fromRGB(255, 255, 255)
    wmText.TextSize = 20
    wmText.Font = Enum.Font.GothamBold
    wmText.TextScaled = true
    wmText.Parent = wmButton
    
    local pulse = TweenService:Create(wmButton, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 74, 0, 74)
    })
    pulse:Play()
    
    wmButton.MouseButton1Click:Connect(function()
        openGUI(player)
    end)
    
    return wmButton
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
    task.spawn(function()
        setupPlayer(player)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if not playerGUIs[player] then
            setupPlayer(player)
        end
    end)
    
    if player.Character then
        task.wait(0.5)
        setupPlayer(player)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ПОЛЕТ
-- ═══════════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    for player, isFlying in pairs(flyingPlayers) do
        if isFlying then
            local character = player.Character
            if not character then
                flyingPlayers[player] = nil
                flySpeeds[player] = nil
                return
            end
            
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                humanoid.PlatformStand = true
                rootPart.CanCollide = false
                
                local speed = flySpeeds[player] or 40
                local moveDirection = Vector3.new(0, 0, 0)
                
                local camera = Workspace.CurrentCamera
                
                if camera then
                    local forward = camera.CFrame.LookVector
                    local right = camera.CFrame.RightVector
                    
                    forward = Vector3.new(forward.X, 0, forward.Z).Unit
                    right = Vector3.new(right.X, 0, right.Z).Unit
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDirection = moveDirection + forward
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDirection = moveDirection - forward
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDirection = moveDirection - right
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDirection = moveDirection + right
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveDirection = moveDirection + Vector3.new(0, 1, 0)
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        moveDirection = moveDirection - Vector3.new(0, 1, 0)
                    end
                end
                
                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit * speed
                    rootPart.Velocity = moveDirection
                    
                    local lookDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z)
                    if lookDirection.Magnitude > 0.1 then
                        rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookDirection)
                    end
                else
                    rootPart.Velocity = Vector3.new(0, 0.1, 0)
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ГОРЯЧИЕ КЛАВИШИ
-- ═══════════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
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
        local guiData = playerGUIs[player]
        if guiData and guiData.flyButton then
            guiData.flyButton:Activate()
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

print("✅ WispMane Admin Panel загружена!")
print("📌 F - открыть/закрыть меню")
print("📌 X - включить/выключить полет")
