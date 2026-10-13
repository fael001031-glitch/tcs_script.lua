-- ZUNO ENGINE - Módulo por Comandos de Chat (Compatível com Xeno)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ZunoScript = {}
ZunoScript.Active = true
ZunoScript.Settings = {
    Reach = 15,
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 30
}

-- Função para localizar a bola no Workspace
function ZunoScript:FindBall()
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

-- Sistema de Comandos via Chat do Roblox
LocalPlayer.Chatted:Connect(function(message)
    local msg = message:lower()
    local args = string.split(msg, " ")

    if args[1] == "/reach" and args[2] then
        local val = tonumber(args[2])
        if val then
            ZunoScript.Settings.Reach = val
            print("⚡ [ZUNO ENGINE] Reach alterado para: " .. val)
        end
    elseif msg == "/autoball" then
        ZunoScript.Settings.AutoBall = not ZunoScript.Settings.AutoBall
        print("⚡ [ZUNO ENGINE] AutoBall: " .. tostring(ZunoScript.Settings.AutoBall))
    elseif msg == "/autofollow" then
        ZunoScript.Settings.AutoFollow = not ZunoScript.Settings.AutoFollow
        print("⚡ [ZUNO ENGINE] AutoFollow: " .. tostring(ZunoScript.Settings.AutoFollow))
    elseif msg == "/teleport" then
        ZunoScript.Settings.AutoTeleport = not ZunoScript.Settings.AutoTeleport
        print("⚡ [ZUNO ENGINE] Teleport: " .. tostring(ZunoScript.Settings.AutoTeleport))
    elseif msg == "/status" then
        print("--- ZUNO ENGINE STATUS ---")
        print("Reach: " .. ZunoScript.Settings.Reach)
        print("AutoBall: " .. tostring(ZunoScript.Settings.AutoBall))
        print("AutoFollow: " .. tostring(ZunoScript.Settings.AutoFollow))
        print("Teleport: " .. tostring(ZunoScript.Settings.AutoTeleport))
    end
end)

-- Loop principal de execução
function ZunoScript:Initialize()
    print("🚀 [ZUNO ENGINE] Carregado com sucesso! Usa os comandos no chat.")
    
    RunService.RenderStepped:Connect(function(dt)
        if not ZunoScript.Active then return end
        
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPart = character.HumanoidRootPart
        local ball = self:FindBall()
        
        if ball then
            local distance = (ball.Position - rootPart.Position).Magnitude
            
            if distance <= self.Settings.Reach then
                if self.Settings.AutoFollow and not self.Settings.AutoTeleport then
                    local targetCFrame = CFrame.new(rootPart.Position, Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z))
                    rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame + (ball.Position - rootPart.Position).Unit * math.min(distance, self.Settings.FollowSpeed * dt), 0.5)
                end

                if self.Settings.AutoTeleport then
                    rootPart.CFrame = ball.CFrame * CFrame.new(0, 2, 0)
                end
                
                if self.Settings.AutoBall and ball:IsA("BasePart") then
                    ball.AssemblyLinearVelocity = Vector3.new(0, 50, 0)
                end
            end
        end
    end)
end

ZunoScript:Initialize()
