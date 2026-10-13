-- ZUNO ENGINE - TCS com Indicador Visual de Reach
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local ZunoScript = {
    Active = true,
    Reach = 45,             -- Reach inicial otimizado
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 25
}

-- Função para encontrar a bola no TCS
local function FindBall()
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

-- Destrói menus antigos
if CoreGui:FindFirstChild("ZunoCoreGui") then
    CoreGui.ZunoCoreGui:Destroy()
end

-- Interface no CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZunoCoreGui"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 330)
MainFrame.Position = UDim2.new(0.08, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.Text = "⚡ ZUNO ENGINE - TCS REACH"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Botão AutoFollow
local BtnFollow = Instance.new("TextButton")
BtnFollow.Size = UDim2.new(0.9, 0, 0, 30)
BtnFollow.Position = UDim2.new(0.05, 0, 0.15, 0)
BtnFollow.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnFollow.Text = "AutoFollow: DESLIGADO"
BtnFollow.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFollow.Font = Enum.Font.SourceSansBold
BtnFollow.TextSize = 13
BtnFollow.Parent = MainFrame

BtnFollow.MouseButton1Click:Connect(function()
    ZunoScript.AutoFollow = not ZunoScript.AutoFollow
    BtnFollow.BackgroundColor3 = ZunoScript.AutoFollow and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
    BtnFollow.Text = "AutoFollow: " .. (ZunoScript.AutoFollow and "LIGADO" or "DESLIGADO")
end)

-- Botão AutoBall
local BtnBall = Instance.new("TextButton")
BtnBall.Size = UDim2.new(0.9, 0, 0, 30)
BtnBall.Position = UDim2.new(0.05, 0, 0.27, 0)
BtnBall.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnBall.Text = "AutoBall (Ímã): DESLIGADO"
BtnBall.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnBall.Font = Enum.Font.SourceSansBold
BtnBall.TextSize = 13
BtnBall.Parent = MainFrame

BtnBall.MouseButton1Click:Connect(function()
    ZunoScript.AutoBall = not ZunoScript.AutoBall
    BtnBall.BackgroundColor3 = ZunoScript.AutoBall and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
    BtnBall.Text = "AutoBall (Ímã): " .. (ZunoScript.AutoBall and "LIGADO" or "DESLIGADO")
end)

-- Botão Teleport
local BtnTeleport = Instance.new("TextButton")
BtnTeleport.Size = UDim2.new(0.9, 0, 0, 30)
BtnTeleport.Position = UDim2.new(0.05, 0, 0.39, 0)
BtnTeleport.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnTeleport.Text = "Teleport Ball: DESLIGADO"
BtnTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnTeleport.Font = Enum.Font.SourceSansBold
BtnTeleport.TextSize = 13
BtnTeleport.Parent = MainFrame

BtnTeleport.MouseButton1Click:Connect(function()
    ZunoScript.AutoTeleport = not ZunoScript.AutoTeleport
    BtnTeleport.BackgroundColor3 = ZunoScript.AutoTeleport and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
    BtnTeleport.Text = "Teleport Ball: " .. (ZunoScript.AutoTeleport and "LIGADO" or "DESLIGADO")
end)

-- Reach Label com Indicador de Distância Ativa
local ReachLabel = Instance.new("TextLabel")
ReachLabel.Size = UDim2.new(0.9, 0, 0, 20)
ReachLabel.Position = UDim2.new(0.05, 0, 0.52, 0)
ReachLabel.BackgroundTransparency = 1
ReachLabel.Text = "Reach Atual: " .. ZunoScript.Reach .. " Studs"
ReachLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ReachLabel.Font = Enum.Font.SourceSansBold
ReachLabel.TextSize = 13
ReachLabel.Parent = MainFrame

-- Caixa de Texto do Reach
local ReachBox = Instance.new("TextBox")
ReachBox.Size = UDim2.new(0.9, 0, 0, 28)
ReachBox.Position = UDim2.new(0.05, 0, 0.60, 0)
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
        ReachLabel.Text = "Reach Atual: " .. ZunoScript.Reach .. " Studs"
        print("⚡ [ZUNO] Reach atualizado para:", val)
    else
        ReachBox.Text = tostring(ZunoScript.Reach)
    end
end)

-- Label de Status em Tempo Real (Mostra a distância exata até à bola)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.05, 0, 0.72, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
StatusLabel.Text = "Distância à Bola: A procurar..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

local HelpLabel = Instance.new("TextLabel")
HelpLabel.Size = UDim2.new(0.9, 0, 0, 20)
HelpLabel.Position = UDim2.new(0.05, 0, 0.89, 0)
HelpLabel.BackgroundTransparency = 1
HelpLabel.Text = "Pressiona 'INSERT' para Fechar"
HelpLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
HelpLabel.Font = Enum.Font.SourceSansItalic
HelpLabel.TextSize = 11
HelpLabel.Parent = MainFrame

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Loop principal com atualização da distância em tempo real
RunService.RenderStepped:Connect(function(dt)
    if not ZunoScript.Active then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local ball = FindBall()
    if ball then
        local distance = (ball.Position - rootPart.Position).Magnitude
        StatusLabel.Text = string.Format("Distância à Bola: %.1f Studs", distance)
        
        if distance <= ZunoScript.Reach then
            -- AutoFollow suave
            if ZunoScript.AutoFollow and not ZunoScript.AutoTeleport then
                local targetPos = Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z)
                rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.Position, targetPos) + (ball.Position - rootPart.Position).Unit * math.min(distance, ZunoScript.FollowSpeed * dt), 0.25)
            end

            -- Teleport Direto
            if ZunoScript.AutoTeleport then
                rootPart.CFrame = ball.CFrame * CFrame.new(0, 3, 0)
            end
            
            -- AutoBall (Ímã baseado no Reach ativo)
            if ZunoScript.AutoBall then
                pcall(function()
                    ball.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2.5)
                    ball.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
                end)
            end
        end
    else
        StatusLabel.Text = "Bola não encontrada!"
    end
end)

print("🚀 [ZUNO ENGINE] Atualizado com Indicador de Distância!")
