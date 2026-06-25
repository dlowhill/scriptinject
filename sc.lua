-- Расширенный скрипт управления персонажем с GUI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Переменные для управления полетом
local flyingPlayers = {}
local flySpeeds = {}

-- Функция создания GUI
local function createGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedFlyGUI"
    screenGui.Parent = playerGui
    
    -- Главный фрейм
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.1
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
    speedInput.Position = UDim2.new(0.15, 0, 0, 55)
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
    speedButton.Position = UDim2.new(0.2, 0, 0, 105)
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
    flyButton.Position = UDim2.new(0.2, 0, 0, 160)
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
    
    -- Анимация появления
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 350, 0, 250)
    }):Play()
    
    -- Функция обновления скорости
    local function setSpeed(speed)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = tonumber(speed) or 16
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
            
            humanoid.PlatformStand = false
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.Anchored = false
            end
            
            flyButton.Text = "🕊️ Включить полет"
            flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            
        else
            -- Включаем полет
            flyingPlayers[player] = true
            flySpeeds[player] = 10
            
            humanoid.PlatformStand = true
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Anchored = true
                rootPart.Velocity = Vector3.new(0, 0, 0)
            end
            
            flyButton.Text = "🕊️ Выключить полет"
            flyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
    end
    
    -- Обработчики кнопок
    speedButton.MouseButton1Click:Connect(function()
        local speedValue = tonumber(speedInput.Text)
        if speedValue then
            if setSpeed(speedValue) then
                -- Успешно
                speedButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                speedButton.Text = "✅ Скорость изменена!"
                wait(0.8)
                speedButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
                speedButton.Text = "🚀 Установить скорость"
            else
                -- Ошибка
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
    
    -- Возвращаем кнопки для обновления ссылок
    return {
        speedButton = speedButton,
        flyButton = flyButton,
        speedInput = speedInput
    }
end

-- Подключаем GUI для всех игроков
for _, player in ipairs(Players:GetPlayers()) do
    createGUI(player)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        createGUI(player)
    end)
end)

-- Цикл управления полетом
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
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveVector = moveVector + rootPart.CFrame.LookVector * flySpeeds[player]
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveVector = moveVector - rootPart.CFrame.LookVector * flySpeeds[player]
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveVector = moveVector - rootPart.CFrame.RightVector * flySpeeds[player]
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveVector = moveVector + rootPart.CFrame.RightVector * flySpeeds[player]
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveVector = moveVector + Vector3.new(0, flySpeeds[player], 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        moveVector = moveVector - Vector3.new(0, flySpeeds[player], 0)
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