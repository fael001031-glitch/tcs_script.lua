-- ZUNO ENGINE - Módulo de Teste de Física e Automação (MPS)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ZunoScriptTest = {}
ZunoScriptTest.Active = true
ZunoScriptTest.Settings = {
    Reach = 15,             -- Alcance da bola em studs (aumenta ou diminui conforme o teste)
    AutoTeleportToBall = false, -- Coloca 'true' se quiseres teleporte instantâneo
    AutoBall = true,        -- Controla e direciona a bola automaticamente
    AutoFollow = true,      -- Segue a bola de forma dinâmica e fluida
    FollowSpeed = 30,       -- Velocidade de aproximação do AutoFollow
    GoalTargetPosition = Vector3.new(0, 0, 0)
}

-- Função para encontrar a bola no mapa
function ZunoScriptTest:FindBall()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("bola")) then
            return obj
        end
    end
    local ballFolder = Workspace:FindFirstChild("Ball") or Workspace:FindFirstChild("Matches")
    if ballFolder then
        for _, obj in ipairs(ballFolder:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("bola")) then
                return obj
            end
        end
    end
    return nil
end

function ZunoScriptTest:Initialize()
    print("🚀 [ZUNO ENGINE] - Reach, AutoBall e AutoFollow Ativados!")
    
    RunService.RenderStepped:Connect(function(dt)
        if not ZunoScriptTest.Active then return end
        
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPart = character.HumanoidRootPart
        local ball = self:FindBall()
        
        if ball then
            local distance = (ball.Position - rootPart.Position).Magnitude
            
            -- Função Reach: Se a bola estiver dentro do alcance personalizado
            if distance <= self.Settings.Reach then
                
                -- Função AutoFollow: Aproximação suave
                if self.Settings.AutoFollow and not self.Settings.AutoTeleportToBall then
                    local targetCFrame = CFrame.new(rootPart.Position, Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z))
                    rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame + (ball.Position - rootPart.Position).Unit * math.min(distance, self.Settings.FollowSpeed * dt), 0.5)
                end

                -- Teleporte Direto (se ativado)
                if self.Settings.AutoTeleportToBall then
                    rootPart.CFrame = ball.CFrame * CFrame.new(0, 2, 0)
                end
                
                -- Função AutoBall: Manipula a física da bola quando ela estiver dentro do Reach
                if self.Settings.AutoBall and ball:IsA("BasePart") then
                    ball.AssemblyLinearVelocity = Vector3.new(0, 65, 0)
                end
            end
        end
    end)
end

-- Executa o teste de automação
ZunoScriptTest:Initialize()
