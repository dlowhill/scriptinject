-- ═══════════════════════════════════════════════════════════════
-- УЛЬТИМАТИВНАЯ АДМИН-ПАНЕЛЬ WISPMANE ДЛЯ 99 NIGHTS IN THE FOREST
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- ═══════════════════════════════════════════════════════════════
-- ГЛОБАЛЬНЫЕ ДАННЫЕ
-- ═══════════════════════════════════════════════════════════════

local flyingPlayers = {}     
local flySpeeds = {}         
local playerGUIs = {}        
local isGUIOpen = {}         
local dragData = {}          -- 🔥 Фикс: отдельные данные для каждого игрока

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
    
    -- Эффект наведения
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.05
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.15
        }):Play()
    end)
    
    return button
end

local function createRoundedFrame(parent, size, position, color, transparency)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(0, 350, 0, 500)
    frame.Position = position or UDim2.new(0.5, -175, 0.5, -250)
    frame.BackgroundColor3 = color or Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = transparency or 0.15
    frame.BorderSizePixel = 0
    frame.Parent = parent  -- 🔥 Исправлено: родитель устанавливается здесь
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    -- Тень (эффект свечения)
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1316044743"
    glow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    glow.ImageTransparency = 0.5
    glow.ZIndex = -1
    glow.Parent = frame
    
    return frame
end

-- ═══════════════════════════════════════════════════════════════
-- СОЗДАНИЕ GUI
-- ═══════════════════════════════════════════════════════════════

local function createGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    if playerGUIs[player] then
        return playerGUIs[player]
    end
    
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WispManePanel"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    screenGui.Enabled = false 
    
    -- Затемнение
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.Parent = screenGui
    
    -- Клик по затемнению закрывает GUI
    background.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            closeGUI(player)
        end
    end)
    
    -- Главный фрейм
    local mainFrame = createRoundedFrame(screenGui)  -- 🔥 Теперь parent устанавливается правильно
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundTransparency = 1 
    mainFrame.ClipsDescendants = true
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "✨ WispMane ✨"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame
    
    -- Разделитель
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
    
    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundTransparency = 0.1
    end)
    
    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundTransparency = 0.2
    end)
    
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
    
    -- Индикатор скорости
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
    
    -- Сохраняем данные
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
    -- ФУНКЦИИ
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
            -- Выключаем полет
            flyingPlayers[player] = nil
            flySpeeds[player] = nil
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.Anchored = false
            end
            
            humanoid.PlatformStand = false
            humanoid.Sit = false
            
            if flyButton and flyButton.Parent then
                flyButton.Text = "🕊️ Включить полет"
                flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            end
        else
            -- Включаем полет
            flyingPlayers[player] = true
            flySpeeds[player] = 40
            
            if flyButton and flyButton.Parent then
                flyButton.Text = "🕊️ Выключить полет"
                flyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            end
        end
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- ВЫРУБКА ЛЕСА (ОПТИМИЗИРОВАННАЯ)
    -- ═══════════════════════════════════════════════════════════════
    
    local function chopAllTrees()
        local map = workspace:FindFirstChild("Map")
        if not map then 
            chopButton.Text = "❌ Карта не найдена!"
            task.wait(1)
            chopButton.Text = "🪓 Вырубить весь лес"
            return 
        end
        
        chopButton.Text = "⏳ Вырубка..."
        chopButton.BackgroundColor3 = Color3.fromRGB(150, 100, 20)
        chopButton.Enabled = false
        
        local treesFound = 0
        local treesDestroyed = 0
        
        -- 🔥 Оптимизация: ищем только деревья
        local function findTrees(container)
            for _, obj in ipairs(container:GetChildren()) do
                if obj:IsA("Model") then
                    local name = obj.Name:lower()
                    if name:find("tree") and not name:find("leaf") and not name:find("stump") then
                        if not name:find("mother") and not name:find("giant") then
                            treesFound = treesFound + 1
                            task.spawn(function()
                                pcall(function()
                                    -- Пытаемся сломать через модули
                                    local module = ServerStorage:FindFirstChild("LandmarkModules") 
                                    if module then
                                        local treeModule = module:FindFirstChild(obj.Name)
                                        if treeModule then
                                            local success, result = pcall(require, treeModule)
                                            if success and type(result) == "function" then
                                                result(obj, 999999)
                                            end
                                        end
                                    end
                                    
                                    -- Удаляем дерево
                                    obj:Destroy()
                                    treesDestroyed = treesDestroyed + 1
                                end)
                            end)
                        end
                    end
                end
            end
        end
        
        -- Ищем деревья по всей карте
        findTrees(map)
        
        -- Ждем завершения
        task.wait(1)
        
        chopButton.Text = "✅ Уничтожено деревьев: " .. treesDestroyed
        chopButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        chopButton.Enabled = true
        
        task.wait(1.5)
        chopButton.Text = "🪓 Вырубить весь лес"
        chopButton.BackgroundColor3 = Color3.fromRGB(230, 140, 10)
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- ПРИТЯГИВАНИЕ ЛУТА (УЛУЧШЕННОЕ)
    -- ═══════════════════════════════════════════════════════════════
    
    local function magnetAllLoot()
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if not rootPart then
            magnetButton.Text = "❌ Нет персонажа!"
            task.wait(1)
            magnetButton.Text = "🧲 Притянуть весь лут"
            return
        end
        
        magnetButton.Text = "⏳ Притягивание..."
        magnetButton.BackgroundColor3 = Color3.fromRGB(20, 120, 90)
        magnetButton.Enabled = false
        
        local targetPosition = rootPart.Position + Vector3.new(0, -2, 0)
        local count = 0
        local items = {}
        
        -- 🔥 Собираем все предметы
        local function collectItems(container)
            for _, obj in ipairs(container:GetChildren()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local name = obj.Name:lower()
                    
                    -- Проверяем, что это ресурс
                    local isResource = name:find("log") or name:find("wood") or name:find("stick") or 
                                      name:find("sapling") or name:find("berry") or name:find("item") or
                                      name:find("stone") or name:find("rock") or name:find("branch")
                    
                    if isResource and not obj:IsDescendantOf(character) then
                        if not obj:FindFirstChild("Leave") and not obj:FindFirstChild("Trunk") then
                            table.insert(items, obj)
                        end
                    end
                end
            end
        end
        
        -- Ищем предметы по всему миру (исключая карту и игроков)
        for _, playerObj in ipairs(Players:GetPlayers()) do
            if playerObj.Character then
                collectItems(playerObj.Character)
            end
        end
        
        collectItems(workspace)
        
        -- 🔥 Телепортируем предметы с задержкой
        for i, item in ipairs(items) do
            task.spawn(function()
                pcall(function()
                    if item and item.Parent then
                        if item:IsA("BasePart") then
                            item.CFrame = CFrame.new(targetPosition + Vector3.new(
                                math.random(-2, 2),
                                0,
                                math.random(-2, 2)
                            ))
                        elseif item:IsA("Model") and item.PrimaryPart then
                            item:PivotTo(CFrame.new(targetPosition + Vector3.new(
                                math.random(-2, 2),
                                0,
                                math.random(-2, 2)
                            )))
                        end
                        count = count + 1
                    end
                end)
            end)
            task.wait(0.01) -- Небольшая задержка для производительности
        end
        
        task.wait(0.5)
        
        magnetButton.Text = "✅ Собрано предметов: " .. count
        magnetButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        magnetButton.Enabled = true
        
        task.wait(1.5)
        magnetButton.Text = "🧲 Притянуть весь лут"
        magnetButton.BackgroundColor3 = Color3.fromRGB(40, 180, 130)
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- ПРОПУСК ДНЯ (УЛУЧШЕННЫЙ)
    -- ═══════════════════════════════════════════════════════════════
    
    local function skipOneDay()
        skipDayButton.Text = "⏳ Перемотка времени..."
        skipDayButton.BackgroundColor3 = Color3.fromRGB(100, 60, 160)
        skipDayButton.Enabled = false
        
        local success = false
        
        -- 🔥 Меняем время суток
        pcall(function()
            Lighting.ClockTime = 6
        end)
        
        -- 🔥 Ищем день в разных местах
        local searchTargets = {
            workspace,
            ReplicatedStorage,
            ServerStorage,
            Lighting
        }
        
        for _, target in ipairs(searchTargets) do
            if target then
                for _, child in ipairs(target:GetChildren()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        local name = child.Name:lower()
                        if name == "day" or name == "currentday" or name == "days" then
                            pcall(function()
                                child.Value = child.Value + 1
                                success = true
                            end)
                        end
                    end
                end
            end
        end
        
        -- 🔥 Ищем атрибуты
        pcall(function()
            for _, target in ipairs(searchTargets) do
                if target then
                    local attrs = target:GetAttributes()
                    for name, value in pairs(attrs) do
                        if name:lower():find("day") then
                            if type(value) == "number" then
                                target:SetAttribute(name, value + 1)
                                success = true
                            end
                        end
                    end
                end
            end
        end)
        
        -- 🔥 Пробуем вызвать функцию пропуска дня
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
            skipDayButton.Text = "✅ День успешно пропущен!"
            skipDayButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            skipDayButton.Text = "🌅 Время сдвинуто на утро!"
            skipDayButton.BackgroundColor3 = Color3.fromRGB(0, 160, 200)
        end
        
        skipDayButton.Enabled = true
        
        task.wait(1.5)
        skipDayButton.Text = "⌛ Пропустить день"
        skipDayButton.BackgroundColor3 = Color3.fromRGB(140, 90, 210)
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
    chopButton.MouseButton1Click:Connect(chopAllTrees)
    magnetButton.MouseButton1Click:Connect(magnetAllLoot)
    skipDayButton.MouseButton1Click:Connect(skipOneDay)
    closeButton.MouseButton1Click:Connect(function()
        closeGUI(player)
    end)
    
    -- Обновление при пересоздании персонажа
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        updateSpeedDisplay()
        
        if flyingPlayers[player] then
            task.wait(0.5)
            -- Восстанавливаем полет
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
        Size = UDim2.new(0, 350, 0, 500)
    }):Play()
    
    if wmButton then
        TweenService:Create(wmButton, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.delay(0.25, function()
            if wmButton then
                wmButton.Visible = false
            end
        end)
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
        
        TweenService:Create(wmButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 70, 0, 70),
            BackgroundTransparency = 0.2
        }):Play()
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
    
    -- Анимация пульсации
    local pulse = TweenService:Create(wmButton, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 74, 0, 74)
    })
    pulse:Play()
    
    -- 🔥 Фикс: отдельные данные для перетаскивания
    dragData[player] = {
        dragging = false,
        dragStart = nil,
        startPos = nil
    }
    
    wmButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local data = dragData[player]
            if data then
                data.dragging = true
                data.dragStart = input.Position
                data.startPos = wmButton.Position
            end
        end
    end)
    
    wmButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local data = dragData[player]
            if data and data.dragging then
                local delta = input.Position - data.dragStart
                wmButton.Position = UDim2.new(
                    data.startPos.X.Scale, data.startPos.X.Offset + delta.X,
                    data.startPos.Y.Scale, data.startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    wmButton.MouseButton1Click:Connect(function()
        openGUI(player)
    end)
    
    return wmButton
end

-- Сброс перетаскивания
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        for player, data in pairs(dragData) do
            if data then
                data.dragging = false
            end
        end
    end
end)

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
        else
            -- Обновляем GUI
            local guiData = playerGUIs[player]
            if guiData and guiData.speedDisplay then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        guiData.speedDisplay.Text = "Текущая скорость: " .. tostring(math.round(humanoid.WalkSpeed))
                    end
                end
            end
        end
    end)
    
    if player.Character then
        task.wait(0.5)
        setupPlayer(player)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ИДЕАЛЬНЫЙ ПОЛЕТ (ИСПРАВЛЕННЫЙ)
-- ═══════════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    for player, isFlying in pairs(flyingPlayers) do
        if isFlying then
            local character = player.Character
            if not character then
                flyingPlayers[player] = nil
                flySpeeds[player] = nil
                
                -- Обновляем кнопку
                local guiData = playerGUIs[player]
                if guiData and guiData.flyButton and guiData.flyButton.Parent then
                    guiData.flyButton.Text = "🕊️ Включить полет"
                    guiData.flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
                end
                return
            end
            
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                -- 🔥 Правильная настройка полета
                humanoid.PlatformStand = true
                rootPart.Anchored = false
                rootPart.CanCollide = false
                
                local speed = flySpeeds[player] or 40
                local moveDirection = Vector3.new(0, 0, 0)
                
                local camera = workspace.CurrentCamera
                
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
                    
                    -- Поворот в сторону движения (только по горизонтали)
                    local lookDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z)
                    if lookDirection.Magnitude > 0.1 then
                        rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookDirection)
                    end
                else
                    -- Парение на месте
                    rootPart.Velocity = Vector3.new(0, 0.1, 0)
                end
            end
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
    dragData[player] = nil
end)

print("✅ WispMane Admin Panel загружена успешно!")
print("📌 Нажмите F для открытия меню")
print("📌 Нажмите X для переключения полета")
print("📌 Кнопка WM в центре экрана")
