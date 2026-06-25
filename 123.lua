-- Автономный скрипт управления скоростью персонажа
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function setWalkSpeed(player)
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        if humanoid.WalkSpeed ~= 25 then
            humanoid.WalkSpeed = 25
        end
    end
end

local function onCharacterAdded(player, character)
    character:WaitForChild("Humanoid")
    setWalkSpeed(player)
end

local function setupPlayer(player)
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
    
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            if humanoid.WalkSpeed ~= 25 then
                humanoid.WalkSpeed = 25
            end
        end
    end
end)