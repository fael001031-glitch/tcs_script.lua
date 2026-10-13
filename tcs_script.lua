-- ==========================================================
-- ZUNO ENGINE - TCS (The Classic Soccer) | Versão Limpa do Zero
-- ==========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configurações e Estado das Funções
local Config = {
    Active = true,
    Reach = 45,             -- Alcance inicial em Studs
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 24        -- Velocidade suave para o AutoFollow
}

-- 1. Destrói menus antigos para não bugar
if CoreGui:FindFirstChild("ZunoZeroGui") then
    CoreGui.ZunoZeroGui:Destroy()
end
if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ZunoZeroGui") then
    LocalPlayer.PlayerGui.ZunoZeroGui:Destroy()
end

-- 2. Sistema de Busca da Bola específico para o TCS
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

-- 3. Criação da Interface (100% Funcional e Arrastável)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZunoZeroGui"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 310)
MainFrame.Position = UDim2.new(0.08, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "⚡ ZUNO ENGINE - TCS"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Função auxiliar para criar botões de forma limpa
local function CreateToggleButton(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, posY, 0)
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Text = name .. ": DESLIGADO"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = MainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
            btn.Text = name .. ": LIGADO"
        else
            btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            btn.Text = name .. ": DESLIGADO"
        end
    end)
    return btn
end

-- Criando os Botões no Menu
CreateToggleButton("AutoFollow", 0.15, function(state)
    Config.AutoFollow = state
end)

CreateToggleButton("AutoBall (Ímã)", 0.28, function(state)
    Config.AutoBall = state
end)

CreateToggleButton("Teleport Ball", 0.41, function(state)
    Config.AutoTeleport = state
end)

-- Reach Label e Caixa de Texto (ReachBox)
local ReachLabel = Instance.new("TextLabel")
ReachLabel.Size = UDim2.new(0.9, 0, 0, 20)
ReachLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
ReachLabel.BackgroundTransparency = 1
ReachLabel.Text = "Alcance do Reach (Studs):"
ReachLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ReachLabel.Font = Enum.Font.SourceSans
ReachLabel.TextSize = 13
ReachLabel.Parent = MainFrame

local ReachBox = Instance.new("TextBox")
ReachBox.Size = UDim2.new(0.9, 0, 0, 28)
ReachBox.Position = UDim2.new(0.05, 0, 0.63, 0)
ReachBox.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
ReachBox.Text = tostring(Config.Reach)
ReachBox.TextColor3 = Color3.fromRGB(0, 230, 255)
ReachBox.Font = Enum.Font.SourceSansBold
ReachBox.TextSize = 14
ReachBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = ReachBox

ReachBox.FocusLost:Connect(function()
    local val = tonumber(ReachBox.Text)
    if val then
        Config.Reach = val
    else
        ReachBox.Text = tostring(Config.Reach)
    end
end)

-- Tecla Atalho para abrir/fechar o menu
local HelpLabel = Instance.new("TextLabel")
HelpLabel.Size = UDim2.new(0.9, 0, 0, 25)
HelpLabel.Position = UDim2.new(0.05, 0, 0.88, 0)
HelpLabel.BackgroundTransparency = 1
HelpLabel.Text = "Pressione 'INSERT' para Fechar/Abrir"
HelpLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
HelpLabel.Font = Enum.Font.SourceSansItalic
HelpLabel.TextSize = 12
HelpLabel.Parent = MainFrame

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 4. Loop Principal de Ações e Automação
RunService.RenderStepped:Connect(function(dt)
    if not Config.Active then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local ball = GetBall()
    if ball then
        local distance = (ball.Position - rootPart.Position).Magnitude
        
        -- Executa apenas se a bola estiver dentro do Reach configurado
        if distance <= Config.Reach then
            
            -- AutoFollow: Segue a bola suavemente
            if Config.AutoFollow and not Config.AutoTeleport then
                local targetPos = Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z)
                rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.Position, targetPos) + (ball.Position - rootPart.Position).Unit * math.min(distance, Config.FollowSpeed * dt), 0.25)
            end

            -- Teleport: Vai direto para cima da bola
            if Config.AutoTeleport then
                rootPart.CFrame = ball.CFrame * CFrame.new(0, 3, 0)
            end
            
            -- AutoBall: Ímã que puxa e cola a bola no pé
            if Config.AutoBall then
                pcall(function()
                    ball.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2.5)
                    ball.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
                end)
            end
        end
    end
end)

print("🚀 [ZUNO ENGINE] Script limpo do zero carregado com sucesso!")
