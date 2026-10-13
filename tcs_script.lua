-- ZUNO ENGINE - TCS ULTIMATE (Library Externa Compatível com Xeno)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

-- Carrega a Library de Interface Externa (Bypassa bloqueios de GUI do Xeno)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡ ZUNO ENGINE - TCS PRO",
   LoadingTitle = "A carregar Zuno Engine...",
   LoadingSubtitle = "por Rafael",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Principal", 4483362458)

-- Toggles de Funções
MainTab:CreateToggle({
   Name = "AutoFollow (Seguir Bola)",
   CurrentValue = false,
   Flag = "AutoFollowFlag",
   Callback = function(Value)
      ZunoScript.AutoFollow = Value
   end,
})

MainTab:CreateToggle({
   Name = "AutoBall (Ímã)",
   CurrentValue = false,
   Flag = "AutoBallFlag",
   Callback = function(Value)
      ZunoScript.AutoBall = Value
   end,
})

MainTab:CreateToggle({
   Name = "Teleport para a Bola",
   CurrentValue = false,
   Flag = "TeleportFlag",
   Callback = function(Value)
      ZunoScript.AutoTeleport = Value
   end,
})

-- Ajuste de Reach (Slider / Input)
MainTab:CreateSlider({
   Name = "Alcance do Reach (Studs)",
   Range = {10, 150},
   Increment = 5,
   Suffix = "Studs",
   CurrentValue = 45,
   Flag = "ReachSlider",
   Callback = function(Value)
      ZunoScript.Reach = Value
   end,
})

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

-- Loop principal de físicas
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
            -- AutoFollow suave
            if ZunoScript.AutoFollow and not ZunoScript.AutoTeleport then
                local targetPos = Vector3.new(ball.Position.X, rootPart.Position.Y, ball.Position.Z)
                rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.Position, targetPos) + (ball.Position - rootPart.Position).Unit * math.min(distance, ZunoScript.FollowSpeed * dt), 0.25)
            end

            -- Teleport Direto
            if ZunoScript.AutoTeleport then
                rootPart.CFrame = ball.CFrame * CFrame.new(0, 3, 0)
            end
            
            -- AutoBall (Ímã baseado no Reach)
            if ZunoScript.AutoBall then
                pcall(function()
                    ball.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2.5)
                    ball.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
                end)
            end
        end
    end
end)

print("🚀 [ZUNO ENGINE] Rayfield Library Injetada com Sucesso!")
