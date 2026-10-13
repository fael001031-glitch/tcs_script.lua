-- ==========================================================
-- ZUNO ENGINE - TCS (Painel Nativo + Atalhos de Emergência)
-- ==========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Active = true,
    Reach = 45,
    AutoFollow = false,
    AutoBall = false,
    AutoTeleport = false,
    FollowSpeed = 24
}

-- 1. Limpeza de menus antigos
pcall(function()
    if CoreGui:FindFirstChild("ZunoEmergencyGui") then CoreGui.ZunoEmergencyGui:Destroy() end
    if LocalPlayer.PlayerGui:FindFirstChild("ZunoEmergencyGui") then LocalPlayer.PlayerGui.ZunoEmergencyGui:Destroy() end
end)

-- 2. Busca da bola no TCS
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

-- 3. Criação da UI Nativa Simples
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZunoEmergencyGui"
ScreenGui.ResetOnSpawn = false

-- Tentativa de injeção em múltiplos locais para garantir que aparece no Xeno
local injected = false
if gethui then
    pcall(function() ScreenGui.Parent = gethui() injected = true end)
end
if not injected then
    pcall(function() ScreenGui.Parent = CoreGui injected = true end)
end
if not injected then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 230, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "⚡ ZUNO ENGINE - TCS"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local function CreateBtn(text, posY, key, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, posY, 0)
    btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    btn.Text = text .. " [" .. key .. "]: OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = MainFrame

    local state = false
    local function Toggle()
        state = not state
        callback(state)
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
        btn.Text = text .. " [" .. key .. "]: " .. (state and "ON" or "OFF")
    end

    btn.MouseButton1Click:Connect(Toggle)
    return Toggle
end

local ToggleFollow = CreateBtn("AutoFollow", 0.16, "F", function(st) Config.AutoFollow = st end)
local ToggleBall = CreateBtn("AutoBall (Ímã)", 0.29, "E", function(st) Config.AutoBall = st end)
local ToggleTP = CreateBtn("Teleport Ball", 0.42, "R", function(st) Config.AutoTeleport = st end)

local ReachBox = Instance.new("TextBox")
ReachBox.Size = UDim2.new(0.9, 0, 0, 28)
ReachBox.Position = UDim2.new(0.05, 0, 0.58, 0)
ReachBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ReachBox.Text = "Reach: " .. tostring(Config.Reach) .. " [T]"
ReachBox.TextColor3 = Color3.fromRGB(0, 230, 255)
ReachBox.Font = Enum.Font.SourceSansBold
ReachBox.TextSize = 13
ReachBox.Parent = MainFrame

ReachBox.FocusLost:Connect(function()
    local val = tonumber(ReachBox.Text:match("%d+"))
    if val then
        Config.Reach = val
        ReachBox.Text = "Reach: " .. tostring(Config.Reach) .. " [T]"
    end
end)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(0.9, 0, 0, 50)
Info.Position = UDim2.new(0.05, 0, 0.75, 0)
Info.BackgroundTransparency = 1
Info.Text = "Teclas de Atalho:\n[F] Follow | [E] Ímã | [R] TP\n[T] Mudar Reach | [INSERT] Menu"
Info.TextColor3 = Color3.fromRGB(180, 180, 180)
Info.Font = Enum.Font.SourceSans
Info.TextSize = 11
Info.Parent = MainFrame

-- 4. Atalhos pelo Teclado (Garantia de Funcionamento no Xeno)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        ToggleFollow()
    elseif input.KeyCode == Enum.KeyCode.E then
        ToggleBall()
    elseif input.KeyCode == Enum.KeyCode.R then
        ToggleTP()
    elseif input.KeyCode == Enum.KeyCode.T then
        if Config.Reach >= 100 then Config.Reach = 25 else Config.Reach = Config.Reach + 25 end
        ReachBox.Text = "Reach: " .. tostring(Config.Reach) .. " [T]"
    elseif input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 5. Loop do Script
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

print("🚀 [ZUNO ENGINE] Injetado com Atalhos de Emergência!")
