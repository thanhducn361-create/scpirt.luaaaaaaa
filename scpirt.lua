-- ============================================================
--  NEBULA | converted to scpirt.lua library
--  cre by bellchuppy
-- ============================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local UIS            = UserInputService

local LocalPlayer    = Players.LocalPlayer

-- ── UI LIBRARY ──────────────────────────────────────────────
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/thanhducn361-create/scpirt.luaaaaa/ef19afe3ed2f5586f3e8fd307dab48b2f1990a5e/scpirt.lua"
))()

local Window = Library:Window({
    Title  = "NEBULA",
    Desc   = "cre by bellchuppy",
    Icon   = "star",
    Theme  = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size    = UDim2.new(0, 550, 0, 450)
    },
    CloseUIButton = {
        Enabled = true,
        Text    = "x"
    }
})

-- ── NOTIFY HELPER ───────────────────────────────────────────
local NOTIFICATION = true

local function Notify(txt)
    if not NOTIFICATION then return end
    Window:Notify({
        Title = "NEBULA",
        Desc  = txt,
        Time  = 2
    })
end

-- ============================================================
--  TAB 1 : MOVEMENT
-- ============================================================
local MovTab = Window:Tab({ Title = "MOVEMENT", Icon = "star" })

-- ── SECTION: MOVEMENT ───────────────────────────────────────
MovTab:Section({ Title = "Movement System" })

local SpeedOn    = false
local SpeedValue = 50
local JumpOn     = false
local JumpValue  = 70
local InfJump    = false
local Noclip     = false
local FloatOn    = false

local FloatPart, FloatConn, NoclipConn, FloatY

local function GetChar() return LocalPlayer.Character end
local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function GetHRP()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Speed + Jump loop
RunService.Heartbeat:Connect(function()
    local char = GetChar()
    local hum  = GetHum()
    local hrp  = GetHRP()
    if not char or not hum or not hrp then return end
    if hum.Health <= 0 then return end

    if SpeedOn then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = Vector3.new(
                moveDir.X * SpeedValue,
                hrp.AssemblyLinearVelocity.Y,
                moveDir.Z * SpeedValue
            )
        end
    end

    hum.UseJumpPower = true
    hum.JumpPower    = JumpOn and JumpValue or 50
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if InfJump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Noclip
local function EnableNoclip()
    if NoclipConn then return end
    NoclipConn = RunService.Stepped:Connect(function()
        local char = GetChar()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end

local function DisableNoclip()
    if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
    local char = GetChar()
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

-- Float
local function EnableFloat()
    if FloatConn then return end
    local hrp = GetHRP()
    if not hrp then return end
    FloatY     = hrp.Position.Y - 3
    FloatPart  = Instance.new("Part")
    FloatPart.Size        = Vector3.new(999999, 1, 999999)
    FloatPart.Anchored    = true
    FloatPart.Transparency = 1
    FloatPart.CanCollide  = true
    FloatPart.Parent      = workspace
    FloatConn = RunService.Heartbeat:Connect(function()
        if not FloatOn then return end
        local hrp2 = GetHRP()
        local hum2 = GetHum()
        if hrp2 and hum2 then
            if hum2.FloorMaterial == Enum.Material.Air and hrp2.AssemblyLinearVelocity.Y < 0 then
                FloatY = hrp2.Position.Y - 3
            end
            FloatPart.Position = Vector3.new(hrp2.Position.X, FloatY, hrp2.Position.Z)
        end
    end)
end

local function DisableFloat()
    if FloatConn then FloatConn:Disconnect() FloatConn = nil end
    if FloatPart then FloatPart:Destroy() FloatPart = nil end
end

MovTab:Toggle({ Title = "SPEED", Value = false, Callback = function(v)
    SpeedOn = v; Notify("SPEED " .. (v and "ON" or "OFF"))
end })

MovTab:Slider({ Title = "SPEED VALUE", Min = 1, Max = 300, Value = 50, Callback = function(v)
    SpeedValue = v
end })

MovTab:Toggle({ Title = "JUMP", Value = false, Callback = function(v)
    JumpOn = v; Notify("JUMP " .. (v and "ON" or "OFF"))
end })

MovTab:Slider({ Title = "JUMP VALUE", Min = 1, Max = 300, Value = 70, Callback = function(v)
    JumpValue = v
end })

MovTab:Toggle({ Title = "INFINITE JUMP", Value = false, Callback = function(v)
    InfJump = v; Notify("INFINITE JUMP " .. (v and "ON" or "OFF"))
end })

MovTab:Toggle({ Title = "NOCLIP", Value = false, Callback = function(v)
    Noclip = v
    if v then EnableNoclip() else DisableNoclip() end
    Notify("NOCLIP " .. (v and "ON" or "OFF"))
end })

MovTab:Toggle({ Title = "FLOAT", Value = false, Callback = function(v)
    FloatOn = v
    if v then EnableFloat() else DisableFloat() end
    Notify("FLOAT " .. (v and "ON" or "OFF"))
end })

-- ── SECTION: INVISIBLE ──────────────────────────────────────
MovTab:Section({ Title = "Invisible" })

local InvisibleEnabled  = false
local LockInvisibleBtn  = false
local invisCurrentSize  = 18
local invisCurrentShape = "SQUARE"
local character, humanoid, rootPart
local parts = {}

local function updateCharacterData()
    character  = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    humanoid   = character:WaitForChild("Humanoid")
    rootPart   = character:WaitForChild("HumanoidRootPart")
    parts      = {}
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency == 0 then
            table.insert(parts, v)
        end
    end
end

updateCharacterData()

local function UpdateInvisBtn() end -- forward declare, defined after GUI

local function ApplyInvisible(state)
    InvisibleEnabled = state
    for _, v in pairs(parts) do
        v.Transparency = state and 0.5 or 0
    end
    Notify(state and "INVISIBLE ON" or "INVISIBLE OFF")
    UpdateInvisBtn()
end

RunService.Heartbeat:Connect(function()
    if InvisibleEnabled and rootPart and humanoid then
        local oldCF     = rootPart.CFrame
        local oldOffset = humanoid.CameraOffset
        local hideCF    = oldCF * CFrame.new(0, -200000, 0)
        rootPart.CFrame = hideCF
        humanoid.CameraOffset = hideCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position
        RunService.RenderStepped:Wait()
        rootPart.CFrame       = oldCF
        humanoid.CameraOffset = oldOffset
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    InvisibleEnabled = false
    task.wait(1)
    updateCharacterData()
end)

-- Float GUI for Invisible button
local InvisGui = Instance.new("ScreenGui")
InvisGui.Name         = "InvisibleFloatGui"
InvisGui.Parent       = game.CoreGui
InvisGui.Enabled      = false
InvisGui.ResetOnSpawn = false

local InvisBtn = Instance.new("TextButton")
InvisBtn.Size                   = UDim2.new(0, 200, 0, 50)
InvisBtn.Position               = UDim2.new(0.5, -100, 0.7, 0)
InvisBtn.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
InvisBtn.BackgroundTransparency = 1
InvisBtn.Text                   = "INVISIBLE : OFF"
InvisBtn.Font                   = Enum.Font.Gotham
InvisBtn.TextSize               = 18
InvisBtn.TextColor3             = Color3.fromRGB(0, 0, 0)
InvisBtn.TextStrokeTransparency = 0.8
InvisBtn.Parent                 = InvisGui

local invisCorner = Instance.new("UICorner", InvisBtn)
invisCorner.CornerRadius = UDim.new(0, 12)

local invisStroke = Instance.new("UIStroke")
invisStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
invisStroke.Color     = Color3.fromRGB(255, 255, 255)
invisStroke.Thickness = 2
invisStroke.Parent    = InvisBtn

local function applyInvisShape(shape, size)
    if shape == "RECTANGLE" then
        InvisBtn.Size = UDim2.new(0, size*8, 0, size*2)
        invisCorner.CornerRadius = UDim.new(0, 16)
        InvisBtn.TextSize = math.clamp(size*0.55, 8, 60)
    elseif shape == "SQUARE" then
        InvisBtn.Size = UDim2.new(0, size*4, 0, size*4)
        invisCorner.CornerRadius = UDim.new(0, 8)
        InvisBtn.TextSize = math.clamp(size*0.4, 6, 50)
    elseif shape == "CIRCLE" then
        InvisBtn.Size = UDim2.new(0, size*3, 0, size*3)
        invisCorner.CornerRadius = UDim.new(0.5, 0)
        InvisBtn.TextSize = math.clamp(size*0.3, 5, 40)
    end
end

applyInvisShape(invisCurrentShape, invisCurrentSize)

UpdateInvisBtn = function()
    InvisBtn.Text = InvisibleEnabled and "INVISIBLE : ON" or "INVISIBLE : OFF"
end

InvisBtn.MouseButton1Click:Connect(function() ApplyInvisible(not InvisibleEnabled) end)

-- drag
local invDragging, invDragStart, invStartPos = false, nil, nil
InvisBtn.InputBegan:Connect(function(input)
    if LockInvisibleBtn then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        invDragging = true; invDragStart = input.Position; invStartPos = InvisBtn.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if LockInvisibleBtn then return end
    if invDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - invDragStart
        InvisBtn.Position = UDim2.new(invStartPos.X.Scale, invStartPos.X.Offset + d.X, invStartPos.Y.Scale, invStartPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        invDragging = false
    end
end)

MovTab:Toggle({ Title = "INVISIBLE", Value = false, Callback = function(v) ApplyInvisible(v) end })

MovTab:Toggle({ Title = "FLOAT INVISIBLE BUTTON", Value = false, Callback = function(v)
    InvisGui.Enabled = v; Notify(v and "FLOAT BUTTON ENABLED" or "FLOAT BUTTON DISABLED")
end })

MovTab:Toggle({ Title = "INVISIBLE BUTTON (invis btn)", Value = false, Callback = function(v)
    InvisBtn.TextTransparency = v and 1 or 0
    invisStroke.Transparency  = v and 1 or 0
    Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
end })

MovTab:Slider({ Title = "INVISIBLE BUTTON SIZE", Min = 1, Max = 100, Value = 18, Callback = function(v)
    invisCurrentSize = v; applyInvisShape(invisCurrentShape, invisCurrentSize)
end })

MovTab:Dropdown({ Title = "BUTTON SHAPE", List = {"RECTANGLE", "SQUARE", "CIRCLE"}, Value = "SQUARE", Callback = function(opt)
    invisCurrentShape = opt
    applyInvisShape(invisCurrentShape, invisCurrentSize)
    Notify("INVIS SHAPE: " .. invisCurrentShape)
end })

MovTab:Toggle({ Title = "LOCK INVISIBLE BUTTON", Value = false, Callback = function(v)
    LockInvisibleBtn = v; Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
end })

-- ── SECTION: SPEED GLITCH ───────────────────────────────────
MovTab:Section({ Title = "Speed Glitch" })

local DEFAULT_WALKSPEED  = 16
local SpeedGlitchEnabled = false
local SpeedGlitchValue   = 50
local SpeedConn2
local humanoidSG

local function BindCharacterSG(char)
    humanoidSG = char:WaitForChild("Humanoid")
    humanoidSG.WalkSpeed = DEFAULT_WALKSPEED
    if SpeedConn2 then SpeedConn2:Disconnect() SpeedConn2 = nil end
    SpeedConn2 = RunService.RenderStepped:Connect(function()
        if not humanoidSG or humanoidSG.Health <= 0 then return end
        if not SpeedGlitchEnabled then
            if humanoidSG.WalkSpeed ~= DEFAULT_WALKSPEED then humanoidSG.WalkSpeed = DEFAULT_WALKSPEED end
            return
        end
        local state     = humanoidSG:GetState()
        local isJumping = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall
        local isMoving  = humanoidSG.MoveDirection.Magnitude > 0.1
        humanoidSG.WalkSpeed = (isJumping and isMoving) and SpeedGlitchValue or DEFAULT_WALKSPEED
    end)
end

LocalPlayer.CharacterAdded:Connect(BindCharacterSG)
if LocalPlayer.Character then BindCharacterSG(LocalPlayer.Character) end

-- Speed Glitch Float GUI
local SpeedGui = Instance.new("ScreenGui")
SpeedGui.Name = "SpeedGlitchFloatingGui"; SpeedGui.Parent = game.CoreGui
SpeedGui.Enabled = false; SpeedGui.ResetOnSpawn = false

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Position               = UDim2.new(0.5, -100, 0.48, 0)
SpeedBtn.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
SpeedBtn.BackgroundTransparency = 1
SpeedBtn.Text                   = "SPEED GLITCH : OFF"
SpeedBtn.Font                   = Enum.Font.Gotham
SpeedBtn.TextColor3             = Color3.fromRGB(0, 0, 0)
SpeedBtn.TextStrokeTransparency = 0.8
SpeedBtn.Parent                 = SpeedGui

local speedCorner = Instance.new("UICorner", SpeedBtn); speedCorner.CornerRadius = UDim.new(0, 12)
local strokeSpeed = Instance.new("UIStroke")
strokeSpeed.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
strokeSpeed.Color = Color3.fromRGB(255,255,255); strokeSpeed.Thickness = 2; strokeSpeed.Parent = SpeedBtn

local sp_Size = 18; local sp_Shape = "SQUARE"; local LockSpeedBtn = false

local function applySpeedShape(shape, size)
    if shape == "RECTANGLE" then
        SpeedBtn.Size = UDim2.new(0, size*8, 0, size*2)
        speedCorner.CornerRadius = UDim.new(0, 16)
        SpeedBtn.TextSize = math.clamp(size*0.55, 8, 60)
    elseif shape == "SQUARE" then
        SpeedBtn.Size = UDim2.new(0, size*4, 0, size*4)
        speedCorner.CornerRadius = UDim.new(0, 8)
        SpeedBtn.TextSize = math.clamp(size*0.4, 6, 50)
    elseif shape == "CIRCLE" then
        SpeedBtn.Size = UDim2.new(0, size*3, 0, size*3)
        speedCorner.CornerRadius = UDim.new(0.5, 0)
        SpeedBtn.TextSize = math.clamp(size*0.3, 5, 40)
    end
end
applySpeedShape(sp_Shape, sp_Size)

SpeedBtn.MouseButton1Click:Connect(function()
    SpeedGlitchEnabled = not SpeedGlitchEnabled
    SpeedBtn.Text = SpeedGlitchEnabled and "SPEED GLITCH : ON" or "SPEED GLITCH : OFF"
end)

local draggingS, dragStartS, startPosS = false, nil, nil
SpeedBtn.InputBegan:Connect(function(input)
    if LockSpeedBtn then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingS = true; dragStartS = input.Position; startPosS = SpeedBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if LockSpeedBtn then return end
    if draggingS and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStartS
        SpeedBtn.Position = UDim2.new(startPosS.X.Scale, startPosS.X.Offset+d.X, startPosS.Y.Scale, startPosS.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingS = false end
end)

MovTab:Toggle({ Title = "SPEED GLITCH", Value = false, Callback = function(v)
    SpeedGlitchEnabled = v; Notify(v and "SPEEDGLITCH ON" or "SPEEDGLITCH OFF")
end })
MovTab:Slider({ Title = "SPEED GLITCH VALUE", Min = 16, Max = 200, Value = 50, Callback = function(v) SpeedGlitchValue = v end })
MovTab:Toggle({ Title = "FLOAT SPEEDGLITCH BUTTON", Value = false, Callback = function(v)
    SpeedGui.Enabled = v; Notify(v and "FLOAT BUTTON ENABLED" or "FLOAT BUTTON DISABLED")
end })
MovTab:Toggle({ Title = "INVISIBLE SPEEDGLITCH BUTTON", Value = false, Callback = function(v)
    SpeedBtn.TextTransparency = v and 1 or 0; strokeSpeed.Transparency = v and 1 or 0
    Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
end })
MovTab:Slider({ Title = "SPEEDGLITCH BUTTON SIZE", Min = 1, Max = 100, Value = 18, Callback = function(v)
    sp_Size = v; applySpeedShape(sp_Shape, sp_Size)
end })
MovTab:Dropdown({ Title = "BUTTON SHAPE", List = {"RECTANGLE", "SQUARE", "CIRCLE"}, Value = "SQUARE", Callback = function(opt)
    sp_Shape = opt
    applySpeedShape(sp_Shape, sp_Size)
    Notify("SPEEDGLITCH SHAPE: " .. sp_Shape)
end })
MovTab:Toggle({ Title = "LOCK SPEEDGLITCH BUTTON", Value = false, Callback = function(v)
    LockSpeedBtn = v; Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
end })

-- ── SECTION: REMOVE HIDDEN PLAYER ───────────────────────────
MovTab:Section({ Title = "Remove Hidden Player" })

local RemoveHidden    = false
local RemoveConn2
local RemoveLock      = false
local savedTransparency = {}

local RemoveGui = Instance.new("ScreenGui")
RemoveGui.Name = "RemoveHiddenGui"; RemoveGui.Parent = game.CoreGui
RemoveGui.Enabled = false; RemoveGui.ResetOnSpawn = false

local RemoveBtn = Instance.new("TextButton")
RemoveBtn.Position               = UDim2.new(0.5,-100,0.8,0)
RemoveBtn.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
RemoveBtn.BackgroundTransparency = 1
RemoveBtn.Text                   = "REMOVE HIDDEN : OFF"
RemoveBtn.Font                   = Enum.Font.Gotham
RemoveBtn.TextColor3             = Color3.fromRGB(0,0,0)
RemoveBtn.TextStrokeTransparency = 0.8
RemoveBtn.Parent                 = RemoveGui

local rmCorner = Instance.new("UICorner"); rmCorner.CornerRadius = UDim.new(0,12); rmCorner.Parent = RemoveBtn
local rmStroke = Instance.new("UIStroke")
rmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; rmStroke.Thickness = 2
rmStroke.Color = Color3.fromRGB(255,255,255); rmStroke.Parent = RemoveBtn

local rm_Size = 18; local rm_Shape = "SQUARE"

local function applyRemoveShape(shape, size)
    if shape == "RECTANGLE" then
        RemoveBtn.Size = UDim2.new(0, size*8, 0, size*2)
        rmCorner.CornerRadius = UDim.new(0, 16)
        RemoveBtn.TextSize = math.clamp(size*0.55, 8, 60)
    elseif shape == "SQUARE" then
        RemoveBtn.Size = UDim2.new(0, size*4, 0, size*4)
        rmCorner.CornerRadius = UDim.new(0, 8)
        RemoveBtn.TextSize = math.clamp(size*0.4, 6, 50)
    elseif shape == "CIRCLE" then
        RemoveBtn.Size = UDim2.new(0, size*3, 0, size*3)
        rmCorner.CornerRadius = UDim.new(0.5, 0)
        RemoveBtn.TextSize = math.clamp(size*0.3, 5, 40)
    end
end
applyRemoveShape(rm_Shape, rm_Size)

local function ShowHidden()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char2 = plr.Character
            if char2 then
                for _, v in pairs(char2:GetDescendants()) do
                    if v:IsA("BasePart") then
                        if savedTransparency[v] == nil then savedTransparency[v] = v.Transparency end
                        v.Transparency = 0; v.LocalTransparencyModifier = 0; v.CanCollide = true
                    end
                    if v:IsA("Decal") then v.Transparency = 0 end
                    if v:IsA("ParticleEmitter") then v.Enabled = false end
                end
                local hrp2 = char2:FindFirstChild("HumanoidRootPart")
                if hrp2 then hrp2.Transparency = 0 end
            end
        end
    end
end

local function RestorePlayers()
    for part, value in pairs(savedTransparency) do
        if part and part.Parent then part.Transparency = value end
    end
    savedTransparency = {}
end

local function StartRemove()
    if RemoveConn2 then return end
    RemoveConn2 = RunService.Heartbeat:Connect(function()
        if RemoveHidden then ShowHidden() end
    end)
end

local function StopRemove()
    if RemoveConn2 then RemoveConn2:Disconnect() RemoveConn2 = nil end
    RestorePlayers()
end

local function UpdateRemoveBtn()
    RemoveBtn.Text = RemoveHidden and "REMOVE HIDDEN : ON" or "REMOVE HIDDEN : OFF"
end

RemoveBtn.MouseButton1Click:Connect(function()
    RemoveHidden = not RemoveHidden; UpdateRemoveBtn()
    if RemoveHidden then StartRemove() else StopRemove() end
    Notify(RemoveHidden and "REMOVE HIDDEN ON" or "REMOVE HIDDEN OFF")
end)

local rmDragging, rmDragStart, rmStartPos = false, nil, nil
RemoveBtn.InputBegan:Connect(function(input)
    if RemoveLock then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        rmDragging = true; rmDragStart = input.Position; rmStartPos = RemoveBtn.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if RemoveLock then return end
    if rmDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - rmDragStart
        RemoveBtn.Position = UDim2.new(rmStartPos.X.Scale, rmStartPos.X.Offset+d.X, rmStartPos.Y.Scale, rmStartPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then rmDragging = false end
end)

MovTab:Toggle({ Title = "REMOVE HIDDEN PLAYER", Value = false, Callback = function(v)
    RemoveHidden = v; UpdateRemoveBtn()
    if v then StartRemove() else StopRemove() end
end })
MovTab:Toggle({ Title = "FLOAT REMOVE HIDDEN BUTTON", Value = false, Callback = function(v)
    RemoveGui.Enabled = v; Notify(v and "FLOAT BUTTON ENABLED" or "FLOAT BUTTON DISABLED")
end })
MovTab:Toggle({ Title = "INVISIBLE REMOVE BUTTON", Value = false, Callback = function(v)
    RemoveBtn.TextTransparency = v and 1 or 0; rmStroke.Transparency = v and 1 or 0
    Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
end })
MovTab:Slider({ Title = "REMOVE BUTTON SIZE", Min = 1, Max = 100, Value = 18, Callback = function(v)
    rm_Size = v; applyRemoveShape(rm_Shape, rm_Size)
end })
MovTab:Dropdown({ Title = "BUTTON SHAPE", List = {"RECTANGLE", "SQUARE", "CIRCLE"}, Value = "SQUARE", Callback = function(opt)
    rm_Shape = opt
    applyRemoveShape(rm_Shape, rm_Size)
    Notify("REMOVE SHAPE: " .. rm_Shape)
end })
MovTab:Toggle({ Title = "LOCK REMOVE BUTTON", Value = false, Callback = function(v)
    RemoveLock = v; Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
end })

-- ── SECTION: AUTO WALLHOP ───────────────────────────────────
MovTab:Section({ Title = "Auto Wallhop" })

local WallHopEnabled  = false
local LOCKED_WALL     = false
local Camera          = workspace.CurrentCamera
local isFlicking      = false
local lastFlickTime   = 0
local lastHitInstance = nil

-- Logic
local function PerformWallHop()
    if isFlicking then return end
    isFlicking = true
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChild("Humanoid")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then isFlicking = false; return end
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
    local camStart = Camera.CFrame
    Camera.CFrame = camStart * CFrame.Angles(0, math.rad(180), 0)
    task.wait(0.01)
    Camera.CFrame = camStart
    isFlicking = false
end

RunService.Heartbeat:Connect(function()
    if not WallHopEnabled then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(hrp.Position, Camera.CFrame.LookVector * 3, rayParams)
    if result and result.Instance and result.Instance.CanCollide then
        if lastHitInstance and lastHitInstance ~= result.Instance then
            if tick() - lastFlickTime > 0.05 then
                lastFlickTime = tick()
                PerformWallHop()
            end
        end
        lastHitInstance = result.Instance
    else
        lastHitInstance = nil
    end
end)

-- Float GUI
local WallGui = Instance.new("ScreenGui")
WallGui.Name         = "WallHopFloatGui"
WallGui.Parent       = game.CoreGui
WallGui.Enabled      = false
WallGui.ResetOnSpawn = false

local WallBtn = Instance.new("TextButton")
WallBtn.Position               = UDim2.new(0.5, -95, 0.55, 0)
WallBtn.Text                   = "AUTO WALLHOP : OFF"
WallBtn.Font                   = Enum.Font.Gotham
WallBtn.TextColor3             = Color3.fromRGB(0, 0, 0)
WallBtn.TextStrokeTransparency = 0.8
WallBtn.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
WallBtn.BackgroundTransparency = 1
WallBtn.Parent                 = WallGui

local wallCorner = Instance.new("UICorner")
wallCorner.Parent         = WallBtn
wallCorner.CornerRadius   = UDim.new(0, 12)

local wallStroke = Instance.new("UIStroke")
wallStroke.Parent          = WallBtn
wallStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
wallStroke.Color           = Color3.fromRGB(255, 255, 255)
wallStroke.Thickness       = 2

local wall_Size  = 25
local wall_Shape = "SQUARE"

local function applyWallShape(shape, size)
    if shape == "RECTANGLE" then
        local w, h = size * 8, size * 2
        WallBtn.Size              = UDim2.new(0, w, 0, h)
        wallCorner.CornerRadius   = UDim.new(0, 16)
        WallBtn.TextSize          = math.clamp(size * 0.55, 8, 60)
    elseif shape == "SQUARE" then
        local s = size * 4
        WallBtn.Size              = UDim2.new(0, s, 0, s)
        wallCorner.CornerRadius   = UDim.new(0, 8)
        WallBtn.TextSize          = math.clamp(size * 0.4, 6, 50)
    elseif shape == "CIRCLE" then
        local s = size * 3
        WallBtn.Size              = UDim2.new(0, s, 0, s)
        wallCorner.CornerRadius   = UDim.new(0.5, 0)
        WallBtn.TextSize          = math.clamp(size * 0.3, 5, 40)
    end
end

local function UpdateWallBtn()
    WallBtn.Text = WallHopEnabled and "AUTO WALLHOP : ON" or "AUTO WALLHOP : OFF"
end

applyWallShape(wall_Shape, wall_Size)
UpdateWallBtn()

-- Toggle trong menu
MovTab:Toggle({ Title = "AUTO WALLHOP", Value = false, Callback = function(v)
    WallHopEnabled = v
    UpdateWallBtn()
    Notify("AUTO WALLHOP " .. (v and "ON" or "OFF"))
end })

-- Float button click
WallBtn.MouseButton1Click:Connect(function()
    WallHopEnabled = not WallHopEnabled
    UpdateWallBtn()
    Notify("AUTO WALLHOP " .. (WallHopEnabled and "ON" or "OFF"))
end)

-- Drag
local wallDragging, wallDragStart, wallStartPos = false, nil, nil
WallBtn.InputBegan:Connect(function(input)
    if LOCKED_WALL then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        wallDragging = true
        wallDragStart = input.Position
        wallStartPos  = WallBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not wallDragging or LOCKED_WALL then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - wallDragStart
        WallBtn.Position = UDim2.new(
            wallStartPos.X.Scale, wallStartPos.X.Offset + d.X,
            wallStartPos.Y.Scale, wallStartPos.Y.Offset + d.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        wallDragging = false
    end
end)

MovTab:Toggle({ Title = "FLOAT AUTO WALLHOP BUTTON", Value = false, Callback = function(v)
    WallGui.Enabled = v
    Notify(v and "FLOAT WALLHOP ENABLED" or "FLOAT WALLHOP DISABLED")
end })

MovTab:Section({ Title = "Wallhop - Button Settings" })

MovTab:Toggle({ Title = "INVISIBLE WALLHOP BUTTON", Value = false, Callback = function(v)
    WallBtn.TextTransparency = v and 1 or 0
    wallStroke.Transparency  = v and 1 or 0
    Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
end })
MovTab:Slider({ Title = "WALLHOP BUTTON SIZE", Min = 1, Max = 100, Value = 25, Callback = function(v)
    wall_Size = v
    applyWallShape(wall_Shape, wall_Size)
end })
MovTab:Dropdown({ Title = "BUTTON SHAPE", List = {"RECTANGLE", "SQUARE", "CIRCLE"}, Value = "SQUARE", Callback = function(opt)
    wall_Shape = opt
    applyWallShape(wall_Shape, wall_Size)
    Notify("WALLHOP SHAPE: " .. wall_Shape)
end })
MovTab:Toggle({ Title = "LOCK WALLHOP BUTTON", Value = false, Callback = function(v)
    LOCKED_WALL = v
    Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
end })

-- ── SECTION: SETTINGS (Movement tab) ────────────────────────
MovTab:Section({ Title = "Settings" })

-- NOTIFICATION: dùng Window:Notify trực tiếp để luôn hiện
-- dù NOTIFICATION = false (vì đây là thông báo về chính NOTIFICATION)
MovTab:Toggle({ Title = "NOTIFICATION", Value = true, Callback = function(v)
    NOTIFICATION = v
    Window:Notify({ Title = "NEBULA", Desc = "NOTIFICATION " .. (v and "ON" or "OFF"), Time = 2 })
end })

-- ============================================================
--  TAB 2 : ESP
-- ============================================================
local EspTab = Window:Tab({ Title = "ESP", Icon = "star" })

local Camera2     = workspace.CurrentCamera

local Settings = {
    MURDER        = false, MUR_TRACER   = false, MUR_RECT     = false,
    MUR_NAME      = false, MUR_DISTANCE = false, MUR_OUTLINE  = false,
    SHERIFF       = false, SHR_TRACER   = false, SHR_RECT     = false,
    SHR_NAME      = false, SHR_DISTANCE = false, SHR_OUTLINE  = false,
    INNOCENT      = false, INN_TRACER   = false, INN_RECT     = false,
    INN_NAME      = false, INN_DISTANCE = false, INN_OUTLINE  = false,
    GUN_ESP       = false, GUN_TRACER   = false, GUN_RECT     = false,
    GUN_NAME      = false, GUN_DISTANCE = false, GUN_OUTLINE  = false,
    ENEMY         = false, ENE_TRACER   = false, ENE_RECT     = false,
    ENE_NAME      = false, ENE_DISTANCE = false, ENE_OUTLINE  = false,
    TEAM          = false, TEAM_TRACER  = false, TEAM_RECT    = false,
    TEAM_NAME     = false, TEAM_DISTANCE= false, TEAM_OUTLINE = false,
}

local EspColors = {
    MUR = { Main = Color3.fromRGB(255,0,0),   Outline = Color3.fromRGB(255,0,0),   Fill = Color3.fromRGB(255,120,120) },
    SHR = { Main = Color3.fromRGB(0,170,255), Outline = Color3.fromRGB(0,170,255), Fill = Color3.fromRGB(170,220,255) },
    INN = { Main = Color3.fromRGB(0,255,0),   Outline = Color3.fromRGB(0,255,0),   Fill = Color3.fromRGB(170,255,170) },
    GUN = { Main = Color3.fromRGB(255,255,0), Outline = Color3.fromRGB(255,255,0), Fill = Color3.fromRGB(255,255,170) },
}

local EnemyColor = Color3.fromRGB(255, 0, 0)
local TeamColor  = Color3.fromRGB(0, 255, 0)

local MurObjects  = {} ; local MurHL  = {}
local ShrObjects  = {} ; local ShrHL  = {}
local InnObjects  = {} ; local InnHL  = {}
local EneObjects  = {} ; local EneHL  = {}
local TeamObjects = {} ; local TeamHL = {}
local GunEspObjects = {} ; local GunEspHL = nil

local espPlayerData = {}

task.spawn(function()
    local rs = game:GetService("ReplicatedStorage")
    local remotes   = rs:WaitForChild("Remotes", 10)   ; if not remotes   then return end
    local gameplay  = remotes:WaitForChild("Gameplay", 10) ; if not gameplay  then return end
    local dataEvent = gameplay:WaitForChild("PlayerDataChanged", 10) ; if not dataEvent then return end
    dataEvent.OnClientEvent:Connect(function(data)
        espPlayerData = data or {}
    end)
end)

local function IsAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

local function IsMurder(plr)
    if not IsAlive(plr) then return false end
    local char = plr.Character
    if char:FindFirstChild("Knife") then return true end
    if plr.Backpack:FindFirstChild("Knife") then return true end
    if espPlayerData[plr.Name] and espPlayerData[plr.Name].Role == "Murderer" then return true end
    return false
end

local function IsSheriff(plr)
    if not IsAlive(plr) then return false end
    local char = plr.Character
    if char:FindFirstChild("Gun") then return true end
    if plr.Backpack:FindFirstChild("Gun") then return true end
    if espPlayerData[plr.Name] and espPlayerData[plr.Name].Role == "Sheriff" then return true end
    return false
end

local function IsInnocent(plr)
    if not IsAlive(plr) then return false end
    if IsMurder(plr) or IsSheriff(plr) then return false end
    if espPlayerData[plr.Name] and espPlayerData[plr.Name].Role then
        return espPlayerData[plr.Name].Role == "Innocent"
    end
    return true
end

local function FindGunDrop2()
    local gunDrop = workspace:FindFirstChild("GunDrop", true)
    if not gunDrop then return nil end
    if gunDrop:IsA("BasePart") then return gunDrop end
    return gunDrop:FindFirstChild("Handle") or gunDrop:FindFirstChildWhichIsA("BasePart")
end

local function IsEnemy(plr)
    local char = plr.Character ; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if LocalPlayer.Team and plr.Team then return plr.Team ~= LocalPlayer.Team end
    if LocalPlayer.TeamColor and plr.TeamColor then return plr.TeamColor ~= LocalPlayer.TeamColor end
    return false
end

local function IsTeammate(plr)
    local char = plr.Character ; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if LocalPlayer.Team and plr.Team then return plr.Team == LocalPlayer.Team end
    if LocalPlayer.TeamColor and plr.TeamColor then return plr.TeamColor == LocalPlayer.TeamColor end
    return false
end

local function MakeDrawings()
    local t = {}
    local tracer = Drawing.new("Line") ; tracer.Thickness = 1 ; tracer.Visible = false ; t.Tracer = tracer
    local box = Drawing.new("Square")  ; box.Thickness = 1    ; box.Filled = false     ; box.Visible = false ; t.Box = box
    local text = Drawing.new("Text")   ; text.Size = 13       ; text.Center = true     ; text.Outline = true ; text.Visible = false ; t.Text = text
    return t
end

local function ClearDrawings(t)
    if not t then return end
    for _, v in pairs(t) do pcall(function() v:Remove() end) end
end

local function SafeHighlight(hlTable, key, char, outlineColor, fillColor)
    if hlTable[key] then
        if not hlTable[key].Parent or hlTable[key].Adornee ~= char then
            pcall(function() hlTable[key]:Destroy() end) ; hlTable[key] = nil
        end
    end
    if not hlTable[key] then
        local hl = Instance.new("Highlight")
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee   = char ; hl.Parent = game.CoreGui ; hlTable[key] = hl
    end
    local hl = hlTable[key]
    hl.OutlineColor        = outlineColor ; hl.FillColor           = fillColor
    hl.OutlineTransparency = 0            ; hl.FillTransparency    = 0.55
end

local function RemoveHighlight(hlTable, key)
    if hlTable[key] then pcall(function() hlTable[key]:Destroy() end) ; hlTable[key] = nil end
end

local function ClearPlayer(plr)
    ClearDrawings(MurObjects[plr])  ; MurObjects[plr]  = nil ; RemoveHighlight(MurHL,  plr)
    ClearDrawings(ShrObjects[plr])  ; ShrObjects[plr]  = nil ; RemoveHighlight(ShrHL,  plr)
    ClearDrawings(InnObjects[plr])  ; InnObjects[plr]  = nil ; RemoveHighlight(InnHL,  plr)
    ClearDrawings(EneObjects[plr])  ; EneObjects[plr]  = nil ; RemoveHighlight(EneHL,  plr)
    ClearDrawings(TeamObjects[plr]) ; TeamObjects[plr] = nil ; RemoveHighlight(TeamHL, plr)
end

local function ClearGunESP()
    ClearDrawings(GunEspObjects) ; GunEspObjects = {}
    if GunEspHL then pcall(function() GunEspHL:Destroy() end) ; GunEspHL = nil end
end

local function GetMyHRP2()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function RenderTarget(objs, hrpPos, color, tracer_on, rect_on, name_on, dist_on, label)
    local pos, onScreen = Camera2:WorldToViewportPoint(hrpPos)
    if onScreen then
        local myHRP = GetMyHRP2()
        local dist  = myHRP and math.floor((myHRP.Position - hrpPos).Magnitude) or 0
        local boxW  = math.clamp(1800 / pos.Z, 16, 40)
        local boxH  = boxW * 1.6
        local box   = objs.Box
        box.Visible  = rect_on ; box.Color = color
        box.Size     = Vector2.new(boxW, boxH)
        box.Position = Vector2.new(pos.X - boxW/2, pos.Y - boxH/2)
        local tracer = objs.Tracer
        tracer.Visible = tracer_on ; tracer.Color = color
        tracer.From = Vector2.new(Camera2.ViewportSize.X/2, Camera2.ViewportSize.Y)
        tracer.To   = Vector2.new(pos.X, pos.Y)
        local text = objs.Text
        if name_on and dist_on then
            text.Text = label .. " [m:" .. dist .. "]" ; text.Visible = true
        elseif name_on then
            text.Text = label ; text.Visible = true
        elseif dist_on then
            text.Text = "[m:" .. dist .. "]" ; text.Visible = true
        else
            text.Visible = false
        end
        text.Color = color ; text.Position = Vector2.new(pos.X, pos.Y - boxH / 1.2)
    else
        objs.Box.Visible = false ; objs.Tracer.Visible = false ; objs.Text.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    local s = Settings
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")

        if s.MURDER and IsMurder(plr) then
            if not hrp then ClearDrawings(MurObjects[plr]) ; MurObjects[plr] = nil ; RemoveHighlight(MurHL, plr) ; continue end
            if not MurObjects[plr] then MurObjects[plr] = MakeDrawings() end
            RenderTarget(MurObjects[plr], hrp.Position, EspColors.MUR.Main, s.MUR_TRACER, s.MUR_RECT, s.MUR_NAME, s.MUR_DISTANCE, plr.Name)
            if s.MUR_OUTLINE then SafeHighlight(MurHL, plr, char, EspColors.MUR.Outline, EspColors.MUR.Fill)
            else RemoveHighlight(MurHL, plr) end
        else ClearDrawings(MurObjects[plr]) ; MurObjects[plr] = nil ; RemoveHighlight(MurHL, plr) end

        if s.SHERIFF and IsSheriff(plr) then
            if not hrp then ClearDrawings(ShrObjects[plr]) ; ShrObjects[plr] = nil ; RemoveHighlight(ShrHL, plr) ; continue end
            if not ShrObjects[plr] then ShrObjects[plr] = MakeDrawings() end
            RenderTarget(ShrObjects[plr], hrp.Position, EspColors.SHR.Main, s.SHR_TRACER, s.SHR_RECT, s.SHR_NAME, s.SHR_DISTANCE, plr.Name)
            if s.SHR_OUTLINE then SafeHighlight(ShrHL, plr, char, EspColors.SHR.Outline, EspColors.SHR.Fill)
            else RemoveHighlight(ShrHL, plr) end
        else ClearDrawings(ShrObjects[plr]) ; ShrObjects[plr] = nil ; RemoveHighlight(ShrHL, plr) end

        if s.INNOCENT and IsInnocent(plr) then
            if not hrp then ClearDrawings(InnObjects[plr]) ; InnObjects[plr] = nil ; RemoveHighlight(InnHL, plr) ; continue end
            if not InnObjects[plr] then InnObjects[plr] = MakeDrawings() end
            RenderTarget(InnObjects[plr], hrp.Position, EspColors.INN.Main, s.INN_TRACER, s.INN_RECT, s.INN_NAME, s.INN_DISTANCE, plr.Name)
            if s.INN_OUTLINE then SafeHighlight(InnHL, plr, char, EspColors.INN.Outline, EspColors.INN.Fill)
            else RemoveHighlight(InnHL, plr) end
        else ClearDrawings(InnObjects[plr]) ; InnObjects[plr] = nil ; RemoveHighlight(InnHL, plr) end

        if s.ENEMY and IsEnemy(plr) then
            if not hrp then ClearDrawings(EneObjects[plr]) ; EneObjects[plr] = nil ; RemoveHighlight(EneHL, plr) ; continue end
            if not EneObjects[plr] then EneObjects[plr] = MakeDrawings() end
            local fill = Color3.new(math.min(EnemyColor.R+0.3,1), math.min(EnemyColor.G+0.3,1), math.min(EnemyColor.B+0.3,1))
            RenderTarget(EneObjects[plr], hrp.Position, EnemyColor, s.ENE_TRACER, s.ENE_RECT, s.ENE_NAME, s.ENE_DISTANCE, plr.Name)
            if s.ENE_OUTLINE then SafeHighlight(EneHL, plr, char, EnemyColor, fill)
            else RemoveHighlight(EneHL, plr) end
        else ClearDrawings(EneObjects[plr]) ; EneObjects[plr] = nil ; RemoveHighlight(EneHL, plr) end

        if s.TEAM and IsTeammate(plr) then
            if not hrp then ClearDrawings(TeamObjects[plr]) ; TeamObjects[plr] = nil ; RemoveHighlight(TeamHL, plr) ; continue end
            if not TeamObjects[plr] then TeamObjects[plr] = MakeDrawings() end
            local fill = Color3.new(math.min(TeamColor.R+0.3,1), math.min(TeamColor.G+0.3,1), math.min(TeamColor.B+0.3,1))
            RenderTarget(TeamObjects[plr], hrp.Position, TeamColor, s.TEAM_TRACER, s.TEAM_RECT, s.TEAM_NAME, s.TEAM_DISTANCE, plr.Name)
            if s.TEAM_OUTLINE then SafeHighlight(TeamHL, plr, char, TeamColor, fill)
            else RemoveHighlight(TeamHL, plr) end
        else ClearDrawings(TeamObjects[plr]) ; TeamObjects[plr] = nil ; RemoveHighlight(TeamHL, plr) end
    end

    if s.GUN_ESP then
        local gun = FindGunDrop2()
        if gun then
            if not GunEspObjects.Tracer then GunEspObjects = MakeDrawings() end
            if s.GUN_OUTLINE then
                if GunEspHL and (not GunEspHL.Parent or GunEspHL.Adornee ~= gun) then
                    pcall(function() GunEspHL:Destroy() end) ; GunEspHL = nil
                end
                if not GunEspHL then
                    local hl = Instance.new("Highlight")
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Adornee = gun ; hl.Parent = game.CoreGui ; GunEspHL = hl
                end
                GunEspHL.OutlineColor = EspColors.GUN.Outline ; GunEspHL.FillColor = EspColors.GUN.Fill
                GunEspHL.OutlineTransparency = 0              ; GunEspHL.FillTransparency = 0.55
            else
                if GunEspHL then pcall(function() GunEspHL:Destroy() end) ; GunEspHL = nil end
            end
            RenderTarget(GunEspObjects, gun.Position, EspColors.GUN.Main, s.GUN_TRACER, s.GUN_RECT, s.GUN_NAME, s.GUN_DISTANCE, "GUN DROPPED!")
        else
            ClearGunESP()
        end
    else
        ClearGunESP()
    end
end)

-- COIN ESP
local ESP_COIN = false
local COIN_HIT = false
local COIN_HIT_COLOR     = Color3.fromRGB(255, 215, 0)
local COIN_OUTLINE_COLOR = Color3.fromRGB(255, 165, 0)
local CoinData   = {}
local KnownCoins = {}
local DescAddedConn, DescRemovedConn

local function CreateCoinHitbox(coin)
    if CoinData[coin] then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = coin ; box.AlwaysOnTop = true ; box.ZIndex = 10
    box.Size = coin.Size + Vector3.new(0.1,0.1,0.1) ; box.Color3 = COIN_HIT_COLOR
    box.Transparency = 0.25 ; box.Parent = game.CoreGui
    local outline = Instance.new("SelectionBox")
    outline.Adornee = coin ; outline.LineThickness = 0.02
    outline.Color3 = COIN_OUTLINE_COLOR ; outline.SurfaceTransparency = 1 ; outline.Parent = game.CoreGui
    CoinData[coin] = { box = box, outline = outline }
end

local function RemoveCoinHitbox(coin)
    if CoinData[coin] then
        pcall(function() CoinData[coin].box:Destroy() end)
        pcall(function() CoinData[coin].outline:Destroy() end)
        CoinData[coin] = nil
    end
end

local function ClearAllCoinESP()
    for coin in pairs(CoinData) do RemoveCoinHitbox(coin) end
end

local function ApplyCoinHit(state)
    if state then for coin in pairs(KnownCoins) do CreateCoinHitbox(coin) end
    else ClearAllCoinESP() end
end

local function RegisterCoin(v)
    if v.Name == "Coin_Server" and v:IsA("BasePart") then
        KnownCoins[v] = true
        if ESP_COIN and COIN_HIT then CreateCoinHitbox(v) end
    end
end

local function StartCoinTracking()
    if DescAddedConn then return end
    for _, v in ipairs(workspace:GetDescendants()) do RegisterCoin(v) end
    DescAddedConn   = workspace.DescendantAdded:Connect(RegisterCoin)
    DescRemovedConn = workspace.DescendantRemoving:Connect(function(v)
        if KnownCoins[v] then KnownCoins[v] = nil ; RemoveCoinHitbox(v) end
    end)
end

local function StopCoinTracking()
    if DescAddedConn   then DescAddedConn:Disconnect()   ; DescAddedConn   = nil end
    if DescRemovedConn then DescRemovedConn:Disconnect() ; DescRemovedConn = nil end
    ClearAllCoinESP() ; KnownCoins = {}
end

Players.PlayerRemoving:Connect(ClearPlayer)
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        RemoveHighlight(MurHL, plr) ; RemoveHighlight(ShrHL, plr)
        RemoveHighlight(InnHL, plr) ; RemoveHighlight(EneHL, plr) ; RemoveHighlight(TeamHL, plr)
    end)
end)
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function()
            RemoveHighlight(MurHL, plr) ; RemoveHighlight(ShrHL, plr)
            RemoveHighlight(InnHL, plr) ; RemoveHighlight(EneHL, plr) ; RemoveHighlight(TeamHL, plr)
        end)
    end
end

-- ── UI ESP ───────────────────────────────────────────────────
local S = Settings

EspTab:Section({ Title = "Murderer ESP" })
EspTab:Toggle({ Title = "ESP MURDERER", Value = false, Callback = function(v) S.MURDER=v;       Notify("ESP MURDERER "..(v and "ON" or "OFF")) end })
EspTab:Toggle({ Title = "CHAMS",        Value = false, Callback = function(v) S.MUR_OUTLINE=v   end })
EspTab:Toggle({ Title = "TRACER",       Value = false, Callback = function(v) S.MUR_TRACER=v    end })
EspTab:Toggle({ Title = "RECTANGLE",    Value = false, Callback = function(v) S.MUR_RECT=v      end })
EspTab:Toggle({ Title = "NAME",         Value = false, Callback = function(v) S.MUR_NAME=v      end })
EspTab:Toggle({ Title = "DISTANCE",     Value = false, Callback = function(v) S.MUR_DISTANCE=v  end })

EspTab:Section({ Title = "Sheriff ESP" })
EspTab:Toggle({ Title = "ESP SHERIFF",  Value = false, Callback = function(v) S.SHERIFF=v;      Notify("ESP SHERIFF "..(v and "ON" or "OFF")) end })
EspTab:Toggle({ Title = "CHAMS",        Value = false, Callback = function(v) S.SHR_OUTLINE=v   end })
EspTab:Toggle({ Title = "TRACER",       Value = false, Callback = function(v) S.SHR_TRACER=v    end })
EspTab:Toggle({ Title = "RECTANGLE",    Value = false, Callback = function(v) S.SHR_RECT=v      end })
EspTab:Toggle({ Title = "NAME",         Value = false, Callback = function(v) S.SHR_NAME=v      end })
EspTab:Toggle({ Title = "DISTANCE",     Value = false, Callback = function(v) S.SHR_DISTANCE=v  end })

EspTab:Section({ Title = "Innocent ESP" })
EspTab:Toggle({ Title = "ESP INNOCENT", Value = false, Callback = function(v) S.INNOCENT=v;     Notify("ESP INNOCENT "..(v and "ON" or "OFF")) end })
EspTab:Toggle({ Title = "CHAMS",        Value = false, Callback = function(v) S.INN_OUTLINE=v   end })
EspTab:Toggle({ Title = "TRACER",       Value = false, Callback = function(v) S.INN_TRACER=v    end })
EspTab:Toggle({ Title = "RECTANGLE",    Value = false, Callback = function(v) S.INN_RECT=v      end })
EspTab:Toggle({ Title = "NAME",         Value = false, Callback = function(v) S.INN_NAME=v      end })
EspTab:Toggle({ Title = "DISTANCE",     Value = false, Callback = function(v) S.INN_DISTANCE=v  end })

EspTab:Section({ Title = "Gun ESP" })
EspTab:Toggle({ Title = "ESP GUN",      Value = false, Callback = function(v) S.GUN_ESP=v;      Notify("ESP GUN "..(v and "ON" or "OFF")) end })
EspTab:Toggle({ Title = "CHAMS",        Value = false, Callback = function(v) S.GUN_OUTLINE=v   end })
EspTab:Toggle({ Title = "TRACER",       Value = false, Callback = function(v) S.GUN_TRACER=v    end })
EspTab:Toggle({ Title = "RECTANGLE",    Value = false, Callback = function(v) S.GUN_RECT=v      end })
EspTab:Toggle({ Title = "TEXT",         Value = false, Callback = function(v) S.GUN_NAME=v      end })
EspTab:Toggle({ Title = "DISTANCE",     Value = false, Callback = function(v) S.GUN_DISTANCE=v  end })

EspTab:Section({ Title = "Coin ESP" })
EspTab:Toggle({ Title = "COIN ESP", Value = false, Callback = function(v)
    ESP_COIN = v
    if v then StartCoinTracking() ; if COIN_HIT then ApplyCoinHit(true) end
    else StopCoinTracking() end
    Notify("COIN ESP "..(v and "ON" or "OFF"))
end })
EspTab:Toggle({ Title = "HIT", Value = false, Callback = function(v)
    COIN_HIT = v ; if ESP_COIN then ApplyCoinHit(v) end
end })

EspTab:Section({ Title = "Enemy ESP" })
EspTab:Toggle({ Title = "ESP ENEMY",    Value = false, Callback = function(v) S.ENEMY=v;        Notify("ESP ENEMY "..(v and "ON" or "OFF")) end })
EspTab:Toggle({ Title = "CHAMS",        Value = false, Callback = function(v) S.ENE_OUTLINE=v   end })
EspTab:Toggle({ Title = "TRACER",       Value = false, Callback = function(v) S.ENE_TRACER=v    end })
EspTab:Toggle({ Title = "RECTANGLE",    Value = false, Callback = function(v) S.ENE_RECT=v      end })
EspTab:Toggle({ Title = "NAME",         Value = false, Callback = function(v) S.ENE_NAME=v      end })
EspTab:Toggle({ Title = "DISTANCE",     Value = false, Callback = function(v) S.ENE_DISTANCE=v  end })
EspTab:Dropdown({ Title = "ESP COLOR", List = {"RED","ORANGE","YELLOW","GREEN","CYAN","BLUE","PINK","WHITE"}, Value = "RED", Callback = function(opt)
    local colorMap = {
        RED    = Color3.fromRGB(255,0,0),   ORANGE = Color3.fromRGB(255,127,0),
        YELLOW = Color3.fromRGB(255,255,0), GREEN  = Color3.fromRGB(0,255,0),
        CYAN   = Color3.fromRGB(0,255,255), BLUE   = Color3.fromRGB(0,100,255),
        PINK   = Color3.fromRGB(255,0,200), WHITE  = Color3.fromRGB(255,255,255),
    }
    EnemyColor = colorMap[opt] or Color3.fromRGB(255,0,0)
    Notify("ENEMY COLOR: " .. opt)
end })

EspTab:Section({ Title = "Team ESP" })
EspTab:Toggle({ Title = "ESP TEAM",     Value = false, Callback = function(v) S.TEAM=v;         Notify("ESP TEAM "..(v and "ON" or "OFF")) end })
EspTab:Toggle({ Title = "CHAMS",        Value = false, Callback = function(v) S.TEAM_OUTLINE=v  end })
EspTab:Toggle({ Title = "TRACER",       Value = false, Callback = function(v) S.TEAM_TRACER=v   end })
EspTab:Toggle({ Title = "RECTANGLE",    Value = false, Callback = function(v) S.TEAM_RECT=v     end })
EspTab:Toggle({ Title = "NAME",         Value = false, Callback = function(v) S.TEAM_NAME=v     end })
EspTab:Toggle({ Title = "DISTANCE",     Value = false, Callback = function(v) S.TEAM_DISTANCE=v end })
EspTab:Dropdown({ Title = "ESP COLOR", List = {"RED","ORANGE","YELLOW","GREEN","CYAN","BLUE","PINK","WHITE"}, Value = "GREEN", Callback = function(opt)
    local colorMap = {
        RED    = Color3.fromRGB(255,0,0),   ORANGE = Color3.fromRGB(255,127,0),
        YELLOW = Color3.fromRGB(255,255,0), GREEN  = Color3.fromRGB(0,255,0),
        CYAN   = Color3.fromRGB(0,255,255), BLUE   = Color3.fromRGB(0,100,255),
        PINK   = Color3.fromRGB(255,0,200), WHITE  = Color3.fromRGB(255,255,255),
    }
    TeamColor = colorMap[opt] or Color3.fromRGB(0,255,0)
    Notify("TEAM COLOR: " .. opt)
end })

EspTab:Section({ Title = "Settings" })
EspTab:Toggle({ Title = "NOTIFICATION", Value = true, Callback = function(v)
    NOTIFICATION = v
    Window:Notify({ Title = "NEBULA", Desc = "NOTIFICATION "..(v and "ON" or "OFF"), Time = 2 })
end })

-- ============================================================
--  TAB 3 : GUN
-- ============================================================
local GunTab = Window:Tab({ Title = "GUN", Icon = "star" })

-- ── SECTION: SHOOT MURDERER ──────────────────────────────────
GunTab:Section({ Title = "Shoot Murderer" })

local offsetToPingMult  = 1
local AUTO_SHOOT_1      = false
local LOCKBUTTON_1      = false
local currentButtonSize_1 = 60
local currentShape_1    = "SQUARE"

local function findSheriffGun()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Gun") or (i.Character and i.Character:FindFirstChild("Gun")) then return i end
    end
    return nil
end

local function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do
        if i ~= LocalPlayer then
            if i.Backpack:FindFirstChild("Knife") or (i.Character and i.Character:FindFirstChild("Knife")) then return i end
        end
    end
    return nil
end

local function getPredictedPosition(player, shootOffset)
    local char2 = player.Character; if not char2 then return Vector3.new(0,0,0) end
    local hrp2  = char2:FindFirstChild("HumanoidRootPart") or char2:FindFirstChild("UpperTorso")
    local hum2  = char2:FindFirstChild("Humanoid")
    if not hrp2 or not hum2 then return Vector3.new(0,0,0) end
    local vel   = hrp2.AssemblyLinearVelocity
    local predicted = hrp2.Position
        + (vel * Vector3.new(0.75,0.5,0.75)) * (shootOffset/15)
        + hum2.MoveDirection * shootOffset
    local ping = LocalPlayer:GetNetworkPing() * 1000
    predicted  = predicted * (((ping) * ((offsetToPingMult-1)*0.01)) + 1)
    return predicted
end

local function shootMurder1()
    local shootOffset = 2.8
    if findSheriffGun() ~= LocalPlayer then return end
    local murderer = findMurderer(); if not murderer or not murderer.Character then return end
    if not LocalPlayer.Character:FindFirstChild("Gun") then
        local gun = LocalPlayer.Backpack:FindFirstChild("Gun")
        if gun then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(gun); task.wait(0.15)
        else return end
    end
    local predictedPos = getPredictedPosition(murderer, shootOffset)
    local rightHand = LocalPlayer.Character:FindFirstChild("RightHand") or LocalPlayer.Character:FindFirstChild("Right Arm")
    if not rightHand then return end
    local gunTool   = LocalPlayer.Character:WaitForChild("Gun")
    local shootRemote = gunTool:FindFirstChild("Shoot")
    if shootRemote then shootRemote:FireServer(CFrame.new(rightHand.Position), CFrame.new(predictedPos)) end
end

GunTab:Button({ Title = "SHOOT MURDERER", Callback = shootMurder1 })

local FloatGui1 = Instance.new("ScreenGui")
FloatGui1.Name = "FloatShootMurderer1"; FloatGui1.Parent = game.CoreGui; FloatGui1.Enabled = false

local FloatButton1 = Instance.new("TextButton")
FloatButton1.Position = UDim2.new(0.5,-200,0.65,0); FloatButton1.BackgroundColor3 = Color3.fromRGB(0,0,0); FloatButton1.BackgroundTransparency = 1
FloatButton1.Text = "SHOOT MURDERER"; FloatButton1.Font = Enum.Font.Gotham
FloatButton1.TextColor3 = Color3.fromRGB(0,0,0); FloatButton1.TextStrokeTransparency = 0.8
FloatButton1.Parent = FloatGui1

local corner1 = Instance.new("UICorner"); corner1.Parent = FloatButton1
local stroke1 = Instance.new("UIStroke")
stroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke1.Color = Color3.fromRGB(255,255,255)
stroke1.Thickness = 2; stroke1.Parent = FloatButton1

local function applyShape1(shape, size)
    if shape == "RECTANGLE" then
        FloatButton1.Size = UDim2.new(0, size*8, 0, size*2)
        corner1.CornerRadius = UDim.new(0, 16)
        FloatButton1.TextSize = math.clamp(size*0.55, 8, 60)
    elseif shape == "SQUARE" then
        FloatButton1.Size = UDim2.new(0, size*4, 0, size*4)
        corner1.CornerRadius = UDim.new(0, 8)
        FloatButton1.TextSize = math.clamp(size*0.4, 6, 50)
    elseif shape == "CIRCLE" then
        FloatButton1.Size = UDim2.new(0, size*3, 0, size*3)
        corner1.CornerRadius = UDim.new(0.5, 0)
        FloatButton1.TextSize = math.clamp(size*0.3, 5, 40)
    end
end
applyShape1(currentShape_1, currentButtonSize_1)

FloatButton1.MouseButton1Click:Connect(shootMurder1)

local dragging1, dragStart1, startPos1 = false, nil, nil
FloatButton1.InputBegan:Connect(function(input)
    if LOCKBUTTON_1 then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging1 = true; dragStart1 = input.Position; startPos1 = FloatButton1.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging1 and not LOCKBUTTON_1 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart1
        FloatButton1.Position = UDim2.new(startPos1.X.Scale, startPos1.X.Offset+d.X, startPos1.Y.Scale, startPos1.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging1 = false end
end)

GunTab:Toggle({ Title = "FLOAT SHOOTMURDERER BUTTON", Value = false, Callback = function(v)
    FloatGui1.Enabled = v; Notify(v and "FLOAT BUTTON ENABLE" or "FLOAT BUTTON DISABLED")
end })
GunTab:Toggle({ Title = "INVISIBLE SHOOT BUTTON", Value = false, Callback = function(v)
    FloatButton1.TextTransparency = v and 1 or 0; stroke1.Transparency = v and 1 or 0
    Notify(v and "BUTTON INVISIBLE" or "BUTTON UNINVISIBLE")
end })
GunTab:Slider({ Title = "SHOOT BUTTON SIZE", Min = 1, Max = 100, Value = 60, Callback = function(v)
    currentButtonSize_1 = v; applyShape1(currentShape_1, currentButtonSize_1)
end })
GunTab:Dropdown({ Title = "BUTTON SHAPE", List = {"RECTANGLE", "SQUARE", "CIRCLE"}, Value = "SQUARE", Callback = function(opt)
    currentShape_1 = opt
    applyShape1(currentShape_1, currentButtonSize_1)
    Notify("SHOOT SHAPE: " .. currentShape_1)
end })
GunTab:Toggle({ Title = "LOCK SHOOT BUTTON", Value = false, Callback = function(v)
    LOCKBUTTON_1 = v; Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
end })
GunTab:Toggle({ Title = "AUTO SHOOTMURDERER", Value = false, Callback = function(v)
    AUTO_SHOOT_1 = v; Notify(v and "AUTO SHOOT ON" or "AUTO SHOOT OFF")
end })

task.spawn(function()
    while true do
        if AUTO_SHOOT_1 then
            pcall(function()
                if findSheriffGun() == LocalPlayer then
                    local murderer = findMurderer()
                    if murderer and murderer.Character then
                        if not LocalPlayer.Character:FindFirstChild("Gun") then
                            local gun = LocalPlayer.Backpack:FindFirstChild("Gun")
                            if gun then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(gun); task.wait(0.1) end
                        end
                        local rightHand = LocalPlayer.Character:FindFirstChild("RightHand") or LocalPlayer.Character:FindFirstChild("Right Arm")
                        if rightHand then
                            local predictedPos = getPredictedPosition(murderer, 2.8)
                            local gunTool = LocalPlayer.Character:FindFirstChild("Gun")
                            if gunTool then
                                local shootRemote = gunTool:FindFirstChild("Shoot")
                                if shootRemote then shootRemote:FireServer(CFrame.new(rightHand.Position), CFrame.new(predictedPos)) end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.25)
    end
end)

-- ── SECTION: SHOOT MURDERER (UE) ────────────────────────────
GunTab:Section({ Title = "Shoot Murderer (UE)" })

local LOCKBUTTON_2      = false
local currentButtonSize_2 = 60
local currentShape_2    = "SQUARE"
local AUTO_SHOOT_2      = false

local function getPredictedPositionUE(player, shootOffset)
    local char2 = player.Character; if not char2 then return Vector3.new(0,0,0) end
    local hrp2  = char2:FindFirstChild("HumanoidRootPart") or char2:FindFirstChild("UpperTorso")
    local hum2  = char2:FindFirstChild("Humanoid")
    if not hrp2 or not hum2 then return Vector3.new(0,0,0) end
    local vel   = hrp2.AssemblyLinearVelocity
    local predicted = hrp2.Position
        + (vel * Vector3.new(0.75,0.5,0.75)) * (shootOffset/15)
        + hum2.MoveDirection * shootOffset
    local ping = LocalPlayer:GetNetworkPing() * 1000
    predicted  = predicted * (((ping) * ((offsetToPingMult-1)*0.01)) + 1)
    return predicted
end

local function shootMurderUE()
    local shootOffset = 2.8
    if findSheriffGun() ~= LocalPlayer then return end
    local murderer = findMurderer(); if not murderer or not murderer.Character then return end
    local char2 = LocalPlayer.Character; if not char2 then return end
    local hum2  = char2:FindFirstChildOfClass("Humanoid"); if not hum2 then return end
    if not char2:FindFirstChild("Gun") then
        local gun = LocalPlayer.Backpack:FindFirstChild("Gun")
        if gun then hum2:EquipTool(gun); task.wait(0.12) else return end
    end
    local predictedPos = getPredictedPositionUE(murderer, shootOffset)
    local rightHand = char2:FindFirstChild("RightHand") or char2:FindFirstChild("Right Arm"); if not rightHand then return end
    local gunTool   = char2:FindFirstChild("Gun"); if not gunTool then return end
    local shootRemote = gunTool:FindFirstChild("Shoot"); if not shootRemote then return end
    shootRemote:FireServer(CFrame.new(rightHand.Position), CFrame.new(predictedPos))
    task.wait(0.05); hum2:UnequipTools()
end

GunTab:Button({ Title = "SHOOT MURDERER (UE)", Callback = shootMurderUE })

local FloatGui2 = Instance.new("ScreenGui")
FloatGui2.Name = "FloatShootMurdererUE"; FloatGui2.ResetOnSpawn = false
FloatGui2.Parent = game.CoreGui; FloatGui2.Enabled = false

local ButtonFrame2 = Instance.new("Frame")
ButtonFrame2.Size = UDim2.new(0,400,0,100); ButtonFrame2.Position = UDim2.new(0.5,-200,0.65,0)
ButtonFrame2.BackgroundColor3 = Color3.fromRGB(0,0,0); ButtonFrame2.BackgroundTransparency = 1; ButtonFrame2.Active = true; ButtonFrame2.Parent = FloatGui2

local frameCorner2 = Instance.new("UICorner"); frameCorner2.CornerRadius = UDim.new(0,16); frameCorner2.Parent = ButtonFrame2
local frameStroke2 = Instance.new("UIStroke")
frameStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; frameStroke2.Color = Color3.fromRGB(255,255,255)
frameStroke2.Thickness = 2; frameStroke2.Parent = ButtonFrame2

local FloatButton2 = Instance.new("TextButton")
FloatButton2.Size = UDim2.new(1,0,1,0); FloatButton2.BackgroundColor3 = Color3.fromRGB(0,0,0); FloatButton2.BackgroundTransparency = 1
FloatButton2.Text = "SHOOT MURDERER"; FloatButton2.Font = Enum.Font.Gotham
FloatButton2.TextColor3 = Color3.fromRGB(0,0,0); FloatButton2.TextStrokeTransparency = 0.8
FloatButton2.Active = false; FloatButton2.Parent = ButtonFrame2

FloatButton2.MouseButton1Click:Connect(shootMurderUE)

local function applyShape2(shape, size)
    if shape == "RECTANGLE" then
        ButtonFrame2.Size = UDim2.new(0, size*8, 0, size*2)
        frameCorner2.CornerRadius = UDim.new(0, 16)
        FloatButton2.TextSize = math.clamp(size*0.55, 8, 60)
    elseif shape == "SQUARE" then
        ButtonFrame2.Size = UDim2.new(0, size*4, 0, size*4)
        frameCorner2.CornerRadius = UDim.new(0, 8)
        FloatButton2.TextSize = math.clamp(size*0.4, 6, 50)
    elseif shape == "CIRCLE" then
        ButtonFrame2.Size = UDim2.new(0, size*3, 0, size*3)
        frameCorner2.CornerRadius = UDim.new(0.5, 0)
        FloatButton2.TextSize = math.clamp(size*0.3, 5, 40)
    end
end
applyShape2(currentShape_2, currentButtonSize_2)

local dragging2, dragStart2, startPos2 = false, nil, nil
ButtonFrame2.InputBegan:Connect(function(input)
    if LOCKBUTTON_2 then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging2 = true; dragStart2 = input.Position; startPos2 = ButtonFrame2.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging2 and not LOCKBUTTON_2 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart2
        ButtonFrame2.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset+d.X, startPos2.Y.Scale, startPos2.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging2 = false end
end)

GunTab:Toggle({ Title = "FLOAT SHOOTMURDERER (UE) BUTTON", Value = false, Callback = function(v)
    FloatGui2.Enabled = v; Notify(v and "FLOAT BUTTON ON" or "FLOAT BUTTON OFF")
end })
GunTab:Toggle({ Title = "INVISIBLE UE BUTTON", Value = false, Callback = function(v)
    FloatButton2.TextTransparency = v and 1 or 0; frameStroke2.Transparency = v and 1 or 0
    Notify(v and "BUTTON INVISIBLE" or "BUTTON UNINVISIBLE")
end })
GunTab:Slider({ Title = "UE BUTTON SIZE", Min = 1, Max = 100, Value = 60, Callback = function(v)
    currentButtonSize_2 = v; applyShape2(currentShape_2, currentButtonSize_2)
end })
GunTab:Dropdown({ Title = "BUTTON SHAPE", List = {"RECTANGLE", "SQUARE", "CIRCLE"}, Value = "SQUARE", Callback = function(opt)
    currentShape_2 = opt
    applyShape2(currentShape_2, currentButtonSize_2)
    Notify("UE SHAPE: " .. currentShape_2)
end })
GunTab:Toggle({ Title = "LOCK UE BUTTON", Value = false, Callback = function(v)
    LOCKBUTTON_2 = v; Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
end })
GunTab:Toggle({ Title = "AUTO SHOOTMURDERER (UE)", Value = false, Callback = function(v)
    AUTO_SHOOT_2 = v; Notify(v and "AUTO SHOOT ON" or "AUTO SHOOT OFF")
end })

task.spawn(function()
    while true do
        if AUTO_SHOOT_2 then
            pcall(function()
                if findSheriffGun() ~= LocalPlayer then return end
                local murderer = findMurderer(); if not murderer or not murderer.Character then return end
                local char2 = LocalPlayer.Character; if not char2 then return end
                local hum2 = char2:FindFirstChildOfClass("Humanoid"); if not hum2 then return end
                if not char2:FindFirstChild("Gun") then
                    local gun = LocalPlayer.Backpack:FindFirstChild("Gun")
                    if gun then hum2:EquipTool(gun); task.wait(0.12) else return end
                end
                local predictedPos = getPredictedPositionUE(murderer, 2.8)
                local rightHand = char2:FindFirstChild("RightHand") or char2:FindFirstChild("Right Arm"); if not rightHand then return end
                local gunTool = char2:FindFirstChild("Gun"); if not gunTool then return end
                local shootRemote = gunTool:FindFirstChild("Shoot"); if not shootRemote then return end
                shootRemote:FireServer(CFrame.new(rightHand.Position), CFrame.new(predictedPos))
            end)
        end
        task.wait(0.25)
    end
end)

-- ── SECTION: GRAB GUN ───────────────────────────────────────
GunTab:Section({ Title = "Grab Gun" })

local GrabGunRunning   = false
local LOCKED_GRAB      = false
local grabCurrentSize  = 18
local grabCurrentShape = "SQUARE"
local AUTO_GRAB_GUN    = false

local function FindDroppedGun()
    local gunDrop = workspace:FindFirstChild("GunDrop", true)
    if gunDrop then
        return gunDrop:IsA("BasePart") and gunDrop
            or gunDrop:FindFirstChild("Handle")
            or gunDrop:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function GrabGun()
    if GrabGunRunning then return end
    GrabGunRunning = true
    local char2 = LocalPlayer.Character
    local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
    if not hrp2 then GrabGunRunning = false; return end
    local gunPart = FindDroppedGun()
    if not gunPart then GrabGunRunning = false; return end
    local oldCFrame = hrp2.CFrame
    hrp2.CFrame = gunPart.CFrame * CFrame.new(0,0,-1)
    task.wait(0.12); hrp2.CFrame = oldCFrame
    GrabGunRunning = false
end

GunTab:Button({ Title = "GRAB GUN", Callback = GrabGun })

local GrabGui = Instance.new("ScreenGui")
GrabGui.Name = "FloatGrabGunGui"; GrabGui.Parent = game.CoreGui; GrabGui.Enabled = false

local GrabBtn = Instance.new("TextButton")
GrabBtn.Position = UDim2.new(0.5,-100,0.65,0); GrabBtn.Text = "GRAB GUN"
GrabBtn.Font = Enum.Font.Gotham; GrabBtn.TextColor3 = Color3.fromRGB(0,0,0)
GrabBtn.TextStrokeTransparency = 0.8; GrabBtn.BackgroundColor3 = Color3.fromRGB(0,0,0); GrabBtn.BackgroundTransparency = 1; GrabBtn.Parent = GrabGui

local cornerGrab = Instance.new("UICorner"); cornerGrab.Parent = GrabBtn
local strokeGrab = Instance.new("UIStroke")
strokeGrab.Parent = GrabBtn; strokeGrab.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
strokeGrab.Color = Color3.fromRGB(255,255,255); strokeGrab.Thickness = 2

local function applyGrabShape(shape, size)
    if shape == "RECTANGLE" then
        GrabBtn.Size = UDim2.new(0, size*8, 0, size*2)
        cornerGrab.CornerRadius = UDim.new(0, 16)
        GrabBtn.TextSize = math.clamp(size*0.55, 8, 60)
    elseif shape == "SQUARE" then
        GrabBtn.Size = UDim2.new(0, size*4, 0, size*4)
        cornerGrab.CornerRadius = UDim.new(0, 8)
        GrabBtn.TextSize = math.clamp(size*0.4, 6, 50)
    elseif shape == "CIRCLE" then
        GrabBtn.Size = UDim2.new(0, size*3, 0, size*3)
        cornerGrab.CornerRadius = UDim.new(0.5, 0)
        GrabBtn.TextSize = math.clamp(size*0.3, 5, 40)
    end
end
applyGrabShape(grabCurrentShape, grabCurrentSize)

GrabBtn.MouseButton1Click:Connect(GrabGun)

local draggingGrab, dragStartGrab, startPosGrab = false, nil, nil
GrabBtn.InputBegan:Connect(function(input)
    if LOCKED_GRAB then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingGrab = true; dragStartGrab = input.Position; startPosGrab = GrabBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingGrab and not LOCKED_GRAB and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStartGrab
        GrabBtn.Position = UDim2.new(startPosGrab.X.Scale, startPosGrab.X.Offset+d.X, startPosGrab.Y.Scale, startPosGrab.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingGrab = false end
end)

GunTab:Toggle({ Title = "FLOAT GRAB GUN BUTTON", Value = false, Callback = function(v)
    GrabGui.Enabled = v; Notify(v and "FLOAT BUTTON ENABLED" or "FLOAT BUTTON DISABLED")
end })

GunTab:Section({ Title = "Grab Gun Button Settings" })

GunTab:Toggle({ Title = "INVISIBLE GRAB BUTTON", Value = false, Callback = function(v)
    GrabBtn.TextTransparency = v and 1 or 0; strokeGrab.Transparency = v and 1 or 0
    Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
end })
GunTab:Slider({ Title = "GRAB BUTTON SIZE", Min = 1, Max = 100, Value = 18, Callback = function(v)
    grabCurrentSize = v; applyGrabShape(grabCurrentShape, grabCurrentSize)
end })
GunTab:Dropdown({ Title = "BUTTON SHAPE", List = {"RECTANGLE", "SQUARE", "CIRCLE"}, Value = "SQUARE", Callback = function(opt)
    grabCurrentShape = opt
    applyGrabShape(grabCurrentShape, grabCurrentSize)
    Notify("GRAB SHAPE: " .. grabCurrentShape)
end })
GunTab:Toggle({ Title = "LOCK GRAB BUTTON", Value = false, Callback = function(v)
    LOCKED_GRAB = v; Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
end })
GunTab:Toggle({ Title = "AUTO GRAB GUN", Value = false, Callback = function(v)
    AUTO_GRAB_GUN = v; Notify(v and "AUTO GRAB ENABLED" or "AUTO GRAB DISABLED")
end })

task.spawn(function()
    while true do
        if AUTO_GRAB_GUN then
            pcall(function()
                local char2 = LocalPlayer.Character
                local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
                if not hrp2 then return end
                local gunPart = FindDroppedGun(); if not gunPart then return end
                local oldCFrame = hrp2.CFrame
                hrp2.CFrame = gunPart.CFrame * CFrame.new(0,0,-1)
                task.wait(0.12); hrp2.CFrame = oldCFrame
            end)
        end
        task.wait(0.35)
    end
end)

-- ── SECTION: STEAL GUN ──────────────────────────────────────
GunTab:Section({ Title = "Steal Gun" })

local LockFlingBtn       = false
local flingCurrentSize   = 18
local flingCurrentShape  = "SQUARE"
local AUTO_STEAL_GUN     = false

local function FindSheriffFling()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then
                return p
            end
        end
    end
    return nil
end

local function StrongFlingPlayer(TargetPlayer)
    if not TargetPlayer or TargetPlayer == LocalPlayer then return end
    if not TargetPlayer.Character or not LocalPlayer.Character then return end
    local Character = LocalPlayer.Character
    local Humanoid2 = Character:FindFirstChildOfClass("Humanoid")
    local RootPart  = Character:FindFirstChild("HumanoidRootPart")
    local TRootPart = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid2 or not RootPart or not TRootPart then return end
    local OldCFrame = RootPart.CFrame
    local BV = Instance.new("BodyVelocity")
    BV.MaxForce = Vector3.new(9e9,9e9,9e9); BV.Velocity = Vector3.new(99999,99999,99999)
    BV.P = 9e9; BV.Parent = RootPart
    local BG = Instance.new("BodyAngularVelocity")
    BG.MaxTorque = Vector3.new(9e9,9e9,9e9); BG.AngularVelocity = Vector3.new(99999,99999,99999)
    BG.P = 9e9; BG.Parent = RootPart
    Humanoid2:ChangeState(Enum.HumanoidStateType.Physics); Humanoid2.AutoRotate = false
    local start = tick()
    repeat
        if not TRootPart.Parent then break end
        RootPart.CFrame = TRootPart.CFrame * CFrame.new(0,-1.5,0) * CFrame.Angles(
            math.rad(math.random(-360,360)), math.rad(math.random(-360,360)), math.rad(math.random(-360,360))
        )
        RunService.Heartbeat:Wait()
    until TRootPart.AssemblyLinearVelocity.Magnitude > 300 or tick()-start > 2 or Humanoid2.Health <= 0
    BV:Destroy(); BG:Destroy()
    RootPart.AssemblyLinearVelocity = Vector3.zero; RootPart.AssemblyAngularVelocity = Vector3.zero
    RootPart.CFrame = OldCFrame
    Humanoid2:ChangeState(Enum.HumanoidStateType.GettingUp)
    task.wait(0.1); Humanoid2:ChangeState(Enum.HumanoidStateType.Running)
    Humanoid2.AutoRotate = true; workspace.CurrentCamera.CameraSubject = Humanoid2
end

GunTab:Button({ Title = "STEAL GUN", Callback = function()
    local sheriff = FindSheriffFling()
    if sheriff then StrongFlingPlayer(sheriff) end
end })

local FlingGui = Instance.new("ScreenGui")
FlingGui.Name = "StealGunFloatingGui"; FlingGui.Parent = game.CoreGui
FlingGui.Enabled = false; FlingGui.ResetOnSpawn = false

local FlingBtn = Instance.new("TextButton")
FlingBtn.Size = UDim2.new(0,200,0,50); FlingBtn.Position = UDim2.new(0.5,-100,0.6,0)
FlingBtn.BackgroundColor3 = Color3.fromRGB(0,0,0); FlingBtn.BackgroundTransparency = 1; FlingBtn.Text = "STEAL GUN"
FlingBtn.Font = Enum.Font.Gotham; FlingBtn.TextSize = 18
FlingBtn.TextColor3 = Color3.fromRGB(0,0,0); FlingBtn.TextStrokeTransparency = 0.8
FlingBtn.Parent = FlingGui

local flingCorner = Instance.new("UICorner", FlingBtn); flingCorner.CornerRadius = UDim.new(0,12)
local flingStroke = Instance.new("UIStroke")
flingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
flingStroke.Color = Color3.fromRGB(255,255,255); flingStroke.Thickness = 2; flingStroke.Parent = FlingBtn

local function applyFlingShape(shape, size)
    if shape == "RECTANGLE" then
        FlingBtn.Size = UDim2.new(0, size*8, 0, size*2)
        flingCorner.CornerRadius = UDim.new(0, 16)
        FlingBtn.TextSize = math.clamp(size*0.55, 8, 60)
    elseif shape == "SQUARE" then
        FlingBtn.Size = UDim2.new(0, size*4, 0, size*4)
        flingCorner.CornerRadius = UDim.new(0, 8)
        FlingBtn.TextSize = math.clamp(size*0.4, 6, 50)
    elseif shape == "CIRCLE" then
        FlingBtn.Size = UDim2.new(0, size*3, 0, size*3)
        flingCorner.CornerRadius = UDim.new(0.5, 0)
        FlingBtn.TextSize = math.clamp(size*0.3, 5, 40)
    end
end
applyFlingShape(flingCurrentShape, flingCurrentSize)

FlingBtn.MouseButton1Click:Connect(function()
    local sheriff = FindSheriffFling(); if sheriff then StrongFlingPlayer(sheriff) end
end)

local flDragging, flDragStart, flStartPos = false, nil, nil
FlingBtn.InputBegan:Connect(function(input)
    if LockFlingBtn then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        flDragging = true; flDragStart = input.Position; flStartPos = FlingBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if LockFlingBtn then return end
    if flDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - flDragStart
        FlingBtn.Position = UDim2.new(flStartPos.X.Scale, flStartPos.X.Offset+d.X, flStartPos.Y.Scale, flStartPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then flDragging = false end
end)

GunTab:Toggle({ Title = "FLOAT STEAL GUN BUTTON", Value = false, Callback = function(v)
    FlingGui.Enabled = v; Notify(v and "FLOAT BUTTON ENABLED" or "FLOAT BUTTON DISABLED")
end })
GunTab:Toggle({ Title = "INVISIBLE STEAL GUN BUTTON", Value = false, Callback = function(v)
    FlingBtn.TextTransparency = v and 1 or 0; flingStroke.Transparency = v and 1 or 0
    Notify(v and "BUTTON INVISIBLE" or "BUTTON VISIBLE")
end })
GunTab:Slider({ Title = "STEAL GUN BUTTON SIZE", Min = 1, Max = 100, Value = 18, Callback = function(v)
    flingCurrentSize = v; applyFlingShape(flingCurrentShape, flingCurrentSize)
end })
GunTab:Dropdown({ Title = "BUTTON SHAPE", List = {"RECTANGLE", "SQUARE", "CIRCLE"}, Value = "SQUARE", Callback = function(opt)
    flingCurrentShape = opt
    applyFlingShape(flingCurrentShape, flingCurrentSize)
    Notify("STEAL SHAPE: " .. flingCurrentShape)
end })
GunTab:Toggle({ Title = "LOCK STEAL GUN BUTTON", Value = false, Callback = function(v)
    LockFlingBtn = v; Notify(v and "BUTTON LOCKED" or "BUTTON UNLOCKED")
end })
GunTab:Toggle({ Title = "AUTO STEAL GUN", Value = false, Callback = function(v)
    AUTO_STEAL_GUN = v; Notify(v and "AUTO STEAL GUN ENABLED" or "AUTO STEAL GUN DISABLED")
end })

task.spawn(function()
    while true do
        if AUTO_STEAL_GUN then
            pcall(function()
                local sheriff = FindSheriffFling(); if sheriff then StrongFlingPlayer(sheriff) end
            end)
        end
        task.wait(1)
    end
end)

-- ── SECTION: SETTINGS (Gun tab) ─────────────────────────────
GunTab:Section({ Title = "Settings" })

GunTab:Toggle({ Title = "NOTIFICATION", Value = true, Callback = function(v)
    NOTIFICATION = v
    Window:Notify({ Title = "NEBULA", Desc = "NOTIFICATION " .. (v and "ON" or "OFF"), Time = 2 })
end })

-- ── LOADED NOTIFY ────────────────────────────────────────────
Window:Notify({
    Title = "NEBULA",
    Desc  = "Script Loaded Successfully",
    Time  = 4
})
