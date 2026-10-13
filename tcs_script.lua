-- ==========================================================
-- ZUNO ENGINE - TCS (Menu Definitivo via Rayfield Library)
-- ==========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Active = true,
    Reach = 45,
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 24
}

-- Carrega a interface gráfica profissional compatível com Xeno
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡ ZUNO ENGINE - TCS",
   LoadingTitle = "Zuno Engine",
   LoadingSubtitle = "por Rafael",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Principal", 4483362458)

-- Botão/Toggle: AutoFollow
Tab:CreateToggle({
   Name = "AutoFollow",
   CurrentValue = false,
   Callback = function(Value)
      Config.AutoFollow = Value
   end,
})

-- Botão/Toggle: AutoBall (Ímã)
Tab:CreateToggle({
   Name = "AutoBall (Ímã)",
   CurrentValue = false,
   Callback = function(Value)
      Config.AutoBall = Value
   end,
})

-- Botão/Toggle: Teleport
Tab:CreateToggle({
   Name = "Teleport Ball",
   CurrentValue = false,
   Callback = function(Value)
      Config.AutoTeleport = Value
   end,
})

-- ReachBox (Slider para ajustar o Reach em tempo real)
Tab:CreateSlider({
   Name = "Alcance do Reach (Studs)",
   Range = {10, 150},
   Increment = 5,
   Suffix = "Studs",
   CurrentValue = 45,
   Callback = function(Value)
      Config.Reach = Value
   end,
})

-- Busca da Bola no TCS
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

-- Loop Principal das Funções
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

            -- Teleport
            if Config.AutoTeleport then
                rootPart.CFrame = ball.CFrame * CFrame.new(0, 3, 0)
            end
            
            -- AutoBall (Ímã)
            if Config.AutoBall then
                pcall(function()
                    ball.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2.5)
                    ball.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
                end)
            end
        end
    end
end)

print("🚀 [ZUNO ENGINE] Menu Rayfield Carregado com Sucesso!")
