-- ==========================================================
-- ZUNO ENGINE - TCS ULTIMATE (Painel Direto no PlayerGui)
-- ==========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Espera o jogador e o PlayerGui carregarem completamente
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configurações das Funções
local Config = {
    Active = true,
    Reach = 45,             -- Reach padrão
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 22        -- Velocidade suave para o AutoFollow
}

-- 1. Destrói qualquer versão antiga do menu no PlayerGui
if PlayerGui:FindFirstChild("ZunoTcsMainGui") then
    PlayerGui.ZunoTcsMainGui:Destroy()
end

-- 2. Função de busca da bola no TCS
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

-- 3. Criação da Interface Gráfica Garantida
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZunoTcsMainGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Position = UDim2.new(0.08, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Título do Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
Title.Text = "⚡ ZUNO ENGINE - TCS"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Criador de Botões
local function CreateButton(text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, posY, 0)
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Text = text .. ": DESLIGADO"
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
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
        btn.Text = text .. ": " .. (state and "LIGADO" or "DESLIGADO")
    end)
    return btn
end

-- Botões do Painel
CreateButton("AutoFollow", 0.15, function(state) Config.AutoFollow = state end)
CreateButton("AutoBall (Ímã)", 0.28, function(state) Config.AutoBall = state end)
CreateButton("Teleport Ball", 0.41, function(state) Config.AutoTeleport = state end)

-- Reach Label
local ReachLabel = Instance.new("TextLabel")
ReachLabel.Size = UDim2.new(0.9, 0, 0, 20)
ReachLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
ReachLabel.BackgroundTransparency = 1
ReachLabel.Text = "Alcance do Reach (Studs):"
ReachLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ReachLabel.Font = Enum.Font.SourceSans
ReachLabel.TextSize = 13
ReachLabel.Parent = MainFrame

-- ReachBox (Caixa de Entrada para alterar o valor do Reach)
local ReachBox = Instance.new("TextBox")
ReachBox.Size = UDim2.new(0.9, 0, 0, 28)
ReachBox.Position = UDim2.new(0.05, 0, 0.63, 0)
ReachBox.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
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
        print("⚡ [ZUNO] Reach ajustado para:", val)
    else
        ReachBox.Text = tostring(Config.Reach)
    end
end)

-- Tecla de Atalho INSERT
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

-- 4. Loop Principal de Execução das Automações
RunService.RenderStepped:Connect(function(dt)
    if not Config.Active then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local ball = GetBall()
    if ball then
        local distance = (ball.Position - rootPart.Position).Magnitude
        
        -- Executa as funções dentro do raio definido na ReachBox
        if distance <= Config.Reach then
            
            -- AutoFollow Suave
            if Config.AutoFollow and not Config.AutoTeleport then
                local targetPos = Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z)
                rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.Position, targetPos) + (ball.Position - rootPart.Position).Unit * math.min(distance, Config.FollowSpeed * dt), 0.25)
            end

            -- Teleport Direto para a Bola
            if Config.AutoTeleport then
                rootPart.CFrame = ball.CFrame * CFrame.new(0, 3, 0)
            end
            
            -- AutoBall (Ímã na Bola)
            if Config.AutoBall then
                pcall(function()
                    ball.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2.5)
                    ball.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
                end)
            end
        end
    end
end)

print("🚀 [ZUNO ENGINE] Injetado com Sucesso no PlayerGui!")
