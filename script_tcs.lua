-- ZUNO ENGINE - Módulo com Menu Visual (MPS)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ZunoScriptTest = {}
ZunoScriptTest.Active = true
ZunoScriptTest.Settings = {
    Reach = 15,
    AutoTeleportToBall = false,
    AutoBall = true,
    AutoFollow = true,
    FollowSpeed = 30
}

-- Função para encontrar a bola no mapa
function ZunoScriptTest:FindBall()
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

-- Criar Menu Visual (GUI)
function ZunoScriptTest:CreateMenu()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Remove menu antigo se existir
    if PlayerGui:FindFirstChild("ZunoEngineGui") then
        PlayerGui.ZunoEngineGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZunoEngineGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 220, 0, 270)
    MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true -- Permite arrastar o menu com o rato
    MainFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.Text = "⚡ ZUNO ENGINE v1.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = MainFrame

    -- Botão AutoFollow
    local BtnFollow = Instance.new("TextButton")
    BtnFollow.Size = UDim2.new(0.9, 0, 0, 30)
    BtnFollow.Position = UDim2.new(0.05, 0, 0.18, 0)
    BtnFollow.BackgroundColor3 = self.Settings.AutoFollow and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    BtnFollow.Text = "AutoFollow: " .. (self.Settings.AutoFollow and "LIGADO" or "DESLIGADO")
    BtnFollow.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnFollow.Font = Enum.Font.SourceSans
    BtnFollow.TextSize = 13
    BtnFollow.Parent = MainFrame

    BtnFollow.MouseButton1Click:Connect(function()
        self.Settings.AutoFollow = not self.Settings.AutoFollow
        BtnFollow.BackgroundColor3 = self.Settings.AutoFollow and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        BtnFollow.Text = "AutoFollow: " .. (self.Settings.AutoFollow and "LIGADO" or "DESLIGADO")
    end)

    -- Botão AutoBall
    local BtnBall = Instance.new("TextButton")
    BtnBall.Size = UDim2.new(0.9, 0, 0, 30)
    BtnBall.Position = UDim2.new(0.05, 0, 0.32, 0)
    BtnBall.BackgroundColor3 = self.Settings.AutoBall and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    BtnBall.Text = "AutoBall: " .. (self.Settings.AutoBall and "LIGADO" or "DESLIGADO")
    BtnBall.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnBall.Font = Enum.Font.SourceSans
    BtnBall.TextSize = 13
    BtnBall.Parent = MainFrame

    BtnBall.MouseButton1Click:Connect(function()
        self.Settings.AutoBall = not self.Settings.AutoBall
        BtnBall.BackgroundColor3 = self.Settings.AutoBall and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        BtnBall.Text = "AutoBall: " .. (self.Settings.AutoBall and "LIGADO" or "DESLIGADO")
    end)

    -- Botão AutoTeleport
    local BtnTeleport = Instance.new("TextButton")
    BtnTeleport.Size = UDim2.new(0.9, 0, 0, 30)
    BtnTeleport.Position = UDim2.new(0.05, 0, 0.46, 0)
    BtnTeleport.BackgroundColor3 = self.Settings.AutoTeleportToBall and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    BtnTeleport.Text = "Teleport Ball: " .. (self.Settings.AutoTeleportToBall and "LIGADO" or "DESLIGADO")
    BtnTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnTeleport.Font = Enum.Font.SourceSans
    BtnTeleport.TextSize = 13
    BtnTeleport.Parent = MainFrame

    BtnTeleport.MouseButton1Click:Connect(function()
        self.Settings.AutoTeleportToBall = not self.Settings.AutoTeleportToBall
        BtnTeleport.BackgroundColor3 = self.Settings.AutoTeleportToBall and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        BtnTeleport.Text = "Teleport Ball: " .. (self.Settings.AutoTeleportToBall and "LIGADO" or "DESLIGADO")
    end)

    -- Input para alterar Reach
    local ReachLabel = Instance.new("TextLabel")
    ReachLabel.Size = UDim2.new(0.9, 0, 0, 20)
    ReachLabel.Position = UDim2.new(0.05, 0, 0.62, 0)
    ReachLabel.BackgroundTransparency = 1
    ReachLabel.Text = "Ajustar Reach (Studs):"
    ReachLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ReachLabel.Font = Enum.Font.SourceSans
    ReachLabel.TextSize = 12
    ReachLabel.Parent = MainFrame

    local ReachBox = Instance.new("TextBox")
    ReachBox.Size = UDim2.new(0.9, 0, 0, 25)
    ReachBox.Position = UDim2.new(0.05, 0, 0.72, 0)
    ReachBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ReachBox.Text = tostring(self.Settings.Reach)
    ReachBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReachBox.Font = Enum.Font.SourceSans
    ReachBox.TextSize = 13
    ReachBox.Parent = MainFrame

    ReachBox.FocusLost:Connect(function()
        local val = tonumber(ReachBox.Text)
        if val then
            self.Settings.Reach = val
        else
            ReachBox.Text = tostring(self.Settings.Reach)
        end
    end)

    -- Atalho no teclado para abrir/fechar o Menu (Tecla INSERT)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
end

function ZunoScriptTest:Initialize()
    print("🚀 [ZUNO ENGINE] - Menu Visual Carregado!")
    self:CreateMenu()
    
    RunService.RenderStepped:Connect(function(dt)
        if not ZunoScriptTest.Active then return end
        
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPart = character.HumanoidRootPart
        local ball = self:FindBall()
        
        if ball then
            local distance = (ball.Position - rootPart.Position).Magnitude
            
            if distance <= self.Settings.Reach then
                if self.Settings.AutoFollow and not self.Settings.AutoTeleportToBall then
                    local targetCFrame = CFrame.new(rootPart.Position, Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z))
                    rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame + (ball.Position - rootPart.Position).Unit * math.min(distance
