-- ═══════════════════════════════════════════════════════════════
-- РАСШИРЕННЫЙ СКРИПТ УПРАВЛЕНИЯ ПЕРСОНАЖЕМ С GUI И ПОЛЕТОМ
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ═══════════════════════════════════════════════════════════════
-- ГЛОБАЛЬНЫЕ ДАННЫЕ
-- ═══════════════════════════════════════════════════════════════

local flyingPlayers = {}     -- {[Player] = true/false}
local flySpeeds = {}         -- {[Player] = speed}
local playerGUIs = {}        -- {[Player] = {gui, wmButton, mainFrame}}
local isGUIOpen = {}         -- {[Player] = true/false}

-- ═══════════════════════════════════════════════════════════════
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ═══════════════════════════════════════════════════════════════

local function createRoundedButton(parent, text, color, size, position)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0, 200, 0, 45)
    button.Position = position or UDim2.new(0.5, -100, 0, 0)
    button.BackgroundColor3 = color or Color3.fromRGB(255, 80, 80)
    button.BackgroundTransparency = 0.2
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.Text = text or "Кнопка"
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

local function createRoundedFrame(parent, size, position, color, transparency)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(0, 350, 0, 300)
    frame.Position = position or UDim2.new(0.5, -175, 0.5, -150)
    frame.BackgroundColor3 = color or Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = transparency or 0.15
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    return frame
end

-- ═══════════════════════════════════════════════════════════════
-- СОЗДАНИЕ GUI
-- ═══════════════════════════════════════════════════════════════

local function createGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Проверяем, есть ли уже GUI
    if playerGUIs[player] then
        return playerGUIs[player]
    end
    
    -- ─── СОЗДАЕМ SCREENGUI ───
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedFlyGUI"
    screenGui.Parent = playerGui
    screenGui.Enabled = false -- По умолчанию скрыт
    
    -- ─── ЗАТЕМНЕНИЕ ───
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.Parent = screenGui
    
    -- ─── ГЛАВНЫЙ ФРЕЙМ ───
    local mainFrame = createRoundedFrame(screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundTransparency = 1 -- Скрыт для анимации
    
    -- Тень
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316044743"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.Parent = mainFrame
    
    -- ─── ЗАГОЛОВОК ───
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Управление персонажем"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
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
    
    -- ─── КНОПКА ЗАКРЫТИЯ ───
    local closeButton = Instance.new("ImageButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.BackgroundTransparency = 0.3
    closeButton.Image = "rbxassetid://1316044743"
    closeButton.ImageColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.ImageTransparency = 0.5
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
    
    local closeText = Instance.new("TextLabel")
    closeText.Size = UDim2.new(1, 0, 1, 0)
    closeText.BackgroundTransparency = 1
    closeText.Text = "✕"
    closeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeText.TextSize = 18
    closeText.Font = Enum.Font.GothamBold
    closeText.Parent = closeButton
    
    -- ─── ПОЛЕ ВВОДА СКОРОСТИ ───
    local speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0.7, 0, 0, 40)
    speedInput.Position = UDim2.new(0.15, 0, 0, 60)
    speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    speedInput.BackgroundTransparency = 0.3
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextSize = 16
    speedInput.Font = Enum.Font.Gotham
    speedInput.PlaceholderText = "Введите скорость..."
    speedInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    speedInput.TextXAlignment = Enum.TextXAlignment.Center
    speedInput.Parent = mainFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = speedInput
    
    -- ─── КНОПКА УСТАНОВКИ СКОРОСТИ ───
    local speedButton = createRoundedButton(mainFrame, "🚀 Установить скорость", Color3.fromRGB(255, 80, 80), 
        UDim2.new(0.6, 0, 0, 45), UDim2.new(0.2, 0, 0, 115))
    
    -- ─── КНОПКА ПОЛЕТА ───
    local flyButton = createRoundedButton(mainFrame, "🕊️ Включить полет", Color3.fromRGB(80, 150, 255),
        UDim2.new(0.6, 0, 0, 45), UDim2.new(0.2, 0, 0, 175))
    
    -- ─── ИНДИКАТОР СКОРОСТИ ───
    local speedDisplay = Instance.new("TextLabel")
    speedDisplay.Size = UDim2.new(0.8, 0, 0, 25)
    speedDisplay.Position = UDim2.new(0.1, 0, 0, 240)
    speedDisplay.BackgroundTransparency = 1
    speedDisplay.TextColor3 = Color3.fromRGB(150, 150, 170)
    speedDisplay.TextSize = 14
    speedDisplay.Font = Enum.Font.Gotham
    speedDisplay.Text = "Текущая скорость: 16"
    speedDisplay.TextXAlignment = Enum.TextXAlignment.Center
    speedDisplay.Parent = mainFrame
    
    -- ─── СОХРАНЯЕМ ДАННЫЕ ───
    local guiData = {
        screenGui = screenGui,
        mainFrame = mainFrame,
        speedInput = speedInput,
        speedButton = speedButton,
        flyButton = flyButton,
        speedDisplay = speedDisplay,
        closeButton = closeButton,
        background = background
    }
    
    playerGUIs[player] = guiData
    isGUIOpen[player] = false
    
    -- ─── ОБНОВЛЯЕМ ОТОБРАЖЕНИЕ СКОРОСТИ ───
    local function updateSpeedDisplay()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                speedDisplay.Text = "Текущая скорость: " .. tostring(math.round(humanoid.WalkSpeed))
            end
        end
    end
    
    -- ─── ФУНКЦИЯ УСТАНОВКИ СКОРОСТИ ───
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
    
    -- ─── ФУНКЦИЯ ПОЛЕТА ───
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
            
            flyButton.Text = "🕊️ Включить полет"
            flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
        else
            -- Включаем полет
            flyingPlayers[player] = true
            flySpeeds[player] = 10
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.Anchored = false
            end
            
            humanoid.PlatformStand = true
            
            flyButton.Text = "🕊️ Выключить полет"
            flyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
    end
    
    -- ─── ОБРАБОТЧИКИ КНОПОК ───
    speedButton.MouseButton1Click:Connect(function()
        local speedValue = speedInput.Text
        if setSpeed(speedValue) then
            speedButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            speedButton.Text = "✅ Скорость изменена!"
            task.wait(0.8)
            speedButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            speedButton.Text = "🚀 Установить скорость"
        else
            speedButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            speedButton.Text = "❌ Ошибка!"
            task.wait(0.8)
            speedButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            speedButton.Text = "🚀 Установить скорость"
        end
    end)
    
    flyButton.MouseButton1Click:Connect(toggleFly)
    
    -- ─── ЗАКРЫТИЕ GUI ───
    closeButton.MouseButton1Click:Connect(function()
        closeGUI(player)
    end)
    
    -- ─── ОБНОВЛЯЕМ ПРИ ПОЯВЛЕНИИ ПЕРСОНАЖА ───
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        updateSpeedDisplay()
        
        -- Если полет был включен, но персонаж пересоздался
        if flyingPlayers[player] then
            task.wait(0.5)
            toggleFly() -- Переключаем заново
        end
    end)
    
    -- Обновляем при запуске
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
    
    if isGUIOpen[player] then return end
    
    local screenGui = guiData.screenGui
    local mainFrame = guiData.mainFrame
    local wmButton = player.PlayerGui:FindFirstChild("WMButton")
    
    -- Показываем GUI
    screenGui.Enabled = true
    isGUIOpen[player] = true
    
    -- Анимация появления
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    
    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15,
        Size = UDim2.new(0, 350, 0, 300)
    }):Play()
    
    -- Скрываем кнопку WM
    if wmButton then
        TweenService:Create(wmButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.3)
        wmButton.Visible = false
    end
end

local function closeGUI(player)
    local guiData = playerGUIs[player]
    if not guiData then return end
    if not isGUIOpen[player] then return end
    
    local screenGui = guiData.screenGui
    local mainFrame = guiData.mainFrame
    local wmButton = player.PlayerGui:FindFirstChild("WMButton")
    
    -- Анимация закрытия
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    task.wait(0.3)
    screenGui.Enabled = false
    isGUIOpen[player] = false
    
    -- Показываем кнопку WM
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
    
    -- Удаляем старую кнопку, если есть
    local oldButton = playerGui:FindFirstChild("WMButton")
    if oldButton then oldButton:Destroy() end
    
    -- Создаем новую кнопку
    local wmButton = Instance.new("ImageButton")
    wmButton.Name = "WMButton"
    wmButton.Size = UDim2.new(0, 70, 0, 70)
    wmButton.Position = UDim2.new(0.5, -35, 0.5, -35)
    wmButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    wmButton.BackgroundTransparency = 0.2
    wmButton.Image = "rbxassetid://1316044743"
    wmButton.ImageColor3 = Color3.fromRGB(255, 100, 100)
    wmButton.ImageTransparency = 0.5
    wmButton.ZIndex = 100
    wmButton.Visible = true
    wmButton.Parent = playerGui
    
    -- Сглаживание
    local wmCorner = Instance.new("UICorner")
    wmCorner.CornerRadius = UDim.new(1, 0)
    wmCorner.Parent = wmButton
    
    -- Текст
    local wmText = Instance.new("TextLabel")
    wmText.Size = UDim2.new(1, 0, 1, 0)
    wmText.BackgroundTransparency = 1
    wmText.Text = "WM"
    wmText.TextColor3 = Color3.fromRGB(255, 255, 255)
    wmText.TextSize = 24
    wmText.Font = Enum.Font.GothamBold
    wmText.TextScaled = true
    wmText.Parent = wmButton
    
    -- Анимация пульсации
    local pulse = TweenService:Create(wmButton, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 75, 0, 75)
    })
    pulse:Play()
    
    -- ─── ПЕРЕТАСКИВАНИЕ ───
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    wmButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = wmButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    wmButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                wmButton.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    -- ─── ОТКРЫТИЕ GUI ───
    wmButton.MouseButton1Click:Connect(function()
        openGUI(player)
    end)
    
    return wmButton
end

-- ═══════════════════════════════════════════════════════════════
-- ИНИЦИАЛИЗАЦИЯ ДЛЯ ВСЕХ ИГРОКОВ
-- ═══════════════════════════════════════════════════════════════

local function setupPlayer(player)
    -- Создаем GUI
    createGUI(player)
    
    -- Создаем кнопку WM
    createWMButton(player)
    
    -- Открываем GUI при первом входе
    task.wait(0.5)
    openGUI(player)
end

-- Для уже существующих игроков
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        setupPlayer(player)
    end)
end

-- Для новых игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        -- Если GUI нет - создаем
        if not playerGUIs[player] then
            setupPlayer(player)
        end
    end)
    
    -- Если игрок уже имеет персонажа
    if player.Character then
        task.wait(0.5)
        setupPlayer(player)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ОСНОВНОЙ ЦИКЛ ПОЛЕТА
-- ═══════════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    for player, isFlying in pairs(flyingPlayers) do
        if isFlying then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and rootPart then
                    -- Настройка полета
                    humanoid.PlatformStand = true
                    rootPart.Anchored = false
                    
                    -- Получаем скорость
                    local speed = flySpeeds[player] or 10
                    
                    -- Вычисляем направление движения
                    local moveDirection = Vector3.new(0, 0, 0)
                    local camera = workspace.CurrentCamera
                    
                    if camera then
                        local forward = camera.CFrame.LookVector
                        local right = camera.CFrame.RightVector
                        
                        -- Убираем вертикальную составляющую для горизонтального движения
                        forward = Vector3.new(forward.X, 0, forward.Z).Unit
                        right = Vector3.new(right.X, 0, right.Z).Unit
                        
                        -- WASD
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
                        
                        -- Вертикаль
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            moveDirection = moveDirection + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            moveDirection = moveDirection - Vector3.new(0, 1, 0)
                        end
                    end
                    
                    -- Нормализуем и применяем скорость
                    if moveDirection.Magnitude > 0 then
                        moveDirection = moveDirection.Unit * speed
                        rootPart.Velocity = moveDirection
                    else
                        rootPart.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    -- Поворот в сторону движения (опционально)
                    if moveDirection.Magnitude > 0.1 then
                        local lookAt = rootPart.Position + moveDirection
                        local newCFrame = CFrame.lookAt(rootPart.Position, lookAt)
                        rootPart.CFrame = CFrame.new(rootPart.Position, lookAt)
                    end
                end
            else
                -- Если персонаж исчез - выключаем полет
                flyingPlayers[player] = nil
                flySpeeds[player] = nil
                
                -- Обновляем кнопку
                local guiData = playerGUIs[player]
                if guiData then
                    guiData.flyButton.Text = "🕊️ Включить полет"
                    guiData.flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ОЧИСТКА ПРИ ВЫХОДЕ
-- ═══════════════════════════════════════════════════════════════

Players.PlayerRemoving:Connect(function(player)
    flyingPlayers[player] = nil
    flySpeeds[player] = nil
    playerGUIs[player] = nil
    isGUIOpen[player] = nil
end)

-- ═══════════════════════════════════════════════════════════════
-- ГОРЯЧИЕ КЛАВИШИ
-- ═══════════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F для открытия/закрытия GUI
    if input.KeyCode == Enum.KeyCode.F then
        local player = Players.LocalPlayer
        if player then
            if isGUIOpen[player] then
                closeGUI(player)
            else
                openGUI(player)
            end
        end
    end
    
    -- X для включения/выключения полета
    if input.KeyCode == Enum.KeyCode.X then
        local player = Players.LocalPlayer
        if player then
            local guiData = playerGUIs[player]
            if guiData then
                guiData.flyButton:Activate()
            end
        end
    end
end)

print("✅ Скрипт управления персонажем успешно загружен!")
print("📌 F - открыть/закрыть меню")
print("📌 X - включить/выключить полет")
print("📌 WASD - движение в полете")
print("📌 Пробел - вверх, Shift - вниз")
