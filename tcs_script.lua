-- ZUNO ENGINE - TCS FIX PAINEL DEFINITIVO (Xeno / PC)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ZunoScript = {
    Active = true,
    Reach = 45,
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 25
}

-- Procura a pasta do PlayerGui com segurança absoluta
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)

-- Destrói instâncias antigas para não travar a injeção
if PlayerGui and PlayerGui:FindFirstChild("ZunoTcsGui") then
    PlayerGui.ZunoTcsGui:Destroy()
end

-- Busca avançada da bola no TCS
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

-- Criando ScreenGui no PlayerGui com proteção de nome
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZunoTcsGui"
ScreenGui.ResetOnSpawn = false

-- Suporte a Synapse/Xeno ProtectGui se existir
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = PlayerGui
end

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 340)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Título do Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "⚡ ZUNO ENGINE - TCS FIX"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Função auxiliar para criar botões
local function CreateButton(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Text = text .. ": DESLIGADO"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = MainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local state = callback()
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
        btn.Text = text .. ": " .. (state and "LIGADO" or "DESLIGADO")
    end)
    return btn
end

-- Botões do Painel
CreateButton("AutoFollow", UDim2.new(0.05, 0, 0.15, 0), function()
    ZunoScript.AutoFollow = not ZunoScript.AutoFollow
    return ZunoScript.AutoFollow
end)

CreateButton("AutoBall (Ímã)", UDim2.new(0.05, 0, 0.27, 0), function()
    ZunoScript.AutoBall = not ZunoScript.AutoBall
    return ZunoScript.AutoBall
end)

CreateButton("Teleport Ball", UDim2.new(0.05, 0, 0.39, 0), function()
    ZunoScript.AutoTeleport = not ZunoScript.AutoTeleport
    return ZunoScript.AutoTeleport
end)

-- Reach Label
local ReachLabel = Instance.new("TextLabel")
ReachLabel.Size = UDim2.new(0.9, 0, 0, 20)
ReachLabel.Position = UDim2.new(0.05, 0, 0.52, 0)
ReachLabel.BackgroundTransparency = 1
ReachLabel.Text = "Reach Atual: " .. ZunoScript.Reach .. " Studs"
ReachLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ReachLabel.Font = Enum.Font.SourceSansBold
ReachLabel.TextSize = 13
ReachLabel.Parent = MainFrame

-- ReachBox (Entrada de Texto do Reach)
local ReachBox = Instance.new("TextBox")
ReachBox.Size = UDim2.new(0.9, 0, 0, 28)
ReachBox.Position = UDim2.new(0.05, 0, 0.60, 0)
ReachBox.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
ReachBox.Text = tostring(ZunoScript.Reach)
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
        ZunoScript.Reach = val
        ReachLabel.Text = "Reach Atual: " .. ZunoScript.Reach .. " Studs"
    else
        ReachBox.Text = tostring(ZunoScript.Reach)
    end
end)

-- Status da Bola
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 28)
StatusLabel.Position = UDim2.new(0.05, 0, 0.72, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
StatusLabel.Text = "A procurar bola..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

-- Tecla INSERT para Esconder/Mostrar Menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Loop principal
RunService.RenderStepped:Connect(function(dt)
