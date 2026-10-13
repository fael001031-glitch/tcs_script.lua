-- ==========================================================
-- ZUNO ENGINE - TCS ULTIMATE (Versão Especial para XENO)
-- ==========================================================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configurações
local Config = {
    Active = true,
    Reach = 45,
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 22
}

-- 1. Janela Principal (Orion GUI - Roda liso no Xeno)
local Window = OrionLib:MakeWindow({
    Name = "⚡ ZUNO ENGINE - TCS",
    HidePremium = true,
    SaveConfig = false,
    ConfigFolder = "ZunoTCS"
})

local Tab = Window:MakeTab({
    Name = "Automações",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- 2. Toggles e Controles
Tab:AddToggle({
    Name = "AutoFollow (Seguir Bola)",
    Default = false,
    Callback = function(Value)
        Config.AutoFollow = Value
    end    
})

Tab:AddToggle({
    Name = "AutoBall (Ímã na Bola)",
    Default = false,
    Callback = function(Value)
        Config.AutoBall = Value
    end    
})

Tab:AddToggle({
    Name = "Teleport Ball (Teleportar)",
    Default = false,
    Callback = function(Value)
        Config.AutoTeleport = Value
    end    
})

Tab:AddTextbox({
    Name = "Alcance do Reach (Studs)",
    Default = "45",
    TextDisappear = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val then
            Config.Reach = val
        end
    end
})

-- 3. Função de busca da bola
local function GetBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("ball") or name:find("bola") or name:find("sph") or (obj.Size.X <= 3 and obj.Size.Y <= 3 and obj.Shape == Enum.PartType.Ball) then
                if not obj.Parent:FindFirstChild("Humanoid") then
                    return obj
                end
            end
        end
    end
    return nil
end

-- 4. Loop de Execução
RunService.RenderStepped:Connect(function(dt)
    if not Config.Active then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local ball = GetBall()
    if ball then
        local distance = (ball.Position - rootPart.Position).Magnitude
        
        if distance <= Config.Reach then
            -- AutoFollow
            if Config.AutoFollow and not Config.AutoTeleport then
                local targetPos = Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z)
                rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.Position, targetPos) + (ball.Position - rootPart.Position).Unit * math.min(distance, Config.FollowSpeed * dt), 0.25)
            end

            -- Teleport Ball
            if Config.AutoTeleport then
                rootPart.CFrame = ball.CFrame * CFrame.new(0, 3, 0)
            end
            
            -- Ímã / AutoBall
            if Config.AutoBall then
                pcall(function()
                    ball.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2.5)
                    ball.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
                end)
            end
        end
    end
end)

OrionLib:Init()
