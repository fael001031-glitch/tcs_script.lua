-- ==========================================================
-- ZUNO ENGINE - TCS (Fluent UI Library Oficial)
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

-- Carrega a Fluent Library de forma totalmente segura
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "⚡ ZUNO ENGINE - TCS",
    SubTitle = "por Rafael",
    TabWidth = 160,
    Size = UDim2.fromOffset(480, 360),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Insert
})

local Tabs = {
    Main = Window:AddTab({ Title = "Principal", Icon = "home" })
}

-- Toggles
Tabs.Main:AddToggle("AutoFollowToggle", {
    Title = "AutoFollow",
    Default = false,
    Callback = function(Value)
        Config.AutoFollow = Value
    end
})

Tabs.Main:AddToggle("AutoBallToggle", {
    Title = "AutoBall (Ímã)",
    Default = false,
    Callback = function(Value)
        Config.AutoBall = Value
    end
})

Tabs.Main:AddToggle("TeleportToggle", {
    Title = "Teleport Ball",
    Default = false,
    Callback = function(Value)
        Config.AutoTeleport = Value
    end
})

-- Slider de Reach
Tabs.Main:AddSlider("ReachSlider", {
    Title = "Alcance do Reach (Studs)",
    Description = "Ajusta o raio de alcance das funções",
    Default = 45,
    Min = 10,
    Max = 150,
    Rounding = 0,
    Callback = function(Value)
        Config.Reach = Value
    end
})

-- Função de busca da bola no TCS
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

-- Loop Principal
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

print("🚀 [ZUNO ENGINE] Fluent UI Carregada com Sucesso!")
