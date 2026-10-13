-- ZUNO ENGINE - TCS (The Classic Soccer) Compatível com Xeno
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local ZunoScript = {
    Active = true,
    Reach = 45,                 -- Ajustado para 45
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 22            -- AutoFollow ajustado
}

-- Função adaptada para localizar a bola especificamente no The Classic Soccer (TCS)
local function FindBall()
    -- Procura direta no Workspace (muito comum no TCS)
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("bola") or obj.Name:lower() == "matchball") then
            return obj
        end
    end
    
    -- Procura em pastas comuns de partidas no TCS
    local foldersToSearch = {"Ball", "Balls", "Match", "Matches", "Workspace.Ball", "GameObjects"}
    for _, folderName in ipairs(foldersToSearch) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, obj in ipairs(folder:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("bola") or obj.Name:lower() == "matchball") then
                    return obj
                end
            end
        end
    end
    
    -- Fallback geral caso a bola esteja escondida
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower() == "ball" or obj.Name:lower() == "matchball") then
            return obj
        end
    end
    
    return nil
end

-- Destrói menus antigos para não sobrepor
if CoreGui:FindFirstChild("ZunoCoreGui") then
    CoreGui.ZunoCoreGui:Destroy()
end

-- Criando a Interface no CoreGui (Injetado com sucesso no Xeno)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZunoCoreGui"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 310)
MainFrame.Position = UDim2.new(0.08, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Barra de Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.Text = "⚡ ZUNO ENGINE - TCS v2.0"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Botão: AutoFollow
local BtnFollow = Instance.new("TextButton")
BtnFollow.Size = UDim2.new(0.9, 0, 0, 32)
BtnFollow.Position = UDim2.new(0.05, 0, 0.16, 0)
BtnFollow.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnFollow.Text = "AutoFollow: DESLIGADO"
BtnFollow.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFollow.Font = Enum.Font.SourceSansBold
BtnFollow.TextSize = 13
BtnFollow.Parent = MainFrame

BtnFollow.MouseButton1Click:Connect(function()
    ZunoScript.AutoFollow = not ZunoScript.AutoFollow
    if ZunoScript.AutoFollow then
        BtnFollow.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        BtnFollow.Text = "AutoFollow: LIGADO"
    else
        BtnFollow.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnFollow.Text = "AutoFollow: DESLIGADO"
    end
end)

-- Botão: AutoBall
local BtnBall = Instance.new("TextButton")
BtnBall.Size = UDim2.new(0.9, 0, 0, 32)
BtnBall.Position = UDim2.new(0.05, 0, 0.29, 0)
BtnBall.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnBall.Text = "AutoBall: DESLIGADO"
BtnBall.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnBall.Font = Enum.Font.SourceSansBold
BtnBall.TextSize = 13
BtnBall.Parent = MainFrame

BtnBall.MouseButton1Click:Connect(function()
    ZunoScript.AutoBall = not ZunoScript.AutoBall
    if ZunoScript.AutoBall then
        BtnBall.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        BtnBall.Text = "AutoBall: LIGADO"
    else
        BtnBall.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnBall.Text = "AutoBall: DESLIGADO"
    end
end)

-- Botão: Teleport
local BtnTeleport = Instance.new("TextButton")
BtnTeleport.Size = UDim2.new(0.9, 0, 0, 32)
BtnTeleport.Position = UDim2.new(0.05, 0, 0.42, 0)
BtnTeleport.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnTeleport.Text = "Teleport Ball: DESLIGADO"
BtnTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnTeleport.Font = Enum.Font.SourceSansBold
BtnTeleport.TextSize = 13
BtnTeleport.Parent = MainFrame

BtnTeleport.MouseButton1Click:Connect(function()
    ZunoScript.AutoTeleport = not ZunoScript.AutoTeleport
    if ZunoScript.AutoTeleport then
        BtnTeleport.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        BtnTeleport.Text = "Teleport Ball: LIGADO"
    else
        BtnTeleport.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnTeleport.Text = "Teleport Ball: DESLIGADO"
    end
end)

-- Ajuste de Reach (Input de Texto)
local ReachLabel = Instance.new("TextLabel")
ReachLabel.Size = UDim2.new(0.9, 0, 0, 20)
ReachLabel.Position = UDim2.new(0.05, 0, 0.56, 0)
ReachLabel.BackgroundTransparency = 1
ReachLabel.Text = "Alcance do Reach (Studs):"
ReachLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ReachLabel.Font = Enum.Font.SourceSans
ReachLabel.TextSize = 13
ReachLabel.Parent = MainFrame

local ReachBox = Instance.new("TextBox")
ReachBox.Size = UDim2.new(0.9, 0, 0, 28)
ReachBox.Position = UDim2.new(0.05, 0, 0.64, 0)
ReachBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ReachBox.Text = tostring(ZunoScript.Reach)
ReachBox.TextColor3 = Color3.fromRGB(0, 230, 255)
ReachBox.Font = Enum.Font.SourceSansBold
ReachBox.TextSize = 14
ReachBox.Parent = MainFrame

ReachBox.FocusLost:Connect(function()
    local val = tonumber(ReachBox.Text)
    if val then
        ZunoScript.Reach = val
    else
        ReachBox.Text = tostring(ZunoScript.Reach)
    end
end)

-- Texto de Ajuda/Atalho
local HelpLabel = Instance.new("TextLabel")
HelpLabel.Size = UDim2.new(0.9, 0, 0, 25)
HelpLabel.Position = UDim2.new(0.05, 0, 0.88, 0)
HelpLabel.BackgroundTransparency = 1
HelpLabel.Text = "Pressiona 'INSERT' para Abrir/Fechar"
HelpLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
HelpLabel.Font = Enum.Font.SourceSansItalic
HelpLabel.TextSize = 12
HelpLabel.Parent = MainFrame

-- Abrir e Fechar o Menu com a tecla INSERT
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Loop principal otimizado para TCS
RunService.RenderStepped:Connect(function(dt)
    if not ZunoScript.Active then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local ball = FindBall()
    if ball then
        local distance = (ball.Position - rootPart.Position).Magnitude
        
        if distance <= ZunoScript.Reach then
            -- AutoFollow Suave
            if ZunoScript.AutoFollow and not ZunoScript.AutoTeleport then
                local targetPos = Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z)
                rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.Position, targetPos) + (ball.Position - rootPart.Position).Unit * math.min(distance, ZunoScript.FollowSpeed * dt), 0.25)
            end

            -- Teleport Corrigido para a Bola
            if ZunoScript.AutoTeleport then
                rootPart.CFrame = ball.CFrame + Vector3.new(0, 3, 0)
            end
            
            -- AutoBall (Ímã reduzido e estável)
            if ZunoScript.AutoBall and ball:IsA("BasePart") then
                pcall(function()
                    ball.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2.5)
                    ball.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
                end)
            end
        end
    end
end)

print("🚀 [ZUNO ENGINE] TCS Carregado com Sucesso!")
