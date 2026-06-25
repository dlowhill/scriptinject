-- ═══════════════════════════════════════════════════════════════
-- АДМИН-ПАНЕЛЬ WISPMANE ДЛЯ 99 НОЧЕЙ В ЛЕСУ
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")

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
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

local function createRoundedFrame(parent, size, position, color, transparency)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(0, 350, 0, 450) -- Увеличен размер под 4 кнопки
    frame.Position = position or UDim2.new(0.5, -175, 0.5, -225)
    frame.BackgroundColor3 = color or Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = transparency or 0.15
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    return frame
end

local closeGUI 

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
    
    local mainFrame = createRoundedFrame(screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundTransparency = 1 
    
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316044743"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.Parent = mainFrame
    
    -- Название изменено на WispMane
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
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0.9, 0, 0, 2)
    divider.Position = UDim2.new(0.05, 0, 0, 42)
    divider.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    divider.BorderSizePixel = 0
    divider.Parent = mainFrame
    
    -- Кнопка закрытия справа сверху
    local closeButton = Instance.new("ImageButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 8)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.BackgroundTransparency = 0.2
    closeButton.Image = "" 
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton 

    local closeText = Instance.new("TextLabel")
    closeText.Size = UDim2.new(1, 0, 1, 0)
    closeText.BackgroundTransparency = 1
    closeText.Text = "✕"
    closeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeText.TextSize = 16
    closeText.Font = Enum.Font.GothamBold
    closeText.TextXAlignment = Enum.TextXAlignment.Center
    closeText.TextYAlignment = Enum.TextYAlignment.Center
    closeText.Parent = closeButton
    
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
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = speedInput
    
    -- Кнопка 1: Установка скорости
    local speedButton = createRoundedButton(mainFrame, "🚀 Установить скорость", Color3.fromRGB(255, 100, 100), 
        UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0, 110))
    
    -- Кнопка 2: Полёт
    local flyButton = createRoundedButton(mainFrame, "🕊️ Включить полет", Color3.fromRGB(80, 150, 255),
        UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0, 165))
        
    -- Кнопка 3: Мгновенная массовая вырубка
    local chopButton = createRoundedButton(mainFrame, "🪓 Вырубить весь лес", Color3.fromRGB(230, 140, 10),
        UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0, 220))
        
    -- Кнопка 4: Магнит лута (притянуть все палки)
    local magnetButton = createRoundedButton(mainFrame, "🧲 Притянуть весь лут", Color3.fromRGB(40, 180, 130),
        UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0, 275))
    
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
        speedDisplay = speedDisplay,
        closeButton = closeButton,
        background = background
    }
    
    playerGUIs[player] = guiData
    isGUIOpen[player] = false
    
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
                rootPart.Anchored = false
            end
            humanoid.PlatformStand = false
            humanoid.Sit = false
            
            if flyButton and flyButton.Parent then
                flyButton.Text = "🕊️ Включить полет"
                flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            end
        else
            flyingPlayers[player] = true
            flySpeeds[player] = 30
            humanoid.PlatformStand = true
            if flyButton and flyButton.Parent then
                flyButton.Text = "🕊️ Выключить полет"
                flyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            end
        end
    end 

    -- Скрипт Логики Локальной Вырубки Леса
    local function chopAllTrees()
        local mapLandmarks = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Landmarks")
        if not mapLandmarks then return end
        
        chopButton.Text = "⏳ Вырубка..."
        chopButton.BackgroundColor3 = Color3.fromRGB(150, 100, 20)
        for _, object in ipairs(mapLandmarks:GetChildren()) do
    if object:IsA("Model") and (object.Name == "Small Tree" or object.Name:find("TreeBig")) then
        task.spawn(function()
            -- Безопасно уничтожаем дерево, имитируя работу LandmarkModules
            local module = ServerStorage:FindFirstChild("LandmarkModules") and ServerStorage.LandmarkModules:FindFirstChild(object.Name)
            
            if module then
                pcall(function()
                    require(module)(object)
                end)
            end
            
            -- Мгновенно ломаем дерево, чтобы DropHandler выплюнул палки
            object:Destroy()
        end)
    end
end

task.wait(0.5)
chopButton.Text = "✅ Лес вырублен!"
chopButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
task.wait(0.8)
chopButton.Text = "🪓 Вырубить весь лес"
chopButton.BackgroundColor3 = Color3.fromRGB(230, 140, 10)
end

-- Логика Магнита Лута (Сбор палок/бревен)
local function magnetAllLoot()
    local itemsFolder = workspace:FindFirstChild("Items")
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not itemsFolder or not rootPart then
        return
    end
    
    magnetButton.Text = "⏳ Притягивание..."
    magnetButton.BackgroundColor3 = Color3.fromRGB(20, 120, 90)
    
    local targetPosition = rootPart.Position + Vector3.new(0, -2, 0)
    local count = 0
    
    for _, item in ipairs(itemsFolder:GetChildren()) do
        local itemRoot = item:FindFirstChild("Handle") or item:IsA("BasePart") and item or item:FindFirstChild("PrimaryPart")
        
        if itemRoot then
            pcall(function()
                if itemRoot:IsA("BasePart") then
                    itemRoot.Anchored = true
                    itemRoot.CFrame = CFrame.new(targetPosition)
                    itemRoot.Anchored = false
                elseif item:IsA("Model") then
                    item:PivotTo(CFrame.new(targetPosition))
                end
                
                count += 1
            end)
        end
    end
    
    task.wait(0.4)
    magnetButton.Text = "✅ Собрано объектов: " .. tostring(count)
    magnetButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    task.wait(1)
    magnetButton.Text = "🧲 Притянуть весь лут"
    magnetButton.BackgroundColor3 = Color3.fromRGB(40, 180, 130)
end

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

closeButton.MouseButton1Click:Connect(function()
    closeGUI(player)
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    updateSpeedDisplay()
    
    if flyingPlayers[player] then
        task.wait(0.5)
        toggleFly()
    end
end)

task.wait(0.5)
updateSpeedDisplay()
return guiData
end

-- ═══════════════════════════════════════════════════════════════
-- ФУНКЦИИ ОТКРЫТИЯ/ЗАКРЫТИЯ GUI (Починено)
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
    
    screenGui.Enabled = true
    isGUIOpen[player] = true
    
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    
    TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15,
        Size = UDim2.new(0, 350, 0, 450)
    }):Play()
    
    if wmButton then
        TweenService:Create(wmButton, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.delay(0.25, function()
            wmButton.Visible = false
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
    
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    isGUIOpen[player] = false
    
    task.delay(0.25, function()
        screenGui.Enabled = false
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
-- СОЗДАНИЕ КНОПКИ WM (Починено открытие)
-- ═══════════════════════════════════════════════════════════════
local dragging = false
local dragStart = nil
local startPos = nil

local function createWMButton(player)
    local playerGui = player:WaitForChild("PlayerGui")
    local oldButton = playerGui:FindFirstChild("WMButton")
    
    if oldButton then
        oldButton:Destroy()
    end
    
    local wmButton = Instance.new("ImageButton")
    wmButton.Name = "WMButton"
    wmButton.Size = UDim2.new(0, 70, 0, 70)
    wmButton.Position = UDim2.new(0.85, 0, 0.15, 0) -- Удобная позиция сбоку
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
    
    wmButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = wmButton.Position
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
    
    wmButton.MouseButton1Click:Connect(function()
        openGUI(player)
    end)
    
    return wmButton
end

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
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
        task.wait(0.5)
        
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
-- ИДЕАЛЬНЫЙ ЦИКЛ ПОЛЕТА БЕЗ ТРЯСКИ
-- ═══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    for player, isFlying in pairs(flyingPlayers) do
        if isFlying then
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                humanoid.PlatformStand = true
                
                local speed = flySpeeds[player] or 30
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
                    rootPart.Anchored = false
                    moveDirection = moveDirection.Unit * speed
                    rootPart.Velocity = moveDirection
                    rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + moveDirection)
                else
                    -- Идеальная заморозка в воздухе при остановке
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                    rootPart.Anchored = true
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    flyingPlayers[player] = nil
    flySpeeds[player] = nil
    playerGUIs[player] = nil
    isGUIOpen[player] = nil
end)
