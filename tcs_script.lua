-- ==========================================================
-- ZUNO ENGINE - TCS (100% NATIVO PARA XENO EXECUTOR)
-- ==========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configurações das Funções
local Config = {
    Active = true,
    Reach = 45,
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 22
}

-- Limpa versões antigas
if PlayerGui:FindFirstChild("ZunoEngineXeno") then
    PlayerGui.ZunoEngineXeno:Destroy()
end

-- 1. Criação do ScreenGui no PlayerGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZunoEngineXeno"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 2. Janela Principal (Posicionada visível no canto esquerdo superior)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 310)
MainFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 230, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "⚡ ZUNO ENGINE - TCS"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Criador de Botões Simples
local function CreateButton(text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, posY, 0)
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = MainFrame

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
    end)
    return btn
end

-- Botões do Painel
CreateButton("AutoFollow", 0.15, function(s) Config.AutoFollow = s end)
CreateButton("AutoBall (Ímã)", 0.28, function(s) Config.AutoBall = s end)
CreateButton("Teleport Ball", 0.41, function(s) Config.AutoTeleport = s end)

-- Alcance / Reach Label
local ReachLabel = Instance.new("TextLabel")
ReachLabel.Size = UDim2.new(0.9, 0, 0, 18)
ReachLabel.Position = UDim2.new(0.05, 0, 0.54, 0)
ReachLabel.BackgroundTransparency = 1
ReachLabel.Text = "Alcance do Reach (Studs):"
ReachLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ReachLabel.Font = Enum.Font.SourceSans
ReachLabel.TextSize = 12
ReachLabel.Parent = MainFrame

-- Reach Box
local ReachBox = Instance.new("TextBox")
ReachBox.Size = UDim2.new(0.9, 0, 0, 28)
ReachBox.Position = UDim2.new(0.05, 0, 0.62, 0)
ReachBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
ReachBox.Text = tostring(Config.Reach)
ReachBox.TextColor3 = Color3.fromRGB(0, 230, 255)
ReachBox.Font = Enum.Font.SourceSansBold
ReachBox.TextSize = 14
ReachBox.Parent = MainFrame

ReachBox.FocusLost:Connect(function()
    local val = tonumber(ReachBox.Text)
    if val then
        Config.Reach = val
    else
        ReachBox.Text = tostring(Config.Reach)
    end
end)

-- Ajuda Atalho
local HelpLabel = Instance.new("TextLabel")
HelpLabel.Size = UDim2.new(0.9, 0, 0, 20)
HelpLabel.Position = UDim2.new(0.05, 0, 0.88, 0)
HelpLabel.BackgroundTransparency = 1
HelpLabel.Text = "Tecla 'INSERT' Abre/Fecha"
HelpLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
HelpLabel.Font = Enum.Font.SourceSansItalic
HelpLabel.TextSize = 11
HelpLabel.Parent = MainFrame

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 3. Função de busca da Bola
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

-- 4. Loop das Automações
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
            if Config.AutoFollow and not Config.AutoTeleport then
                local targetPos = Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z)
                rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.Position, targetPos) + (ball.Position - rootPart.Position).Unit * math.min(distance, Config.FollowSpeed * dt), 0.25)
            end

            if Config.AutoTeleport then
                rootPart.CFrame = ball.CFrame * CFrame.new(0, 3, 0)
            end
            
            if Config.AutoBall then
                pcall(function()
                    ball.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2.5)
                    ball.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
                end)
            end
        end
    end
end)

print("🚀 Zuno Engine carregado no Xeno!")
