-- ZUNO ENGINE - Módulo Ultra Compatível (Xeno / MPS)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ZunoScript = {
    Active = true,
    Reach = 20,
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 30
}

-- Procura a bola no mapa sem falhar
local function FindBall()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("bola")) then
            return obj
        end
    end
    local ballFolder = Workspace:FindFirstChild("Ball") or Workspace:FindFirstChild("Matches") or Workspace:FindFirstChild("Pitch")
    if ballFolder then
        for _, obj in ipairs(ballFolder:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("bola")) then
                return obj
            end
        end
    end
    return nil
end

-- Atalhos de Teclado (Evita bloqueios do Chat do Roblox)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Tecla 'F': Liga/Desliga o AutoFollow
    if input.KeyCode == Enum.KeyCode.F then
        ZunoScript.AutoFollow = not ZunoScript.AutoFollow
        print("⚡ [ZUNO] AutoFollow:", ZunoScript.AutoFollow)
    
    -- Tecla 'E': Liga/Desliga o AutoBall (Impulso no gol)
    elseif input.KeyCode == Enum.KeyCode.E then
        ZunoScript.AutoBall = not ZunoScript.AutoBall
        print("⚡ [ZUNO] AutoBall:", ZunoScript.AutoBall)

    -- Tecla 'R': Liga/Desliga o Teleporte Direto
    elseif input.KeyCode == Enum.KeyCode.R then
        ZunoScript.AutoTeleport = not ZunoScript.AutoTeleport
        print("⚡ [ZUNO] Teleport:", ZunoScript.AutoTeleport)
    end
end)

-- Loop principal
RunService.RenderStepped:Connect(function(dt)
    if not ZunoScript.Active then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local ball = FindBall()
    if ball then
        local distance = (ball.Position - rootPart.Position).Magnitude
        
        -- Se a bola estiver dentro do Reach definido
        if distance <= ZunoScript.Reach then
            
            -- AutoFollow (Seguir suavemente)
            if ZunoScript.AutoFollow and not ZunoScript.AutoTeleport then
                local targetPos = Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z)
                rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.Position, targetPos) + (ball.Position - rootPart.Position).Unit * math.min(distance, ZunoScript.FollowSpeed * dt), 0.3)
            end

            -- Teleporte Direto para a bola
            if ZunoScript.AutoTeleport then
                rootPart.CFrame = ball.CFrame * CFrame.new(0, 2, 0)
            end
            
            -- AutoBall (Impulso na bola)
            if ZunoScript.AutoBall and ball:IsA("BasePart") then
                ball.AssemblyLinearVelocity = Vector3.new(0, 50, 0)
            end
        end
    end
end)

print("🚀 [ZUNO ENGINE] Script Ativo! Usa as teclas F (Follow), E (AutoBall) e R (Teleport).")
