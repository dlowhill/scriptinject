-- Расширенный скрипт управления персонажем с GUI и полетом
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Переменные для управления полетом
local flyingPlayers = {}
local flySpeeds = {}
local guiStates = {} -- Хранит состояние GUI для каждого игрока

-- Функция создания кнопки WM
local function createWMButton(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Кнопка WM
    local wmButton = Instance.new("ImageButton")
    wmButton.Name = "WMButton"
    wmButton.Size = UDim2.new(0, 70, 0, 70)
    wmButton.Position = UDim2.new(0.5, -35, 0.5, -35)
    wmButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    wmButton.BackgroundTransparency = 0.2
    wmButton.Image = "rbxassetid://1316044743" -- Круглая тень
    wmButton.ImageColor3 = Color3.fromRGB(255, 100, 100)
    wmButton.ImageTransparency = 0.5
    wmButton.ZIndex = 100
    wmButton.Parent = playerGui
    
    -- Сглаживание
    local wmCorner = Instance.new("UICorner")
    wmCorner.CornerRadius = UDim.new(1, 0)
    wmCorner.Parent = wmButton
    
    -- Текст WM
    local wmText = Instance.new("TextLabel")
    wmText.Size = UDim2.new(1, 0, 1, 0)
    wmText.Position = UDim2.new(0, 0, 0, 0)
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
    
    -- Перетаскивание кнопки
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
    
    return wmButton
end

-- Функция создания GUI
local function createGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Проверяем, есть ли уже GUI
    if playerGui:FindFirstChild("SpeedFlyGUI") then
        return
    end
    
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedFlyGUI"
    screenGui.Parent = playerGui
    
    -- Затемнение фона
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.Parent = screenGui
    
    -- Главный фрейм
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Сглаживание углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Тень
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316044743"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.Parent = mainFrame
    
    -- Кнопка закрытия
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
    closeText.Position = UDim2.new(0, 0, 0, 0)
    closeText.BackgroundTransparency = 1
    closeText.Text = "✕"
    closeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeText.TextSize = 18
    closeText.Font = Enum.Font.GothamBold
    closeText.Parent = closeButton
    
    -- Заголовок
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
    
    -- Поле для ввода скорости
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
    
    -- Сглаживание для поля ввода
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = speedInput
    
    -- Кнопка установки скорости
    local speedButton = Instance.new("TextButton")
    speedButton.Size = UDim2.new(0.6, 0, 0, 45)
    speedButton.Position = UDim2.new(0.2, 0, 0, 115)
    speedButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    speedButton.BackgroundTransparency = 0.2
    speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedButton.TextSize = 16
    speedButton.Font = Enum.Font.GothamBold
    speedButton.Text = "🚀 Установить скорость"
    speedButton.Parent = mainFrame
    
    -- Сглаживание для кнопки
    local speedButtonCorner = Instance.new("UICorner")
    speedButtonCorner.CornerRadius = UDim.new(0, 8)
    speedButtonCorner.Parent = speedButton
    
    -- Кнопка полета
    local flyButton = Instance.new("TextButton")
    flyButton.Size = UDim2.new(0.6, 0, 0, 45)
    flyButton.Position = UDim2.new(0.2, 0, 0, 175)
    flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
    flyButton.BackgroundTransparency = 0.2
    flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyButton.TextSize = 16
    flyButton.Font = Enum.Font.GothamBold
    flyButton.Text = "🕊️ Включить полет"
    flyButton.Parent = mainFrame
    
    -- Сглаживание для кнопки
    local flyButtonCorner = Instance.new("UICorner")
    flyButtonCorner.CornerRadius = UDim.new(0, 8)
    flyButtonCorner.Parent = flyButton
    
    -- Индикатор скорости
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
    
    -- Анимация появления
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15,
        Size = UDim2.new(0, 350, 0, 300)
    }):Play()
    
    -- Функция обновления скорости
    local function setSpeed(speed)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = tonumber(speed) or 16
                speedDisplay.Text = "Текущая скорость: " .. tostring(humanoid.WalkSpeed)
                return true
            end
        end
        return false
    end
    
    -- Функция полета
    local function toggleFly()
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local isFlying = flyingPlayers[player]
        
        if isFlying then
            -- Выключаем полет
            flyingPlayers[player] = nil
            flySpeeds[player] = nil
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.Anchored = false
            end
            
            humanoid.PlatformStand = false
            
            flyButton.Text = "🕊️ Включить полет"
            flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            
        else
            -- Включаем полет
            flyingPlayers[player] = true
            flySpeeds[player] = 10
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.Anchored = true
            end
            
            humanoid.PlatformStand = true
            
            flyButton.Text = "🕊️ Выключить полет"
            flyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
    end
    
    -- Обработчики кнопок
    speedButton.MouseButton1Click:Connect(function()
        local speedValue = tonumber(speedInput.Text)
        if speedValue then
            if setSpeed(speedValue) then
                speedButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                speedButton.Text = "✅ Скорость изменена!"
                wait(0.8)
                speedButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
                speedButton.Text = "🚀 Установить скорость"
            else
                speedButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                speedButton.Text = "❌ Ошибка!"
                wait(0.8)
                speedButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
                speedButton.Text = "🚀 Установить скорость"
            end
        else
            speedButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            speedButton.Text = "⚠️ Введите число!"
            wait(0.8)
            speedButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            speedButton.Text = "🚀 Установить скорость"
        end
    end)
    
    flyButton.MouseButton1Click:Connect(toggleFly)
    
    -- Кнопка закрытия
    closeButton.MouseButton1Click:Connect(function()
        -- Закрываем GUI
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        wait(0.3)
        screenGui.Enabled = false
        
        -- Показываем кнопку WM
        local wmButton = playerGui:FindFirstChild("WMButton")
        if wmButton then
            wmButton.Visible = true
            TweenService:Create(wmButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 70, 0, 70),
                BackgroundTransparency = 0.2
            }):Play()
        end
    end)
    
    -- Создаем кнопку WM если её нет
    if not playerGui:FindFirstChild("WMButton") then
        local wmButton = createWMButton(player)
        
        wmButton.MouseButton1Click:Connect(function()
            -- Открываем GUI
            screenGui.Enabled = true
            
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.15,
                Size = UDim2.new(0, 350, 0, 300)
            }):Play()
            
            -- Скрываем кнопку WM
            TweenService:Create(wmButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            
            wait(0.3)
            wmButton.Visible = false
        end)
    end
    
    -- Обновляем отображение скорости
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            speedDisplay.Text = "Текущая скорость: " .. tostring(humanoid.WalkSpeed)
        end
    end
    
    return {
        speedButton = speedButton,
        flyButton = flyButton,
        speedInput = speedInput,
        speedDisplay = speedDisplay,
        mainFrame = mainFrame,
        screenGui = screenGui
    }
end

-- Подключаем GUI для всех игроков
for _, player in ipairs(Players:GetPlayers()) do
    createGUI(player)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        if not player.PlayerGui:FindFirstChild("SpeedFlyGUI") then
            createGUI(player)
        end
    end)
end)

-- Основной цикл управления полетом
RunService.Heartbeat:Connect(function()
    for player, isFlying in pairs(flyingPlayers) do
        if isFlying then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and rootPart then
                    humanoid.PlatformStand = true
                    rootPart.Anchored = true
                    
                    -- Управление полетом
                    local moveVector = Vector3.new(0, 0, 0)
                    local speed = flySpeeds[player] or 10
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveVector = moveVector + rootPart.CFrame.LookVector * speed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveVector = moveVector - rootPart.CFrame.LookVector * speed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveVector = moveVector - rootPart.CFrame.RightVector * speed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveVector = moveVector + rootPart.CFrame.RightVector * speed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveVector = moveVector + Vector3.new(0, speed, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        moveVector = moveVector - Vector3.new(0, speed, 0)
                    end
                    
                    rootPart.Velocity = moveVector
                end
            else
                -- Если персонаж исчез - выключаем полет
                flyingPlayers[player] = nil
                flySpeeds[player] = nil
            end
        end
    end
end)

-- Очистка при выходе игрока
Players.PlayerRemoving:Connect(function(player)
    flyingPlayers[player] = nil
    flySpeeds[player] = nil
end)
