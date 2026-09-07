-- Criando a Interface
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

-- Variáveis principais
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variáveis do sistema
local selectedTarget = nil
local isBringing = false
local isKilling = false
local isProcessingJail = false
local isFlinging = false
local originalPosition = nil
local targetChar = nil
local followConnection = nil
local jailLoopConnections = {}
local jailTargetsList = {}
local espActive = false
local espObjects = {}
local espLoopConnection = nil
local isViewing = false
local cameraConnection = nil
local isAntiSitActive = false
local antiSitConnection = nil
local spinConnection = nil
local isSpinning = false
local searchText = ""
local flingConnection = nil
local isFlingActive = false
local recapturingInProgress = false
local isClickLoopActive = false
local clickLoopConnection = nil

-- Coordenadas
local COORDENADA_KILL = Vector3.new(-37.25, -284.28, -131.55)
local COORDENADA_JAIL = Vector3.new(-1124.13, 66.38, -1254.82)
local COORDENADA_JAIL_CENTER = Vector3.new(-1124.13, 66.38, -1254.82)
local JAIL_RADIUS = 60
local COORDENADA_FLING = Vector3.new(3588.67, 3491.28, -19659.02)

-- Criando a ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminGUI"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- Frame principal (draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 720)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -360)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
title.BorderSizePixel = 0
title.Text = "🔥 ADMIN PANEL 🔥"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Label do alvo selecionado
local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(0.9, 0, 0, 25)
targetLabel.Position = UDim2.new(0.05, 0, 0, 40)
targetLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "🎯 Alvo: Nenhum"
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetLabel.TextSize = 13
targetLabel.Font = Enum.Font.GothamBold
targetLabel.Parent = mainFrame

-- Barra de Pesquisa
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.9, 0, 0, 25)
searchBox.Position = UDim2.new(0.05, 0, 0, 70)
searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
searchBox.BorderSizePixel = 0
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.TextSize = 13
searchBox.Font = Enum.Font.Gotham
searchBox.PlaceholderText = "🔍 Pesquisar jogador..."
searchBox.ClearTextOnFocus = false
searchBox.Parent = mainFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBox

-- Lista de jogadores (com SCROLL)
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(0.9, 0, 0, 80)
playerListFrame.Position = UDim2.new(0.05, 0, 0, 100)
playerListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
playerListFrame.BackgroundTransparency = 0
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 5
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.Parent = mainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = playerListFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 3)
listLayout.Parent = playerListFrame

-- Label da lista de Jail
local jailListTitle = Instance.new("TextLabel")
jailListTitle.Size = UDim2.new(0.9, 0, 0, 20)
jailListTitle.Position = UDim2.new(0.05, 0, 0, 188)
jailListTitle.BackgroundTransparency = 1
jailListTitle.Text = "🔒 Alvos no Jail:"
jailListTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
jailListTitle.TextSize = 12
jailListTitle.Font = Enum.Font.GothamBold
jailListTitle.TextXAlignment = Enum.TextXAlignment.Left
jailListTitle.Visible = false
jailListTitle.Parent = mainFrame

-- Lista de alvos no Jail (com SCROLL)
local jailListFrame = Instance.new("ScrollingFrame")
jailListFrame.Size = UDim2.new(0.9, 0, 0, 60)
jailListFrame.Position = UDim2.new(0.05, 0, 0, 210)
jailListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
jailListFrame.BackgroundTransparency = 0
jailListFrame.BorderSizePixel = 0
jailListFrame.ScrollBarThickness = 5
jailListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
jailListFrame.Visible = false
jailListFrame.Parent = mainFrame

local jailListCorner = Instance.new("UICorner")
jailListCorner.CornerRadius = UDim.new(0, 6)
jailListCorner.Parent = jailListFrame

local jailListLayout = Instance.new("UIListLayout")
jailListLayout.SortOrder = Enum.SortOrder.LayoutOrder
jailListLayout.Padding = UDim.new(0, 3)
jailListLayout.Parent = jailListFrame

-- Frame para os botões de ação (linha 1)
local actionFrame1 = Instance.new("Frame")
actionFrame1.Size = UDim2.new(0.9, 0, 0, 40)
actionFrame1.Position = UDim2.new(0.05, 0, 0, 278)
actionFrame1.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
actionFrame1.BackgroundTransparency = 1
actionFrame1.Parent = mainFrame

-- Botão Bring
local bringButton = Instance.new("TextButton")
bringButton.Size = UDim2.new(0.1, -3, 1, 0)
bringButton.Position = UDim2.new(0, 0, 0, 0)
bringButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
bringButton.Text = "🚗"
bringButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bringButton.TextSize = 12
bringButton.Font = Enum.Font.GothamBold
bringButton.Parent = actionFrame1

local bringCorner = Instance.new("UICorner")
bringCorner.CornerRadius = UDim.new(0, 6)
bringCorner.Parent = bringButton

-- Botão Kill
local killButton = Instance.new("TextButton")
killButton.Size = UDim2.new(0.1, -3, 1, 0)
killButton.Position = UDim2.new(0.12, 2, 0, 0)
killButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
killButton.Text = "💀"
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.TextSize = 12
killButton.Font = Enum.Font.GothamBold
killButton.Parent = actionFrame1

local killCorner = Instance.new("UICorner")
killCorner.CornerRadius = UDim.new(0, 6)
killCorner.Parent = killButton

-- Botão Jail
local jailButton = Instance.new("TextButton")
jailButton.Size = UDim2.new(0.1, -3, 1, 0)
jailButton.Position = UDim2.new(0.24, 4, 0, 0)
jailButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
jailButton.Text = "🔒"
jailButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jailButton.TextSize = 12
jailButton.Font = Enum.Font.GothamBold
jailButton.Parent = actionFrame1

local jailCorner = Instance.new("UICorner")
jailCorner.CornerRadius = UDim.new(0, 6)
jailCorner.Parent = jailButton

-- Botão Add Jail
local addJailButton = Instance.new("TextButton")
addJailButton.Size = UDim2.new(0.1, -3, 1, 0)
addJailButton.Position = UDim2.new(0.36, 6, 0, 0)
addJailButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
addJailButton.Text = "➕"
addJailButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addJailButton.TextSize = 12
addJailButton.Font = Enum.Font.GothamBold
addJailButton.Parent = actionFrame1

local addJailCorner = Instance.new("UICorner")
addJailCorner.CornerRadius = UDim.new(0, 6)
addJailCorner.Parent = addJailButton

-- Botão ESP
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.1, -3, 1, 0)
espButton.Position = UDim2.new(0.48, 8, 0, 0)
espButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
espButton.Text = "👁️"
espButton.TextColor3 = Color3.fromRGB(0, 0, 0)
espButton.TextSize = 12
espButton.Font = Enum.Font.GothamBold
espButton.Parent = actionFrame1

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
espCorner.Parent = espButton

-- Botão TP
local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(0.1, -3, 1, 0)
tpButton.Position = UDim2.new(0.6, 10, 0, 0)
tpButton.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
tpButton.Text = "📍"
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.TextSize = 12
tpButton.Font = Enum.Font.GothamBold
tpButton.Parent = actionFrame1

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 6)
tpCorner.Parent = tpButton

-- Botão Anti-Sit
local antiSitButton = Instance.new("TextButton")
antiSitButton.Size = UDim2.new(0.1, -3, 1, 0)
antiSitButton.Position = UDim2.new(0.72, 12, 0, 0)
antiSitButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
antiSitButton.Text = "🪑"
antiSitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
antiSitButton.TextSize = 12
antiSitButton.Font = Enum.Font.GothamBold
antiSitButton.Parent = actionFrame1

local antiSitCorner = Instance.new("UICorner")
antiSitCorner.CornerRadius = UDim.new(0, 6)
antiSitCorner.Parent = antiSitButton

-- Botão Fling
local flingButton = Instance.new("TextButton")
flingButton.Size = UDim2.new(0.1, -3, 1, 0)
flingButton.Position = UDim2.new(0.84, 14, 0, 0)
flingButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
flingButton.Text = "🚀"
flingButton.TextColor3 = Color3.fromRGB(0, 0, 0)
flingButton.TextSize = 12
flingButton.Font = Enum.Font.GothamBold
flingButton.Parent = actionFrame1

local flingCorner = Instance.new("UICorner")
flingCorner.CornerRadius = UDim.new(0, 6)
flingCorner.Parent = flingButton

-- Frame para os botões de ação (linha 2)
local actionFrame2 = Instance.new("Frame")
actionFrame2.Size = UDim2.new(0.9, 0, 0, 40)
actionFrame2.Position = UDim2.new(0.05, 0, 0, 323)
actionFrame2.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
actionFrame2.BackgroundTransparency = 1
actionFrame2.Parent = mainFrame

-- Botão View
local viewButton = Instance.new("TextButton")
viewButton.Size = UDim2.new(0.25, -5, 1, 0)
viewButton.Position = UDim2.new(0, 0, 0, 0)
viewButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
viewButton.Text = "📷 View"
viewButton.TextColor3 = Color3.fromRGB(255, 255, 255)
viewButton.TextSize = 11
viewButton.Font = Enum.Font.GothamBold
viewButton.Parent = actionFrame2

local viewCorner = Instance.new("UICorner")
viewCorner.CornerRadius = UDim.new(0, 6)
viewCorner.Parent = viewButton

-- Botão Stop View
local stopViewButton = Instance.new("TextButton")
stopViewButton.Size = UDim2.new(0.25, -5, 1, 0)
stopViewButton.Position = UDim2.new(0.27, 2, 0, 0)
stopViewButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
stopViewButton.Text = "🛑 Stop View"
stopViewButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopViewButton.TextSize = 11
stopViewButton.Font = Enum.Font.GothamBold
stopViewButton.Visible = false
stopViewButton.Parent = actionFrame2

local stopViewCorner = Instance.new("UICorner")
stopViewCorner.CornerRadius = UDim.new(0, 6)
stopViewCorner.Parent = stopViewButton

-- Botão Stop All Jail
local stopAllJailButton = Instance.new("TextButton")
stopAllJailButton.Size = UDim2.new(0.25, -5, 1, 0)
stopAllJailButton.Position = UDim2.new(0.55, 4, 0, 0)
stopAllJailButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
stopAllJailButton.Text = "🛑 Parar Jail"
stopAllJailButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopAllJailButton.TextSize = 10
stopAllJailButton.Font = Enum.Font.GothamBold
stopAllJailButton.Visible = false
stopAllJailButton.Parent = actionFrame2

local stopAllJailCorner = Instance.new("UICorner")
stopAllJailCorner.CornerRadius = UDim.new(0, 6)
stopAllJailCorner.Parent = stopAllJailButton

-- Botão Click Automático
local clickButtonBtn = Instance.new("TextButton")
clickButtonBtn.Size = UDim2.new(0.25, -5, 1, 0)
clickButtonBtn.Position = UDim2.new(0.7, 4, 0, 0)
clickButtonBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
clickButtonBtn.Text = "🏠 Click Auto"
clickButtonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clickButtonBtn.TextSize = 10
clickButtonBtn.Font = Enum.Font.GothamBold
clickButtonBtn.Parent = actionFrame2

local clickCorner = Instance.new("UICorner")
clickCorner.CornerRadius = UDim.new(0, 6)
clickCorner.Parent = clickButtonBtn

-- Label de status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 80)
statusLabel.Position = UDim2.new(0.05, 0, 0, 370)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "✅ Pronto para usar"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- ============================================
-- FUNÇÃO PARA TRAVAR/DESTRAVAR PERSONAGEM
-- ============================================

function freezeCharacter(char)
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

function unfreezeCharacter(char)
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- ============================================
-- LOOP DE CLICAR NA COUCH (SPAM DE CLIQUE)
-- ============================================

function startClickLoop()
    if isClickLoopActive then return end
    isClickLoopActive = true
    print("🔄 Loop de clique na Couch iniciado!")
    
    clickLoopConnection = RunService.Heartbeat:Connect(function()
        if not isClickLoopActive then
            clickLoopConnection:Disconnect()
            return
        end
        
        local char = player.Character
        if not char then return end
        
        local couch = char:FindFirstChild("Couch")
        if not couch then
            couch = player.Backpack:FindFirstChild("Couch")
        end
        
        if couch then
            couch:Fire("Activated")
        end
    end)
end

function stopClickLoop()
    isClickLoopActive = false
    if clickLoopConnection then
        clickLoopConnection:Disconnect()
        clickLoopConnection = nil
    end
    print("🛑 Loop de clique na Couch parado!")
end

-- ============================================
-- NOTIFICAÇÃO
-- ============================================

function showNotification(title, text, duration)
    duration = duration or 3
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration,
    })
end

-- ============================================
-- FUNÇÃO DE CLICAR AUTOMATICAMENTE EM BOTÕES
-- ============================================

function clickButtons()
    local function clickButton(buttonName)
        local gui = player.PlayerGui
        if not gui then return false end
        
        local function searchInGui(guiObject)
            for _, child in pairs(guiObject:GetChildren()) do
                if child:IsA("TextButton") or child:IsA("ImageButton") then
                    if child.Text and string.find(child.Text, buttonName) then
                        child:Fire("MouseButton1Click")
                        print("✅ Cliquei em: " .. child.Text)
                        return true
                    end
                end
                if child:IsA("Frame") or child:IsA("ScreenGui") or child:IsA("ScrollingFrame") then
                    local found = searchInGui(child)
                    if found then return true end
                end
            end
            return false
        end
        
        for _, gui in pairs(gui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local found = searchInGui(gui)
                if found then return true end
            end
        end
        
        return false
    end
    
    statusLabel.Text = "🔄 Executando sequência de botões..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    showNotification("🔄 Cliques Automáticos!", "Iniciando sequência...", 2)
    
    task.wait(0.5)
    if clickButton("LeavHome") then
        task.wait(0.5)
    else
        if not clickButton("LeaveHome") and not clickButton("Leav") and not clickButton("Home") then
            statusLabel.Text = "❌ Botão 'LeavHome' não encontrado!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            showNotification("❌ Erro!", "Botão 'LeavHome' não encontrado!", 3)
            return
        end
    end
    
    task.wait(1)
    if clickButton("001_Landmark") then
        task.wait(0.5)
    else
        if not clickButton("Landmark") and not clickButton("001") then
            statusLabel.Text = "❌ Botão '001_Landmark' não encontrado!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            showNotification("❌ Erro!", "Botão '001_Landmark' não encontrado!", 3)
            return
        end
    end
    
    task.wait(0.5)
    if clickButton("Yes") then
        task.wait(0.5)
    else
        if not clickButton("Sim") and not clickButton("Confirm") and not clickButton("OK") then
            statusLabel.Text = "❌ Botão 'Yes' não encontrado!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            showNotification("❌ Erro!", "Botão 'Yes' não encontrado!", 3)
            return
        end
    end
    
    statusLabel.Text = "✅ Sequência de cliques finalizada!"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    showNotification("✅ Sequência Finalizada!", "Todos os botões foram clicados!", 2)
end

-- ============================================
-- FUNÇÃO DE GIRAR (DISCO AMBULANTE)
-- ============================================

function startSpinning()
    if isSpinning then return end
    isSpinning = true
    
    local time = 0
    
    spinConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not isSpinning then
            spinConnection:Disconnect()
            return
        end
        
        local char = player.Character
        if not char then return end
        
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        time = time + deltaTime * 50
        
        local rotX = math.sin(time * 1.5) * 6.28
        local rotY = math.cos(time * 0.9) * 6.28
        local rotZ = math.sin(time * 1.7) * 6.28
        
        local currentPos = rootPart.Position
        rootPart.CFrame = CFrame.new(currentPos) * CFrame.Angles(rotX, rotY, rotZ)
    end)
end

function stopSpinning()
    isSpinning = false
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
    
    local char = player.Character
    if char then
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local currentPos = rootPart.Position
            rootPart.CFrame = CFrame.new(currentPos)
        end
    end
end

-- ============================================
-- ANTI-SIT
-- ============================================

function toggleAntiSit()
    isAntiSitActive = not isAntiSitActive
    
    if isAntiSitActive then
        antiSitButton.Text = "🪑 ON"
        antiSitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        antiSitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusLabel.Text = "🪑 Anti-Sit ativado!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        showNotification("🪑 Anti-Sit Ativado!", "Você não vai sentar em nada!", 2)
        
        antiSitConnection = RunService.Heartbeat:Connect(function()
            if not isAntiSitActive then
                antiSitConnection:Disconnect()
                return
            end
            
            local char = player.Character
            if not char then return end
            
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Sit == true then
                humanoid.Sit = false
            end
        end)
        
    else
        antiSitButton.Text = "🪑"
        antiSitButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        antiSitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        statusLabel.Text = "🪑 Anti-Sit desativado!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        showNotification("🪑 Anti-Sit Desativado!", "Você pode sentar novamente!", 2)
        
        if antiSitConnection then
            antiSitConnection:Disconnect()
            antiSitConnection = nil
        end
    end
end

-- ============================================
-- FUNÇÃO EQUIPAR COUCH
-- ============================================

function equipCouch()
    local char = player.Character
    if not char then return false end
    
    local equippedCouch = char:FindFirstChild("Couch")
    if equippedCouch then
        return true
    end
    
    local couchTool = player.Backpack:FindFirstChild("Couch")
    if couchTool then
        couchTool.Parent = char
        return true
    end
    
    statusLabel.Text = "🔄 Teleportando para pegar Couch..."
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local wasAntiSitActive = isAntiSitActive
    if wasAntiSitActive then
        isAntiSitActive = false
        if antiSitConnection then
            antiSitConnection:Disconnect()
            antiSitConnection = nil
        end
        antiSitButton.Text = "🪑"
        antiSitButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        antiSitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
    
    local targetPos = Vector3.new(-82.62, 19.26, -130.02)
    rootPart.CFrame = CFrame.new(targetPos)
    
    task.wait(1)
    
    couchTool = player.Backpack:FindFirstChild("Couch")
    if couchTool then
        couchTool.Parent = char
        
        if wasAntiSitActive then
            isAntiSitActive = true
            antiSitButton.Text = "🪑 ON"
            antiSitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            antiSitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusLabel.Text = "🪑 Anti-Sit reativado!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            antiSitConnection = RunService.Heartbeat:Connect(function()
                if not isAntiSitActive then
                    antiSitConnection:Disconnect()
                    return
                end
                
                local char = player.Character
                if not char then return end
                
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Sit == true then
                    humanoid.Sit = false
                end
            end)
        end
        
        return true
    else
        statusLabel.Text = "❌ Couch não encontrada!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        
        if wasAntiSitActive then
            isAntiSitActive = true
            antiSitButton.Text = "🪑 ON"
            antiSitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            antiSitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            antiSitConnection = RunService.Heartbeat:Connect(function()
                if not isAntiSitActive then
                    antiSitConnection:Disconnect()
                    return
                end
                
                local char = player.Character
                if not char then return end
                
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Sit == true then
                    humanoid.Sit = false
                end
            end)
        end
        
        return false
    end
end

-- ============================================
-- FUNÇÃO DESEQUIPAR COUCH E LIBERAR
-- ============================================

function unequipCouchAndFree()
    local char = player.Character
    if not char then return end
    
    local equippedCouch = char:FindFirstChild("Couch")
    if equippedCouch then
        equippedCouch.Parent = player.Backpack
    end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    disableNoclip()
end

-- ============================================
-- FUNÇÃO PRINCIPAL: PEGAR ALVO E TELEPORTAR
-- ============================================

function grabAndTeleport(targetPlayer, targetPosition, isBring, isFling)
    if isProcessingJail then return end
    if not targetPlayer or not targetPosition then return end
    
    isProcessingJail = true
    
    local targetName = targetPlayer.Name
    local actionName = isFling and "🚀 Fling" or (isBring and "Bring" or (targetPosition == COORDENADA_KILL and "Kill" or "Jail"))
    statusLabel.Text = "🎯 " .. actionName .. " em " .. targetName .. "..."
    statusLabel.TextColor3 = isFling and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 200, 0)
    
    local playerChar = player.Character
    if not playerChar then
        statusLabel.Text = "❌ Personagem não encontrado!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        isProcessingJail = false
        return
    end
    
    local playerRoot = playerChar:FindFirstChild("HumanoidRootPart")
    if not playerRoot then
        statusLabel.Text = "❌ RootPart não encontrado!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        isProcessingJail = false
        return
    end
    
    originalPosition = playerRoot.Position
    
    if not equipCouch() then
        isProcessingJail = false
        return
    end
    
    startClickLoop()
    startSpinning()
    
    targetChar = targetPlayer.Character
    if not targetChar then
        statusLabel.Text = "❌ Alvo sem personagem!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        isProcessingJail = false
        stopClickLoop()
        stopSpinning()
        unequipCouchAndFree()
        return
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        statusLabel.Text = "❌ Alvo sem RootPart!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        isProcessingJail = false
        stopClickLoop()
        stopSpinning()
        unequipCouchAndFree()
        return
    end
    
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if not targetHumanoid then
        statusLabel.Text = "❌ Alvo sem Humanoid!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        isProcessingJail = false
        stopClickLoop()
        stopSpinning()
        unequipCouchAndFree()
        return
    end
    
    enableNoclip()
    humanoid.PlatformStand = true
    
    local playerPos = targetRoot.Position + Vector3.new(0, -2.0, 0)
    playerRoot.CFrame = CFrame.new(playerPos)
    
    statusLabel.Text = "⏳ Clicando na Couch, aguardando alvo sentar... (8s timeout)"
    statusLabel.TextColor3 = isFling and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 200, 0)
    
    local startTime = tick()
    local alvoSentou = false
    local lastPos = targetRoot.Position
    local estavaAndando = false
    local waitTime = 8
    
    while tick() - startTime < waitTime do
        if not targetChar or not targetChar.Parent then
            break
        end
        
        local currentHumanoid = targetChar:FindFirstChild("Humanoid")
        if currentHumanoid and currentHumanoid.Sit == true then
            alvoSentou = true
            showNotification("✅ Alvo Sentou!", targetName .. " sentou!", 2)
            stopClickLoop()
            stopSpinning()
            break
        end
        
        local currentTargetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if currentTargetRoot then
            local currentPos = currentTargetRoot.Position
            local distance = (currentPos - lastPos).Magnitude
            
            if distance > 0.5 then
                if not estavaAndando then
                    estavaAndando = true
                    showNotification("🚶 Alvo Andando!", targetName .. " está andando!", 2)
                end
            else
                if estavaAndando then
                    estavaAndando = false
                end
            end
            
            lastPos = currentPos
            playerRoot.CFrame = CFrame.new(currentPos + Vector3.new(0, -2.0, 0))
        end
        
        task.wait(0.05)
    end
    
    if not alvoSentou then
        statusLabel.Text = "⏰ Timeout! Teleportando mesmo assim..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        showNotification("⏰ Timeout!", "Teleportando " .. targetName .. " mesmo assim!", 2)
        stopClickLoop()
        stopSpinning()
    end
    
    -- ============================================
    -- SE FOR FLING - TELEGUIADO PARA COORDENADA
    -- ============================================
    if isFling then
        statusLabel.Text = "🚀 Teleguiando " .. targetName .. " para coordenada..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        showNotification("🚀 FLING!", "Teleguiando " .. targetName .. "!", 2)
        
        targetRoot.CFrame = CFrame.new(COORDENADA_FLING + Vector3.new(0, 0.5, 0))
        playerRoot.CFrame = CFrame.new(COORDENADA_FLING + Vector3.new(0, 3, 0))
        
        statusLabel.Text = "📍 Chegou na coordenada do Fling!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        showNotification("📍 Chegou!", "Coordenada do Fling alcançada!", 2)
        
        humanoid.PlatformStand = true
        disableNoclip()
        
        statusLabel.Text = "⏳ Aguardando 0.5s para desequipar..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        task.wait(0.5)
        
        unequipCouchAndFree()
        
        playerRoot.CFrame = CFrame.new(originalPosition)
        
        isProcessingJail = false
        statusLabel.Text = "✅ " .. targetName .. " foi flingado!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        showNotification("✅ Fling Finalizado!", targetName .. " foi flingado!", 2)
        return
    end
    
    -- ============================================
    -- BRING, KILL, JAIL
    -- ============================================
    targetRoot.CFrame = CFrame.new(targetPosition + Vector3.new(0, 0.5, 0))
    playerRoot.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
    
    if isBring then
        targetRoot.CFrame = CFrame.new(originalPosition + Vector3.new(0, 0.5, 0))
        playerRoot.CFrame = CFrame.new(originalPosition + Vector3.new(0, 3, 0))
    end
    
    humanoid.PlatformStand = true
    disableNoclip()
    
    statusLabel.Text = "⏳ Aguardando 0.5s para desequipar..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    task.wait(0.5)
    
    unequipCouchAndFree()
    
    -- ============================================
    -- SE FOR JAIL - TRAVAR OS DOIS PERSONAGENS
    -- ============================================
    if not isBring and targetPosition == COORDENADA_JAIL then
        -- Travar o alvo
        freezeCharacter(targetChar)
        -- Travar o jogador
        freezeCharacter(player.Character)
        addToJail(targetPlayer)
    end
    
    if not isBring then
        playerRoot.CFrame = CFrame.new(originalPosition)
    end
    
    isProcessingJail = false
    statusLabel.Text = "✅ " .. targetName .. " foi teleportado!"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    showNotification("✅ Sucesso!", targetName .. " foi teleportado!", 2)
end

-- ============================================
-- FUNÇÃO EXECUTAR FLING
-- ============================================

function executeFling()
    if not selectedTarget then
        statusLabel.Text = "⚠️ Selecione um alvo primeiro!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        showNotification("⚠️ Erro!", "Selecione um alvo para flingar!", 2)
        return
    end
    
    if isProcessingJail or isFlinging then
        statusLabel.Text = "⏳ Já está em execução!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    isFlinging = true
    grabAndTeleport(selectedTarget, COORDENADA_FLING, false, true)
    isFlinging = false
end

-- ============================================
-- FUNÇÕES DO ESP
-- ============================================

function createESP(plr)
    if not espActive then return end
    if plr == player then return end
    
    local targetChar = plr.Character
    if not targetChar then return end
    
    local rootPart = targetChar:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    if espObjects[plr.UserId] then
        removeESP(plr)
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard_" .. plr.Name
    billboard.Size = UDim2.new(0, 200, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.MaxDistance = 1000
    billboard.Adornee = rootPart
    billboard.Parent = rootPart
    billboard.AlwaysOnTop = true
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 24)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 18
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.1
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = frame
    
    local studsLabel = Instance.new("TextLabel")
    studsLabel.Size = UDim2.new(1, 0, 0, 20)
    studsLabel.Position = UDim2.new(0, 0, 0, 24)
    studsLabel.BackgroundTransparency = 1
    studsLabel.Text = "📏 0 studs"
    studsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    studsLabel.TextSize = 14
    studsLabel.Font = Enum.Font.Gotham
    studsLabel.TextStrokeTransparency = 0.2
    studsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    studsLabel.Parent = frame
    
    espObjects[plr.UserId] = {
        billboard = billboard,
        nameLabel = nameLabel,
        studsLabel = studsLabel,
        plr = plr,
        rootPart = rootPart
    }
    
    updateESPColor(plr)
end

function updateESPColor(plr)
    local esp = espObjects[plr.UserId]
    if not esp then return end
    
    local color = Color3.fromRGB(255, 255, 255)
    
    if selectedTarget and selectedTarget.UserId == plr.UserId then
        color = Color3.fromRGB(255, 0, 0)
    elseif isInJail(plr) then
        color = Color3.fromRGB(0, 100, 255)
    end
    
    esp.nameLabel.TextColor3 = color
end

function updateESPStuds(plr)
    local esp = espObjects[plr.UserId]
    if not esp then return end
    
    local playerChar = player.Character
    if not playerChar then return end
    
    local playerRoot = playerChar:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end
    
    local targetRoot = esp.rootPart
    if not targetRoot or not targetRoot.Parent then return end
    
    local distance = (playerRoot.Position - targetRoot.Position).Magnitude
    esp.studsLabel.Text = "📏 " .. math.floor(distance) .. " studs"
end

function removeESP(plr)
    local esp = espObjects[plr.UserId]
    if esp then
        if esp.billboard then esp.billboard:Destroy() end
        espObjects[plr.UserId] = nil
    end
end

function toggleESP()
    espActive = not espActive
    
    if espActive then
        espButton.Text = "👁️ ON"
        espButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusLabel.Text = "👁️ ESP ativado!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                createESP(plr)
            end
        end
        
        espLoopConnection = RunService.Heartbeat:Connect(function()
            if not espActive then
                espLoopConnection:Disconnect()
                return
            end
            
            for userId, esp in pairs(espObjects) do
                if esp and esp.plr then
                    updateESPStuds(esp.plr)
                    updateESPColor(esp.plr)
                end
            end
        end)
        
    else
        espButton.Text = "👁️"
        espButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        espButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        statusLabel.Text = "👁️ ESP desativado!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        
        if espLoopConnection then
            espLoopConnection:Disconnect()
            espLoopConnection = nil
        end
        
        for userId, esp in pairs(espObjects) do
            if esp then
                if esp.billboard then esp.billboard:Destroy() end
            end
        end
        espObjects = {}
    end
end

-- ============================================
-- FUNÇÕES DO JAIL
-- ============================================

function isInJail(plr)
    if not plr then return false end
    for _, p in pairs(jailTargetsList) do
        if p == plr then
            return true
        end
    end
    return false
end

function addToJail(plr)
    if not plr then return end
    if isInJail(plr) then return end
    
    table.insert(jailTargetsList, plr)
    updateJailList()
    
    if espObjects[plr.UserId] then
        updateESPColor(plr)
    end
    
    showNotification("🔒 Alvo Preso!", plr.Name .. " foi adicionado ao Jail!", 2)
    
    task.wait(0.3)
    startJailLoopForTarget(plr)
end

function removeFromJail(plr)
    if not plr then return end
    
    local removed = false
    for i, p in pairs(jailTargetsList) do
        if p == plr then
            table.remove(jailTargetsList, i)
            removed = true
            break
        end
    end
    
    if removed then
        if jailLoopConnections[plr.UserId] then
            jailLoopConnections[plr.UserId]:Disconnect()
            jailLoopConnections[plr.UserId] = nil
        end
        
        updateJailList()
        
        if espObjects[plr.UserId] then
            updateESPColor(plr)
        end
        
        showNotification("🔓 Alvo Libertado!", plr.Name .. " foi removido do Jail!", 2)
    end
end

function updateJailList()
    for _, child in pairs(jailListFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if #jailTargetsList == 0 then
        jailListFrame.Visible = false
        jailListTitle.Visible = false
        stopAllJailButton.Visible = false
        return
    end
    
    jailListFrame.Visible = true
    jailListTitle.Visible = true
    stopAllJailButton.Visible = true
    
    for _, plr in pairs(jailTargetsList) do
        if plr and plr.Parent then
            local plrFrame = Instance.new("Frame")
            plrFrame.Size = UDim2.new(1, 0, 0, 22)
            plrFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            plrFrame.BackgroundTransparency = 0
            plrFrame.BorderSizePixel = 0
            plrFrame.Parent = jailListFrame
            
            local plrCorner = Instance.new("UICorner")
            plrCorner.CornerRadius = UDim.new(0, 4)
            plrCorner.Parent = plrFrame
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
            nameLabel.Position = UDim2.new(0.05, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = "🔒 " .. plr.Name
            nameLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
            nameLabel.TextSize = 12
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = plrFrame
            
            local stopBtn = Instance.new("TextButton")
            stopBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
            stopBtn.Position = UDim2.new(0.78, 0, 0.1, 0)
            stopBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            stopBtn.Text = "❌"
            stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            stopBtn.TextSize = 12
            stopBtn.Font = Enum.Font.GothamBold
            stopBtn.Parent = plrFrame
            
            local stopCorner = Instance.new("UICorner")
            stopCorner.CornerRadius = UDim.new(0, 4)
            stopCorner.Parent = stopBtn
            
            stopBtn.MouseButton1Click:Connect(function()
                if plr and plr.Parent then
                    removeFromJail(plr)
                end
            end)
        end
    end
    
    local count = #jailTargetsList
    jailListFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(count * 25, 0))
end

-- ============================================
-- LOOP DO JAIL
-- ============================================

function startJailLoopForTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Parent then return end
    
    if jailLoopConnections[targetPlayer.UserId] then
        jailLoopConnections[targetPlayer.UserId]:Disconnect()
        jailLoopConnections[targetPlayer.UserId] = nil
    end
    
    print("🔄 Loop do Jail iniciado para: " .. targetPlayer.Name)
    
    local lastPos = nil
    local isMoving = false
    local loopActive = true
    
    local connection = RunService.Heartbeat:Connect(function()
        if not loopActive then
            connection:Disconnect()
            return
        end
        
        if not targetPlayer or not targetPlayer.Parent then
            print("❌ Alvo saiu do jogo! Removendo do Jail...")
            removeFromJail(targetPlayer)
            connection:Disconnect()
            return
        end
        
        if not isInJail(targetPlayer) then
            print("🛑 Alvo não está mais no Jail, parando loop...")
            connection:Disconnect()
            return
        end
        
        if recapturingInProgress then
            return
        end
        
        local targetChar = targetPlayer.Character
        if not targetChar then
            return
        end
        
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        
        local targetHumanoid = targetChar:FindFirstChild("Humanoid")
        if not targetHumanoid then return end
        
        local targetPos = targetRoot.Position
        local distance = (targetPos - COORDENADA_JAIL_CENTER).Magnitude
        
        if targetHumanoid.Sit == true then
            lastPos = targetPos
            return
        end
        
        if lastPos then
            local moveDistance = (targetPos - lastPos).Magnitude
            isMoving = moveDistance > 0.3
        else
            isMoving = false
        end
        lastPos = targetPos
        
        if isMoving and distance > JAIL_RADIUS and not isProcessingJail then
            print("🔒 " .. targetPlayer.Name .. " está ANDANDO e fugiu da cadeia! Recapturando...")
            showNotification("🔒 Recapturando!", targetPlayer.Name .. " fugiu! Recapturando...", 2)
            statusLabel.Text = "🔒 Recapturando " .. targetPlayer.Name .. "..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            
            recapturingInProgress = true
            
            local jailTarget = targetPlayer
            
            for i, p in pairs(jailTargetsList) do
                if p == jailTarget then
                    table.remove(jailTargetsList, i)
                    break
                end
            end
            updateJailList()
            
            loopActive = false
            if jailLoopConnections[jailTarget.UserId] then
                jailLoopConnections[jailTarget.UserId]:Disconnect()
                jailLoopConnections[jailTarget.UserId] = nil
            end
            
            task.wait(0.5)
            
            grabAndTeleport(jailTarget, COORDENADA_JAIL, false, false)
            
            task.wait(0.5)
            if not isInJail(jailTarget) and jailTarget and jailTarget.Parent then
                addToJail(jailTarget)
            end
            
            recapturingInProgress = false
        end
    end)
    
    jailLoopConnections[targetPlayer.UserId] = connection
end

-- ============================================
-- FUNÇÕES DO TP E VIEW
-- ============================================

function executeTP()
    if not selectedTarget then
        statusLabel.Text = "⚠️ Selecione um alvo primeiro!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        showNotification("⚠️ Erro!", "Selecione um alvo primeiro!", 2)
        return
    end
    
    local targetChar = selectedTarget.Character
    if not targetChar then
        statusLabel.Text = "❌ Alvo sem personagem!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        statusLabel.Text = "❌ Alvo sem RootPart!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    local playerChar = player.Character
    if not playerChar then
        statusLabel.Text = "❌ Você sem personagem!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    local playerRoot = playerChar:FindFirstChild("HumanoidRootPart")
    if not playerRoot then
        statusLabel.Text = "❌ Você sem RootPart!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    local targetPos = targetRoot.Position + Vector3.new(0, 3, 0)
    playerRoot.CFrame = CFrame.new(targetPos)
    
    statusLabel.Text = "📍 Teleportado para " .. selectedTarget.Name
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    showNotification("📍 Teleportado!", "Teleportado para " .. selectedTarget.Name, 2)
end

function toggleView()
    if isViewing then
        stopView()
        return
    end
    
    if not selectedTarget then
        statusLabel.Text = "⚠️ Selecione um alvo primeiro!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    local targetChar = selectedTarget.Character
    if not targetChar then
        statusLabel.Text = "❌ Alvo sem personagem!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    local targetHead = targetChar:FindFirstChild("Head")
    if not targetHead then
        statusLabel.Text = "❌ Alvo sem Head!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    isViewing = true
    viewButton.Text = "📷 ON"
    viewButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    viewButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopViewButton.Visible = true
    
    statusLabel.Text = "📷 Visualizando: " .. selectedTarget.Name
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    showNotification("📷 View Ativado!", "Visualizando " .. selectedTarget.Name, 2)
    
    local camera = Workspace.CurrentCamera
    camera.CameraSubject = targetHead
    camera.CameraType = Enum.CameraType.Attach
    
    cameraConnection = RunService.Heartbeat:Connect(function()
        if not isViewing or not selectedTarget then
            return
        end
        
        local targetChar = selectedTarget.Character
        if not targetChar then
            stopView()
            return
        end
        
        local targetHead = targetChar:FindFirstChild("Head")
        if not targetHead then
            stopView()
            return
        end
        
        camera.CameraSubject = targetHead
    end)
end

function stopView()
    isViewing = false
    viewButton.Text = "📷 View"
    viewButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    viewButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopViewButton.Visible = false
    
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    
    local playerChar = player.Character
    if playerChar then
        local playerHead = playerChar:FindFirstChild("Head")
        if playerHead then
            local camera = Workspace.CurrentCamera
            camera.CameraSubject = playerHead
            camera.CameraType = Enum.CameraType.Custom
        end
    end
    
    statusLabel.Text = "📷 View desativado!"
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
end

-- ============================================
-- FUNÇÕES DE UTILITÁRIOS
-- ============================================

function enableNoclip()
    local char = player.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

function disableNoclip()
    local char = player.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- ============================================
-- FUNÇÃO DE PESQUISA E ATUALIZAR LISTA
-- ============================================

function updatePlayerList(filter)
    filter = filter or ""
    filter = string.lower(filter)
    
    for _, child in pairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local count = 0
    local playersList = Players:GetPlayers()
    
    for _, plr in pairs(playersList) do
        if plr ~= player then
            local nameLower = string.lower(plr.Name)
            if filter == "" or string.sub(nameLower, 1, string.len(filter)) == filter then
                count = count + 1
                local playerButton = Instance.new("TextButton")
                playerButton.Size = UDim2.new(1, 0, 0, 26)
                playerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                playerButton.BorderSizePixel = 0
                playerButton.Text = "👤 " .. plr.Name
                playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                playerButton.TextSize = 12
                playerButton.Font = Enum.Font.Gotham
                playerButton.TextXAlignment = Enum.TextXAlignment.Left
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = playerButton
                
                playerButton.MouseEnter:Connect(function()
                    playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                end)
                
                playerButton.MouseLeave:Connect(function()
                    playerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                end)
                
                playerButton.MouseButton1Click:Connect(function()
                    selectedTarget = plr
                    targetLabel.Text = "🎯 Alvo: " .. plr.Name
                    targetLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    statusLabel.Text = "✅ Alvo selecionado: " .. plr.Name
                    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    
                    if isViewing then
                        stopView()
                        task.wait(0.3)
                        toggleView()
                    end
                    
                    for userId, esp in pairs(espObjects) do
                        if esp and esp.plr then
                            updateESPColor(esp.plr)
                        end
                    end
                end)
                
                playerButton.Parent = playerListFrame
            end
        end
    end
    
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(count * 29, 0))
end

-- ============================================
-- FUNÇÕES PRINCIPAIS
-- ============================================

function executeBring()
    if not selectedTarget then
        statusLabel.Text = "⚠️ Selecione um alvo primeiro!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        showNotification("⚠️ Erro!", "Selecione um alvo primeiro!", 2)
        return
    end
    
    if isProcessingJail or isBringing or isFlinging then
        statusLabel.Text = "⏳ Já está em execução!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    isBringing = true
    grabAndTeleport(selectedTarget, originalPosition or Vector3.new(0, 0, 0), true, false)
    isBringing = false
end

function executeKill()
    if not selectedTarget then
        statusLabel.Text = "⚠️ Selecione um alvo primeiro!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        showNotification("⚠️ Erro!", "Selecione um alvo primeiro!", 2)
        return
    end
    
    if isProcessingJail or isKilling or isFlinging then
        statusLabel.Text = "⏳ Já está em execução!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    isKilling = true
    grabAndTeleport(selectedTarget, COORDENADA_KILL, false, false)
    isKilling = false
end

function executeJail()
    if not selectedTarget then
        statusLabel.Text = "⚠️ Selecione um alvo primeiro!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        showNotification("⚠️ Erro!", "Selecione um alvo primeiro!", 2)
        return
    end
    
    if isInJail(selectedTarget) then
        statusLabel.Text = "⚠️ Alvo já está no Jail!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        showNotification("⚠️ Aviso!", selectedTarget.Name .. " já está no Jail!", 2)
        return
    end
    
    if isProcessingJail or isFlinging then
        statusLabel.Text = "⏳ Já está em execução!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    statusLabel.Text = "🔒 Iniciando Jail em: " .. selectedTarget.Name
    statusLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    
    grabAndTeleport(selectedTarget, COORDENADA_JAIL, false, false)
end

function executeAddJail()
    if not selectedTarget then
        statusLabel.Text = "⚠️ Selecione um alvo primeiro!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        showNotification("⚠️ Erro!", "Selecione um alvo para adicionar!", 2)
        return
    end
    
    if isInJail(selectedTarget) then
        statusLabel.Text = "⚠️ Alvo já está no Jail!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        showNotification("⚠️ Aviso!", selectedTarget.Name .. " já está no Jail!", 2)
        return
    end
    
    if isProcessingJail or isFlinging then
        statusLabel.Text = "⏳ Já está em execução!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    statusLabel.Text = "➕ Adicionando " .. selectedTarget.Name .. " ao Jail..."
    statusLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
    
    grabAndTeleport(selectedTarget, COORDENADA_JAIL, false, false)
end

function stopAllJail()
    for i, plr in pairs(jailTargetsList) do
        if jailLoopConnections[plr.UserId] then
            jailLoopConnections[plr.UserId]:Disconnect()
            jailLoopConnections[plr.UserId] = nil
        end
    end
    jailTargetsList = {}
    updateJailList()
    stopAllJailButton.Visible = false
    recapturingInProgress = false
    statusLabel.Text = "🛑 Todos os Jail foram parados!"
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    showNotification("🛑 Jail Parado!", "Todos os alvos foram libertados!", 2)
end

-- ============================================
-- CONEXÕES
-- ============================================

bringButton.MouseButton1Click:Connect(executeBring)
killButton.MouseButton1Click:Connect(executeKill)
jailButton.MouseButton1Click:Connect(executeJail)
addJailButton.MouseButton1Click:Connect(executeAddJail)
espButton.MouseButton1Click:Connect(toggleESP)
tpButton.MouseButton1Click:Connect(executeTP)
viewButton.MouseButton1Click:Connect(toggleView)
stopViewButton.MouseButton1Click:Connect(stopView)
stopAllJailButton.MouseButton1Click:Connect(stopAllJail)
antiSitButton.MouseButton1Click:Connect(toggleAntiSit)
flingButton.MouseButton1Click:Connect(executeFling)
clickButtonBtn.MouseButton1Click:Connect(clickButtons)

-- Pesquisa em tempo real
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    searchText = searchBox.Text
    updatePlayerList(searchText)
end)

-- Atualizar lista quando jogadores entrarem/saírem
Players.PlayerAdded:Connect(function(plr)
    task.wait(0.5)
    updatePlayerList(searchText)
    if espActive and plr ~= player then
        task.wait(0.5)
        createESP(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    task.wait(0.5)
    updatePlayerList(searchText)
    if espActive then
        removeESP(plr)
    end
    if selectedTarget == plr then
        selectedTarget = nil
        targetLabel.Text = "🎯 Alvo: Nenhum"
        targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        if isViewing then
            stopView()
        end
    end
    if isInJail(plr) then
        removeFromJail(plr)
    end
end)

-- Recriar ESP quando personagem renascer
local function onCharacterAdded(plr)
    if espActive and plr ~= player then
        task.wait(0.5)
        createESP(plr)
    end
end

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= player then
        plr.CharacterAdded:Connect(function()
            onCharacterAdded(plr)
        end)
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= player then
        plr.CharacterAdded:Connect(function()
            onCharacterAdded(plr)
        end)
    end
end)

task.wait(0.5)
updatePlayerList()

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    statusLabel.Text = "✅ Personagem atualizado!"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
end)

print("✅ Script carregado! Selecione um alvo e use as funções!")
