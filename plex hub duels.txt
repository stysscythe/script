-- Plexhub Duel V4 

-- Ragdoll TP

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- --- CONFIG & PURPLE/BLUE THEME ---
local COLORS = {
    Background = Color3.fromRGB(10, 15, 35), -- Dark blue background
    ButtonPurple = Color3.fromRGB(120, 40, 180), -- Purple
    ButtonBlue = Color3.fromRGB(40, 80, 200), -- Blue
    ButtonHoverPurple = Color3.fromRGB(150, 60, 220), -- Lighter purple
    ButtonHoverBlue = Color3.fromRGB(60, 100, 240), -- Lighter blue
    TopBarBlue = Color3.fromRGB(30, 60, 150), -- Medium blue
    TextWhite = Color3.fromRGB(255, 255, 255),
    StatusRed = Color3.fromRGB(255, 95, 87),
    StatusGreen = Color3.fromRGB(40, 200, 64)
}

-- --- TP COORDINATES ---
local finalPos1 = Vector3.new(-483.59, -5.04, 104.24)
local finalPos2 = Vector3.new(-483.51, -5.10, 18.89)
local checkpointA = Vector3.new(-472.60, -7.00, 57.52)
local checkpointB1 = Vector3.new(-472.65, -7.00, 95.69)
local checkpointB2 = Vector3.new(-471.76, -7.00, 26.22)

-- --- STATE ---
local autoTpLeft = false
local autoTpRight = false
local isTeleporting = false
local hasRecovered = true -- Tracks if player stopped ragdolling since last TP

-- --- UI SETUP ---
local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
sg.Name = "PlexhubRagdollTP"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(0, 260, 0, 190)
Shadow.Position = UDim2.new(0.5, -125, 0.5, -90)
Shadow.BackgroundTransparency = 1
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = sg

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 250, 0, 180)
Main.Position = UDim2.new(0.5, -125, 0.5, -90)
Main.BackgroundColor3 = COLORS.Background
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 18)

-- Blue to Purple tweening stroke
local mStroke = Instance.new("UIStroke", Main)
mStroke.Thickness = 2.5
mStroke.Transparency = 0

local strokeTween
local blueToPurple = true

local function updateStrokeColor()
    local targetColor = blueToPurple and COLORS.ButtonBlue or COLORS.ButtonPurple
    strokeTween = TweenService:Create(mStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = targetColor})
    strokeTween:Play()
    blueToPurple = not blueToPurple
end

updateStrokeColor()
strokeTween.Completed:Connect(updateStrokeColor)

-- Top bar
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1,0,0,45)
TopBar.BackgroundColor3 = COLORS.TopBarBlue
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 18)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "Plexhub Ragdoll TP"
Title.TextColor3 = COLORS.TextWhite
Title.Font = Enum.Font.Bangers
Title.TextSize = 25
Title.BackgroundTransparency = 1

-- --- DRAGGING ---
local function makeNormalDrag(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = gui.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end
makeNormalDrag(Main)

-- --- BUTTON CREATOR ---
local function createButton(posY, text, isPurple)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.85, 0, 0, 45)
    btn.Position = UDim2.new(0.075, 0, 0, posY)
    btn.BackgroundColor3 = isPurple and COLORS.ButtonPurple or COLORS.ButtonBlue
    btn.Text = text
    btn.TextColor3 = COLORS.TextWhite
    btn.Font = Enum.Font.Bangers  -- Changed to Bangers
    btn.TextSize = 18  -- Slightly larger for Bangers font
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(1, -20, 0.5, -4)
    dot.BackgroundColor3 = COLORS.StatusRed
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    -- Hover effects
    local hoverColor = isPurple and COLORS.ButtonHoverPurple or COLORS.ButtonHoverBlue
    btn.MouseEnter:Connect(function() 
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play() 
    end)
    btn.MouseLeave:Connect(function() 
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = btn.BackgroundColor3}):Play() 
    end)
    
    return btn, dot
end

local leftBtn, leftDot = createButton(55, "AUTO TP LEFT", true) -- Purple
local rightBtn, rightDot = createButton(110, "AUTO TP RIGHT", false) -- Blue

-- --- CORE LOGIC ---

local function move(pos)
    local char = LocalPlayer.Character
    if char then
        char:PivotTo(CFrame.new(pos))
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end
    end
end

local function executeTpSequence(side)
    isTeleporting = true
    hasRecovered = false -- Block further TPs until character is standing again
    
    local targetB = (side == "Left") and checkpointB1 or checkpointB2
    local targetFinal = (side == "Left") and finalPos1 or finalPos2
    
    move(checkpointA)
    task.wait(0.12)
    move(targetB)
    task.wait(0.12)
    move(targetFinal)
    
    isTeleporting = false
end

-- Detection Loop
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    
    if hum then
        local state = hum:GetState()
        local isRagdoll = (state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown)
        
        -- Reset recovery status if standing up
        if not isRagdoll then
            hasRecovered = true
        end
        
        -- Only TP if: Button is on, not currently TPing, and character had recovered since last hit
        if not isTeleporting and hasRecovered and isRagdoll then
            if autoTpLeft then
                executeTpSequence("Left")
            elseif autoTpRight then
                executeTpSequence("Right")
            end
        end
    end
end)

-- --- UI INTERACTIONS ---
leftBtn.MouseButton1Click:Connect(function()
    autoTpLeft = not autoTpLeft
    if autoTpLeft then autoTpRight = false end 
    leftDot.BackgroundColor3 = autoTpLeft and COLORS.StatusGreen or COLORS.StatusRed
    rightDot.BackgroundColor3 = autoTpRight and COLORS.StatusGreen or COLORS.StatusRed
    
    -- Visual feedback when active
    if autoTpLeft then
        TweenService:Create(leftBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.ButtonPurple}):Play()
    end
end)

rightBtn.MouseButton1Click:Connect(function()
    autoTpRight = not autoTpRight
    if autoTpRight then autoTpLeft = false end
    rightDot.BackgroundColor3 = autoTpRight and COLORS.StatusGreen or COLORS.StatusRed
    leftDot.BackgroundColor3 = autoTpLeft and COLORS.StatusGreen or COLORS.StatusRed
    
    -- Visual feedback when active
    if autoTpRight then
        TweenService:Create(rightBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.ButtonBlue}):Play()
    end
end)

-- Cleanup
sg.Destroying:Connect(function()
    if strokeTween then
        strokeTween:Cancel()
    end
end)

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function()
    autoTpLeft = false
    autoTpRight = false
    isTeleporting = false
    hasRecovered = true
    
    leftDot.BackgroundColor3 = COLORS.StatusRed
    rightDot.BackgroundColor3 = COLORS.StatusRed
end)

print("Plexhub Ragdoll TP Loaded.")




-- Auto Duel

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player           = Players.LocalPlayer

-- Color definitions (purple/blue theme)
local COLORS = {
    Background = Color3.fromRGB(10, 15, 35), -- Dark blue background
    ButtonPurple = Color3.fromRGB(120, 40, 180), -- Purple
    ButtonBlue = Color3.fromRGB(40, 80, 200), -- Blue
    ButtonHoverPurple = Color3.fromRGB(150, 60, 220), -- Lighter purple
    ButtonHoverBlue = Color3.fromRGB(60, 100, 240), -- Lighter blue
    ButtonActivePurple = Color3.fromRGB(160, 80, 220), -- Active purple
    ButtonActiveBlue = Color3.fromRGB(80, 120, 240), -- Active blue
    TopBarBlue = Color3.fromRGB(30, 60, 150), -- Medium blue
    TextWhite = Color3.fromRGB(255, 255, 255),
    SliderPurple1 = Color3.fromRGB(180, 120, 255), -- Light purple
    SliderPurple2 = Color3.fromRGB(140, 80, 220), -- Medium purple
    SliderPurple3 = Color3.fromRGB(100, 40, 180), -- Dark purple
}

local Config = {
    ForwardSpeed = 59,
    ReturnSpeed  = 28,
}

local POSITION_L1     = Vector3.new(-476.48, -6.28,  92.73)
local POSITION_LEND   = Vector3.new(-483.12, -4.95,  94.80)
local POSITION_LFINAL = Vector3.new(-473.38, -8.40,  22.34)

local POSITION_R1     = Vector3.new(-476.16, -6.52,  25.62)
local POSITION_REND   = Vector3.new(-483.04, -5.09,  23.14)
local POSITION_RFINAL = Vector3.new(-476.17, -7.91, 97.91)

-- Window state
local isMinimized = false
local originalSize = UDim2.new(0, 260, 0, 280) -- Made larger
local minimizedSize = UDim2.new(0, 260, 0, 45) -- Taller minimized bar for better spacing

local function getHRP()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local AutoLeftEnabled = false
local autoLeftPhase   = 1
local autoLeftConn    = nil

local function stopAutoLeft()
    if autoLeftConn then autoLeftConn:Disconnect(); autoLeftConn = nil end
    autoLeftPhase = 1
    local hum = getHum()
    if hum then hum:Move(Vector3.zero, false) end
end

local function startAutoLeft()
    if autoLeftConn then autoLeftConn:Disconnect() end
    autoLeftPhase = 1

    autoLeftConn = RunService.Heartbeat:Connect(function()
        if not AutoLeftEnabled then return end
        local h, hum = getHRP(), getHum()
        if not h or not hum then return end

        if autoLeftPhase == 1 then
            local d = Vector3.new(POSITION_L1.X - h.Position.X, 0, POSITION_L1.Z - h.Position.Z)
            if d.Magnitude < 1 then autoLeftPhase = 2; return end
            local md = d.Unit
            hum:Move(md, false)
            h.AssemblyLinearVelocity = Vector3.new(md.X * Config.ForwardSpeed, h.AssemblyLinearVelocity.Y, md.Z * Config.ForwardSpeed)

        elseif autoLeftPhase == 2 then
            local d = Vector3.new(POSITION_LEND.X - h.Position.X, 0, POSITION_LEND.Z - h.Position.Z)
            if d.Magnitude < 1 then
                autoLeftPhase = 0
                hum:Move(Vector3.zero, false)
                h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                task.delay(0.2, function()
                    if AutoLeftEnabled then autoLeftPhase = 3 end
                end)
                return
            end
            local md = d.Unit
            hum:Move(md, false)
            h.AssemblyLinearVelocity = Vector3.new(md.X * Config.ForwardSpeed, h.AssemblyLinearVelocity.Y, md.Z * Config.ForwardSpeed)

        elseif autoLeftPhase == 0 then
            return

        elseif autoLeftPhase == 3 then
            local d = Vector3.new(POSITION_L1.X - h.Position.X, 0, POSITION_L1.Z - h.Position.Z)
            if d.Magnitude < 1 then autoLeftPhase = 4; return end
            local md = d.Unit
            hum:Move(md, false)
            h.AssemblyLinearVelocity = Vector3.new(md.X * Config.ReturnSpeed, h.AssemblyLinearVelocity.Y, md.Z * Config.ReturnSpeed)

        elseif autoLeftPhase == 4 then
            local d = Vector3.new(POSITION_LFINAL.X - h.Position.X, 0, POSITION_LFINAL.Z - h.Position.Z)
            if d.Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                AutoLeftEnabled = false
                stopAutoLeft()
                if _G._updateMiniLeft then _G._updateMiniLeft() end
                return
            end
            local md = d.Unit
            hum:Move(md, false)
            h.AssemblyLinearVelocity = Vector3.new(md.X * Config.ReturnSpeed, h.AssemblyLinearVelocity.Y, md.Z * Config.ReturnSpeed)
        end
    end)
end

local AutoRightEnabled = false
local autoRightPhase   = 1
local autoRightConn    = nil

local function stopAutoRight()
    if autoRightConn then autoRightConn:Disconnect(); autoRightConn = nil end
    autoRightPhase = 1
    local hum = getHum()
    if hum then hum:Move(Vector3.zero, false) end
end

local function startAutoRight()
    if autoRightConn then autoRightConn:Disconnect() end
    autoRightPhase = 1

    autoRightConn = RunService.Heartbeat:Connect(function()
        if not AutoRightEnabled then return end
        local h, hum = getHRP(), getHum()
        if not h or not hum then return end

        if autoRightPhase == 1 then
            local d = Vector3.new(POSITION_R1.X - h.Position.X, 0, POSITION_R1.Z - h.Position.Z)
            if d.Magnitude < 1 then autoRightPhase = 2; return end
            local md = d.Unit
            hum:Move(md, false)
            h.AssemblyLinearVelocity = Vector3.new(md.X * Config.ForwardSpeed, h.AssemblyLinearVelocity.Y, md.Z * Config.ForwardSpeed)

        elseif autoRightPhase == 2 then
            local d = Vector3.new(POSITION_REND.X - h.Position.X, 0, POSITION_REND.Z - h.Position.Z)
            if d.Magnitude < 1 then
                autoRightPhase = 0
                hum:Move(Vector3.zero, false)
                h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                task.delay(0.2, function()
                    if AutoRightEnabled then autoRightPhase = 3 end
                end)
                return
            end
            local md = d.Unit
            hum:Move(md, false)
            h.AssemblyLinearVelocity = Vector3.new(md.X * Config.ForwardSpeed, h.AssemblyLinearVelocity.Y, md.Z * Config.ForwardSpeed)

        elseif autoRightPhase == 0 then
            return

        elseif autoRightPhase == 3 then
            local d = Vector3.new(POSITION_R1.X - h.Position.X, 0, POSITION_R1.Z - h.Position.Z)
            if d.Magnitude < 1 then autoRightPhase = 4; return end
            local md = d.Unit
            hum:Move(md, false)
            h.AssemblyLinearVelocity = Vector3.new(md.X * Config.ReturnSpeed, h.AssemblyLinearVelocity.Y, md.Z * Config.ReturnSpeed)

        elseif autoRightPhase == 4 then
            local d = Vector3.new(POSITION_RFINAL.X - h.Position.X, 0, POSITION_RFINAL.Z - h.Position.Z)
            if d.Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                AutoRightEnabled = false
                stopAutoRight()
                if _G._updateMiniRight then _G._updateMiniRight() end
                return
            end
            local md = d.Unit
            hum:Move(md, false)
            h.AssemblyLinearVelocity = Vector3.new(md.X * Config.ReturnSpeed, h.AssemblyLinearVelocity.Y, md.Z * Config.ReturnSpeed)
        end
    end)
end

-- UI Setup
local sg = Instance.new("ScreenGui")
sg.Name        = "PlexhubAutoDuel"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999
sg.Parent       = Player.PlayerGui
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true

-- Shadow effect (adjusted for larger size)
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(0, 270, 0, 290)
Shadow.Position = UDim2.new(0, 15, 0.5, -145)
Shadow.BackgroundTransparency = 1
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = sg

local frame = Instance.new("Frame")
frame.Size            = originalSize
frame.Position        = UDim2.new(0, 20, 0.5, -140) -- Centered with new size
frame.BackgroundColor3 = COLORS.Background
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active    = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent    = sg
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

-- Blue to Purple tweening stroke
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2.5

local strokeTween
local blueToPurple = true

local function updateStrokeColor()
    local targetColor = blueToPurple and COLORS.ButtonBlue or COLORS.ButtonPurple
    strokeTween = TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = targetColor})
    strokeTween:Play()
    blueToPurple = not blueToPurple
end

updateStrokeColor()
strokeTween.Completed:Connect(updateStrokeColor)

-- Top bar with minimize and close buttons (taller for better spacing)
local TopBar = Instance.new("Frame", frame)
TopBar.Size = UDim2.new(1,0,0,45) -- Taller top bar
TopBar.BackgroundColor3 = COLORS.TopBarBlue
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", TopBar)
title.Size               = UDim2.new(1, -80, 1, 0)
title.Position            = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text               = "Plexhub Auto Duel"
title.TextColor3         = COLORS.TextWhite
title.Font               = Enum.Font.Bangers
title.TextSize           = 24 -- Larger text
title.TextXAlignment     = Enum.TextXAlignment.Left
title.ZIndex             = 3

-- Minimize button
local minimizeBtn = Instance.new("TextButton", TopBar)
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -80, 0.5, -17)
minimizeBtn.BackgroundColor3 = COLORS.ButtonPurple
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = COLORS.TextWhite
minimizeBtn.Font = Enum.Font.Bangers
minimizeBtn.TextSize = 28
minimizeBtn.TextScaled = true
minimizeBtn.AutoButtonColor = false
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

-- Close button
local closeBtn = Instance.new("TextButton", TopBar)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0.5, -17)
closeBtn.BackgroundColor3 = COLORS.ButtonPurple
closeBtn.Text = "✕"
closeBtn.TextColor3 = COLORS.TextWhite
closeBtn.Font = Enum.Font.Bangers
closeBtn.TextSize = 24
closeBtn.TextScaled = true
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Hover effects for top bar buttons
minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHoverPurple}):Play()
end)
minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonPurple}):Play()
end)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonPurple}):Play()
end)

-- Content container (for minimize functionality)
local contentContainer = Instance.new("Frame", frame)
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, 0, 1, -45)
contentContainer.Position = UDim2.new(0, 0, 0, 45)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0

-- Buttons (adjusted positions for larger UI)
local btnLeft = Instance.new("TextButton", contentContainer)
btnLeft.Size             = UDim2.new(1, -30, 0, 40)
btnLeft.Position         = UDim2.new(0, 15, 0, 10)
btnLeft.BackgroundColor3 = COLORS.ButtonPurple
btnLeft.Text             = "AUTO LEFT  ●  OFF"
btnLeft.TextColor3       = COLORS.TextWhite
btnLeft.Font             = Enum.Font.Bangers
btnLeft.TextSize         = 18
btnLeft.AutoButtonColor  = false
btnLeft.ZIndex           = 3
Instance.new("UICorner", btnLeft).CornerRadius = UDim.new(0, 10)

local btnRight = Instance.new("TextButton", contentContainer)
btnRight.Size             = UDim2.new(1, -30, 0, 40)
btnRight.Position         = UDim2.new(0, 15, 0, 60)
btnRight.BackgroundColor3 = COLORS.ButtonBlue
btnRight.Text             = "AUTO RIGHT  ●  OFF"
btnRight.TextColor3       = COLORS.TextWhite
btnRight.Font             = Enum.Font.Bangers
btnRight.TextSize         = 18
btnRight.AutoButtonColor  = false
btnRight.ZIndex           = 3
Instance.new("UICorner", btnRight).CornerRadius = UDim.new(0, 10)

-- Hover effects for main buttons
btnLeft.MouseEnter:Connect(function()
    TweenService:Create(btnLeft, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHoverPurple}):Play()
end)
btnLeft.MouseLeave:Connect(function()
    local color = AutoLeftEnabled and COLORS.ButtonActivePurple or COLORS.ButtonPurple
    TweenService:Create(btnLeft, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
end)

btnRight.MouseEnter:Connect(function()
    TweenService:Create(btnRight, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHoverBlue}):Play()
end)
btnRight.MouseLeave:Connect(function()
    local color = AutoRightEnabled and COLORS.ButtonActiveBlue or COLORS.ButtonBlue
    TweenService:Create(btnRight, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
end)

local sep = Instance.new("Frame", contentContainer)
sep.Size              = UDim2.new(0.85, 0, 0, 1)
sep.Position          = UDim2.new(0.075, 0, 0, 115)
sep.BackgroundColor3  = COLORS.TopBarBlue
sep.BorderSizePixel   = 0
sep.ZIndex            = 3

local function makeSlider(yPos, labelText, defaultVal, maxVal, onChanged)
    local lbl = Instance.new("TextLabel", contentContainer)
    lbl.Size               = UDim2.new(1, -30, 0, 20)
    lbl.Position           = UDim2.new(0, 15, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text               = labelText .. defaultVal
    lbl.TextColor3         = COLORS.SliderPurple1
    lbl.Font               = Enum.Font.Bangers
    lbl.TextSize           = 16
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 3

    local bg = Instance.new("Frame", contentContainer)
    bg.Size               = UDim2.new(1, -30, 0, 10)
    bg.Position           = UDim2.new(0, 15, 0, yPos + 22)
    bg.BackgroundColor3   = Color3.fromRGB(15, 15, 25)
    bg.BorderSizePixel    = 0
    bg.ZIndex             = 3
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bg)
    fill.Size             = UDim2.new(defaultVal / maxVal, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 4
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    -- Purple gradient for both sliders
    local fg = Instance.new("UIGradient", fill)
    fg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   COLORS.SliderPurple1),
        ColorSequenceKeypoint.new(0.5, COLORS.SliderPurple2),
        ColorSequenceKeypoint.new(1,   COLORS.SliderPurple3),
    })

    local sh = Instance.new("Frame", fill)
    sh.Size                  = UDim2.new(0, 25, 1, 0) -- Wider shine effect
    sh.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
    sh.BackgroundTransparency = 0.55
    sh.BorderSizePixel       = 0
    sh.ZIndex                = 5
    Instance.new("UICorner", sh).CornerRadius = UDim.new(1, 0)
    local shg = Instance.new("UIGradient", sh)
    shg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   1),
        NumberSequenceKeypoint.new(0.5, 0.4),
        NumberSequenceKeypoint.new(1,   1),
    })
    task.spawn(function()
        local offset = math.random()
        task.wait(offset * 1.5)
        while sh.Parent do
            sh.Position = UDim2.new(-0.15, 0, 0, 0)
            TweenService:Create(sh, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                {Position = UDim2.new(1.1, 0, 0, 0)}):Play()
            task.wait(1.9)
        end
    end)

    local knob = Instance.new("Frame", fill)
    knob.Size            = UDim2.new(0, 16, 0, 16) -- Larger knob
    knob.Position        = UDim2.new(1, -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex          = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", bg)
    btn.Size             = UDim2.new(1, 0, 4, 0)
    btn.Position         = UDim2.new(0, 0, -1.5, 0)
    btn.BackgroundTransparency = 1
    btn.Text             = ""
    btn.ZIndex           = 7

    local dragging = false
    btn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            local val = math.max(1, math.floor(pct * maxVal))
            fill.Size = UDim2.new(pct, 0, 1, 0)
            lbl.Text  = labelText .. val
            onChanged(val)
        end
    end)

    return lbl, fill
end

-- Walk Speed slider (top, purple)
makeSlider(
    130, -- Adjusted Y position
    "Walk Speed : ",
    Config.ForwardSpeed,
    100,
    function(v) Config.ForwardSpeed = v end
)

-- Steal Speed slider (bottom, purple)
makeSlider(
    180, -- Adjusted Y position
    "Steal Speed : ",
    Config.ReturnSpeed,
    100,
    function(v) Config.ReturnSpeed = v end
)

-- Minimize/Close functionality
local function setMinimized(state)
    isMinimized = state
    if isMinimized then
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = minimizedSize}):Play()
        contentContainer.Visible = false
        minimizeBtn.Text = "□"
    else
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = originalSize}):Play()
        contentContainer.Visible = true
        minimizeBtn.Text = "−"
    end
end

minimizeBtn.MouseButton1Click:Connect(function()
    setMinimized(not isMinimized)
end)

closeBtn.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

local function updateLeft()
    if AutoLeftEnabled then
        TweenService:Create(btnLeft, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonActivePurple}):Play()
        btnLeft.Text = "AUTO LEFT  ●  ON"
    else
        TweenService:Create(btnLeft, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonPurple}):Play()
        btnLeft.Text = "AUTO LEFT  ●  OFF"
    end
end

local function updateRight()
    if AutoRightEnabled then
        TweenService:Create(btnRight, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonActiveBlue}):Play()
        btnRight.Text = "AUTO RIGHT  ●  ON"
    else
        TweenService:Create(btnRight, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonBlue}):Play()
        btnRight.Text = "AUTO RIGHT  ●  OFF"
    end
end

_G._updateMiniLeft  = updateLeft
_G._updateMiniRight = updateRight

btnLeft.MouseButton1Click:Connect(function()
    AutoLeftEnabled = not AutoLeftEnabled
    if AutoLeftEnabled then
        AutoRightEnabled = false
        stopAutoRight()
        updateRight()
        startAutoLeft()
    else
        stopAutoLeft()
    end
    updateLeft()
end)

btnRight.MouseButton1Click:Connect(function()
    AutoRightEnabled = not AutoRightEnabled
    if AutoRightEnabled then
        AutoLeftEnabled = false
        stopAutoLeft()
        updateLeft()
        startAutoRight()
    else
        stopAutoRight()
    end
    updateRight()
end)

-- Cleanup
sg.Destroying:Connect(function()
    if strokeTween then
        strokeTween:Cancel()
    end
end)

-- Character respawn handling
Player.CharacterAdded:Connect(function()
    AutoLeftEnabled = false
    AutoRightEnabled = false
    stopAutoLeft()
    stopAutoRight()
    updateLeft()
    updateRight()
end)

updateLeft()
updateRight()

-- Auto grab 

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local me = Players.LocalPlayer

-- Color definitions (purple/blue theme)
local COLORS = {
    Background = Color3.fromRGB(10, 15, 35), -- Dark blue background
    ButtonPurple = Color3.fromRGB(120, 40, 180), -- Purple
    ButtonBlue = Color3.fromRGB(40, 80, 200), -- Blue
    ButtonHoverPurple = Color3.fromRGB(150, 60, 220), -- Lighter purple
    ButtonHoverBlue = Color3.fromRGB(60, 100, 240), -- Lighter blue
    ButtonActivePurple = Color3.fromRGB(160, 80, 220), -- Active purple
    ButtonActiveBlue = Color3.fromRGB(80, 120, 240), -- Active blue
    TopBarBlue = Color3.fromRGB(30, 60, 150), -- Medium blue
    TextWhite = Color3.fromRGB(255, 255, 255),
    SliderPurple1 = Color3.fromRGB(180, 120, 255), -- Light purple
    SliderPurple2 = Color3.fromRGB(140, 80, 220), -- Medium purple
    SliderPurple3 = Color3.fromRGB(100, 40, 180), -- Dark purple
    StatusGreen = Color3.fromRGB(40, 200, 64),
    StatusRed = Color3.fromRGB(255, 95, 87)
}

-- Window state
local isMinimized = false
local originalSize = UDim2.new(0, 300, 0, 180)
local minimizedSize = UDim2.new(0, 300, 0, 45)

-- auto steal
local stealActive = false
local stealConn = nil
local animalCache = {}
local promptCache = {}
local stealCache = {}
local isStealing = false
local STEAL_R = 7

local AnimalsData = {}
pcall(function()
	local rep = game:GetService("ReplicatedStorage")
	local datas = rep:FindFirstChild("Datas")
	if datas then
		local animals = datas:FindFirstChild("Animals")
		if animals then AnimalsData = require(animals) end
	end
end)

local function stealHRP()
	local c = me.Character; if not c then return nil end
	return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")
end

local function isMyBase(plotName)
	local plot = workspace.Plots and workspace.Plots:FindFirstChild(plotName); if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign"); if not sign then return false end
	local yb = sign:FindFirstChild("YourBase")
	return yb and yb:IsA("BillboardGui") and yb.Enabled == true
end

local function scanPlot(plot)
	if not plot or not plot:IsA("Model") then return end
	if isMyBase(plot.Name) then return end
	local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return end
	for _, pod in ipairs(podiums:GetChildren()) do
		if pod:IsA("Model") and pod:FindFirstChild("Base") then
			local name = "Unknown"
			local spawn = pod.Base:FindFirstChild("Spawn")
			if spawn then
				for _, child in ipairs(spawn:GetChildren()) do
					if child:IsA("Model") and child.Name ~= "PromptAttachment" then
						name = child.Name
						local info = AnimalsData[name]
						if info and info.DisplayName then name = info.DisplayName end
						break
					end
				end
			end
			table.insert(animalCache, {
				name = name, plot = plot.Name, slot = pod.Name,
				worldPosition = pod:GetPivot().Position,
				uid = plot.Name .. "_" .. pod.Name,
			})
		end
	end
end

local function findPrompt(ad)
	if not ad then return nil end
	local cp = promptCache[ad.uid]
	if cp and cp.Parent then return cp end
	local plots = workspace:FindFirstChild("Plots"); if not plots then return nil end
	local plot = plots:FindFirstChild(ad.plot); if not plot then return nil end
	local pods = plot:FindFirstChild("AnimalPodiums"); if not pods then return nil end
	local pod = pods:FindFirstChild(ad.slot); if not pod then return nil end
	local base = pod:FindFirstChild("Base"); if not base then return nil end
	local sp = base:FindFirstChild("Spawn"); if not sp then return nil end
	local att = sp:FindFirstChild("PromptAttachment"); if not att then return nil end
	for _, p in ipairs(att:GetChildren()) do
		if p:IsA("ProximityPrompt") then promptCache[ad.uid] = p; return p end
	end
end

local function buildCallbacks(prompt)
	if stealCache[prompt] then return end
	local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
	local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
	if ok1 and type(c1) == "table" then
		for _, conn in ipairs(c1) do
			if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
		end
	end
	local ok2, c2 = pcall(getconnections, prompt.Triggered)
	if ok2 and type(c2) == "table" then
		for _, conn in ipairs(c2) do
			if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
		end
	end
	if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then stealCache[prompt] = data end
end

local function execSteal(prompt)
	local data = stealCache[prompt]
	if not data or not data.ready then return false end
	data.ready = false; isStealing = true
	task.spawn(function()
		for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
		task.wait(0.2)
		for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
		task.wait(0.01); data.ready = true; task.wait(0.01); isStealing = false
	end)
	return true
end

local function nearestAnimal()
	local hrp = stealHRP(); if not hrp then return nil end
	local best, bestD = nil, math.huge
	for _, ad in ipairs(animalCache) do
		if not isMyBase(ad.plot) and ad.worldPosition then
			local d = (hrp.Position - ad.worldPosition).Magnitude
			if d < bestD then bestD = d; best = ad end
		end
	end
	return best
end

local function startStealLoop()
	if stealConn then stealConn:Disconnect() end
	stealConn = RS.Heartbeat:Connect(function()
		if not stealActive or isStealing then return end
		local target = nearestAnimal(); if not target then return end
		local hrp = stealHRP(); if not hrp then return end
		if (hrp.Position - target.worldPosition).Magnitude > STEAL_R then return end
		local prompt = promptCache[target.uid]
		if not prompt or not prompt.Parent then prompt = findPrompt(target) end
		if prompt then buildCallbacks(prompt); execSteal(prompt) end
	end)
end

-- Initialize animal scanning
task.spawn(function()
	task.wait(2)
	local plots = workspace:WaitForChild("Plots", 10); if not plots then return end
	for _, plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanPlot(plot) end end
	plots.ChildAdded:Connect(function(plot)
		if plot:IsA("Model") then task.wait(0.5); scanPlot(plot) end
	end)
	task.spawn(function()
		while task.wait(5) do
			animalCache = {}
			for _, plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanPlot(plot) end end
		end
	end)
end)

-- Start steal loop
startStealLoop()

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "PlexhubAutoSteal"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(0, 310, 0, 190)
Shadow.Position = UDim2.new(0.5, -155, 0.5, -95)
Shadow.BackgroundTransparency = 1
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = gui

local win = Instance.new("Frame")
win.Name = "Window"
win.Size = originalSize
win.Position = UDim2.new(0.5, -150, 0.5, -90)
win.BackgroundColor3 = COLORS.Background
win.BackgroundTransparency = 0.1
win.BorderSizePixel = 0
win.Active = true
win.Draggable = true
win.ClipsDescendants = true
win.Parent = gui

local winCorner = Instance.new("UICorner")
winCorner.CornerRadius = UDim.new(0, 14)
winCorner.Parent = win

-- Blue to Purple tweening stroke
local stroke = Instance.new("UIStroke", win)
stroke.Thickness = 2.5

local strokeTween
local blueToPurple = true

local function updateStrokeColor()
    local targetColor = blueToPurple and COLORS.ButtonBlue or COLORS.ButtonPurple
    strokeTween = TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = targetColor})
    strokeTween:Play()
    blueToPurple = not blueToPurple
end

updateStrokeColor()
strokeTween.Completed:Connect(updateStrokeColor)

-- Top bar
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 45)
topbar.BackgroundColor3 = COLORS.TopBarBlue
topbar.BorderSizePixel = 0
topbar.Parent = win

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = topbar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Plexhub Auto Steal"
title.TextColor3 = COLORS.TextWhite
title.Font = Enum.Font.Bangers
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar

-- Minimize button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -80, 0.5, -17)
minimizeBtn.BackgroundColor3 = COLORS.ButtonPurple
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = COLORS.TextWhite
minimizeBtn.Font = Enum.Font.Bangers
minimizeBtn.TextSize = 28
minimizeBtn.TextScaled = true
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = topbar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0.5, -17)
closeBtn.BackgroundColor3 = COLORS.ButtonPurple
closeBtn.Text = "✕"
closeBtn.TextColor3 = COLORS.TextWhite
closeBtn.Font = Enum.Font.Bangers
closeBtn.TextSize = 24
closeBtn.TextScaled = true
closeBtn.AutoButtonColor = false
closeBtn.Parent = topbar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Hover effects
minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHoverPurple}):Play()
end)
minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonPurple}):Play()
end)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonPurple}):Play()
end)

-- Content container
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, 0, 1, -45)
contentContainer.Position = UDim2.new(0, 0, 0, 45)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.Parent = win

-- Auto Steal button
local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(1, -30, 0, 45)
stealBtn.Position = UDim2.new(0, 15, 0, 15)
stealBtn.BackgroundColor3 = COLORS.ButtonBlue
stealBtn.Text = "AUTO STEAL  ●  OFF"
stealBtn.TextColor3 = COLORS.TextWhite
stealBtn.Font = Enum.Font.Bangers
stealBtn.TextSize = 20
stealBtn.AutoButtonColor = false
stealBtn.Parent = contentContainer
Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0, 10)

-- Status indicator dot
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 12, 0, 12)
statusDot.Position = UDim2.new(1, -30, 0.5, -6)
statusDot.BackgroundColor3 = COLORS.StatusRed
statusDot.Parent = stealBtn
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

-- Radius control
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0, 80, 0, 20)
radiusLabel.Position = UDim2.new(0, 15, 0, 70)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Radius:"
radiusLabel.TextColor3 = COLORS.SliderPurple1
radiusLabel.Font = Enum.Font.Bangers
radiusLabel.TextSize = 16
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = contentContainer

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(0, 50, 0, 25)
radiusBox.Position = UDim2.new(0, 85, 0, 68)
radiusBox.BackgroundColor3 = COLORS.ButtonPurple
radiusBox.Text = tostring(STEAL_R)
radiusBox.TextColor3 = COLORS.TextWhite
radiusBox.Font = Enum.Font.Bangers
radiusBox.TextSize = 16
radiusBox.TextScaled = true
radiusBox.BorderSizePixel = 0
radiusBox.Parent = contentContainer
Instance.new("UICorner", radiusBox).CornerRadius = UDim.new(0, 6)

-- Radius slider background
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -30, 0, 10)
sliderBg.Position = UDim2.new(0, 15, 0, 105)
sliderBg.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = contentContainer
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

-- Radius slider fill
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(STEAL_R / 20, 0, 1, 0)
sliderFill.BackgroundColor3 = COLORS.ButtonBlue
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

-- Slider knob
local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 16, 0, 16)
knob.Position = UDim2.new(1, -8, 0.5, -8)
knob.BackgroundColor3 = COLORS.TextWhite
knob.BorderSizePixel = 0
knob.Parent = sliderFill
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

-- Slider button (invisible)
local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(1, 0, 2, 0)
sliderBtn.Position = UDim2.new(0, 0, -0.5, 0)
sliderBtn.BackgroundTransparency = 1
sliderBtn.Text = ""
sliderBtn.Parent = sliderBg

-- Hover effect for steal button
stealBtn.MouseEnter:Connect(function()
    TweenService:Create(stealBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHoverBlue}):Play()
end)
stealBtn.MouseLeave:Connect(function()
    local color = stealActive and COLORS.ButtonActiveBlue or COLORS.ButtonBlue
    TweenService:Create(stealBtn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
end)

-- Radius box focus
radiusBox.FocusLost:Connect(function()
    local n = tonumber(radiusBox.Text)
    if n then 
        STEAL_R = math.clamp(n, 1, 20)
        radiusBox.Text = tostring(STEAL_R)
        sliderFill:TweenSize(UDim2.new(STEAL_R / 20, 0, 1, 0), "Out", "Quad", 0.2, true)
    else 
        radiusBox.Text = tostring(STEAL_R) 
    end
end)

-- Slider drag functionality
local dragging = false
sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local pct = math.clamp((i.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        STEAL_R = math.floor(pct * 20)
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        radiusBox.Text = tostring(STEAL_R)
    end
end)

-- Steal button click
stealBtn.MouseButton1Click:Connect(function()
    stealActive = not stealActive
    if stealActive then
        TweenService:Create(stealBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.ButtonActiveBlue}):Play()
        stealBtn.Text = "AUTO STEAL  ●  ON"
        statusDot.BackgroundColor3 = COLORS.StatusGreen
    else
        TweenService:Create(stealBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.ButtonBlue}):Play()
        stealBtn.Text = "AUTO STEAL  ●  OFF"
        statusDot.BackgroundColor3 = COLORS.StatusRed
    end
end)

-- Minimize functionality
local function setMinimized(state)
    isMinimized = state
    if isMinimized then
        TweenService:Create(win, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = minimizedSize}):Play()
        contentContainer.Visible = false
        minimizeBtn.Text = "□"
    else
        TweenService:Create(win, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = originalSize}):Play()
        contentContainer.Visible = true
        minimizeBtn.Text = "−"
    end
end

minimizeBtn.MouseButton1Click:Connect(function()
    setMinimized(not isMinimized)
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Cleanup
gui.Destroying:Connect(function()
    if strokeTween then
        strokeTween:Cancel()
    end
    if stealConn then
        stealConn:Disconnect()
    end
end)

-- Character respawn handling
me.CharacterAdded:Connect(function()
    stealActive = false
    stealBtn.Text = "AUTO STEAL  ●  OFF"
    statusDot.BackgroundColor3 = COLORS.StatusRed
    TweenService:Create(stealBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.ButtonBlue}):Play()
end)

-- Keyboard shortcut (U key)
UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.U then
        stealActive = not stealActive
        if stealActive then
            TweenService:Create(stealBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.ButtonActiveBlue}):Play()
            stealBtn.Text = "AUTO STEAL  ●  ON"
            statusDot.BackgroundColor3 = COLORS.StatusGreen
        else
            TweenService:Create(stealBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.ButtonBlue}):Play()
            stealBtn.Text = "AUTO STEAL  ●  OFF"
            statusDot.BackgroundColor3 = COLORS.StatusRed
        end
    end
end)



--  Misc


local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local ws = workspace
local cg = game:GetService("CoreGui")

-- Color definitions (purple/blue theme)
local COLORS = {
    Background = Color3.fromRGB(10, 15, 35), -- Dark blue background
    ButtonPurple = Color3.fromRGB(120, 40, 180), -- Purple
    ButtonBlue = Color3.fromRGB(40, 80, 200), -- Blue
    ButtonHoverPurple = Color3.fromRGB(150, 60, 220), -- Lighter purple
    ButtonHoverBlue = Color3.fromRGB(60, 100, 240), -- Lighter blue
    ButtonActivePurple = Color3.fromRGB(160, 80, 220), -- Active purple
    ButtonActiveBlue = Color3.fromRGB(80, 120, 240), -- Active blue
    TopBarBlue = Color3.fromRGB(30, 60, 150), -- Medium blue
    TextWhite = Color3.fromRGB(255, 255, 255),
    StatusGreen = Color3.fromRGB(40, 200, 64),
    StatusRed = Color3.fromRGB(255, 95, 87)
}

-- Window state
local isMinimized = false
local originalSize = UDim2.new(0, 220, 0, 180)
local minimizedSize = UDim2.new(0, 220, 0, 32) -- Smaller minimized height (32px)

-- Anti Ragdoll
local antirag = false
local charCache = {}
local ragConns = {}

local function cacheChar()
    local c = plr.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return false end
    charCache = {
        char = c,
        hum = h,
        root = r
    }
    return true
end

local function killConns()
    for _, c in pairs(ragConns) do
        pcall(function() c:Disconnect() end)
    end
    ragConns = {}
end

local function isRagdoll()
    if not charCache.hum then return false end
    local s = charCache.hum:GetState()
    if s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown then
        return true
    end
    local et = plr:GetAttribute("RagdollEndTime")
    if et then
        local n = workspace:GetServerTimeNow()
        if (et - n) > 0 then
            return true
        end
    end
    return false
end

local function removeCons()
    if not charCache.char then return end
    for _, d in pairs(charCache.char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and string.find(d.Name, "RagdollAttachment")) then
            pcall(function() d:Destroy() end)
        end
    end
end

local function forceExit()
    if not charCache.hum or not charCache.root then return end
    pcall(function()
        plr:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)
    if charCache.hum.Health > 0 then
        charCache.hum:ChangeState(Enum.HumanoidStateType.Running)
    end
    charCache.root.Anchored = false
    charCache.root.AssemblyLinearVelocity = Vector3.zero
end

local function setupCam()
    if not charCache.hum then return end
    table.insert(ragConns, rs.RenderStepped:Connect(function()
        if not antirag then return end
        local c = workspace.CurrentCamera
        if c and charCache.hum and c.CameraSubject ~= charCache.hum then
            c.CameraSubject = charCache.hum
        end
    end))
end

local function antiLoop()
    while antirag and charCache.hum do
        task.wait()
        if isRagdoll() then
            removeCons()
            forceExit()
        end
    end
end

local function onChar(c)
    task.wait(0.5)
    if not antirag then return end
    if cacheChar() then
        setupCam()
        task.spawn(antiLoop)
    end
end

local function enableAntiRagdoll()
    antirag = true
    if cacheChar() then
        setupCam()
        task.spawn(antiLoop)
    end
    table.insert(ragConns, plr.CharacterAdded:Connect(onChar))
    print("Anti Ragdoll ON")
end

local function disableAntiRagdoll()
    antirag = false
    killConns()
    charCache = {}
    print("Anti Ragdoll OFF")
end

-- Float Nearest
local floaton = false
local floatConn = nil
local floatSpeed = 56.1
local vertSpeed = 35
local target = nil

local function startFloat()
    floaton = true
    if floatConn then floatConn:Disconnect() end
    floatConn = rs.Heartbeat:Connect(function()
        if not floaton then return end
        local c = plr.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local np = nil
        local nd = math.huge
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= plr and p.Character then
                local oh = p.Character:FindFirstChild("HumanoidRootPart")
                if oh then
                    local d = (h.Position - oh.Position).Magnitude
                    if d < nd then
                        nd = d
                        np = p
                    end
                end
            end
        end
        if np and np.Character then
            local th = np.Character:FindFirstChild("HumanoidRootPart")
            if th then
                target = np
                local dir = (th.Position - h.Position).Unit
                local hd = th.Position.Y - h.Position.Y
                local hv = dir * floatSpeed
                local vv = 0
                if hd > 2 then
                    vv = vertSpeed
                elseif hd < -2 then
                    vv = -vertSpeed * 0.5
                end
                h.AssemblyLinearVelocity = Vector3.new(hv.X, vv, hv.Z)
            end
        else
            h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            target = nil
        end
    end)
    print("Float ON")
end

local function stopFloat()
    floaton = false
    target = nil
    if floatConn then
        floatConn:Disconnect()
        floatConn = nil
    end
    local c = plr.Character
    if c then
        local h = c:FindFirstChild("HumanoidRootPart")
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
    print("Float OFF")
end

-- Inf Jump
local infjump = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "PlexhubDuelHelper"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = cg

-- Shadow effect (adjusted for smaller minimized)
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(0, 230, 0, 190)
Shadow.Position = UDim2.new(0.5, -115, 0.5, -95)
Shadow.BackgroundTransparency = 1
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = gui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = originalSize
main.Position = UDim2.new(0.5, -110, 0.5, -90)
main.BackgroundColor3 = COLORS.Background
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

-- Blue to Purple tweening stroke
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2.5

local strokeTween
local blueToPurple = true

local function updateStrokeColor()
    local targetColor = blueToPurple and COLORS.ButtonBlue or COLORS.ButtonPurple
    strokeTween = ts:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = targetColor})
    strokeTween:Play()
    blueToPurple = not blueToPurple
end

updateStrokeColor()
strokeTween.Completed:Connect(updateStrokeColor)

-- Top bar (slimmer for minimized state)
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 32) -- Slimmer top bar (32px)
topbar.BackgroundColor3 = COLORS.TopBarBlue
topbar.BorderSizePixel = 0
topbar.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = topbar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Plexhub Helper"
title.TextColor3 = COLORS.TextWhite
title.Font = Enum.Font.Bangers
title.TextSize = 18 -- Slightly smaller for slimmer bar
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar

-- Minimize button (slightly smaller)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -58, 0.5, -12)
minimizeBtn.BackgroundColor3 = COLORS.ButtonPurple
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = COLORS.TextWhite
minimizeBtn.Font = Enum.Font.Bangers
minimizeBtn.TextSize = 20
minimizeBtn.TextScaled = true
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = topbar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

-- Close button (slightly smaller)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = COLORS.ButtonPurple
closeBtn.Text = "✕"
closeBtn.TextColor3 = COLORS.TextWhite
closeBtn.Font = Enum.Font.Bangers
closeBtn.TextSize = 18
closeBtn.TextScaled = true
closeBtn.AutoButtonColor = false
closeBtn.Parent = topbar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Hover effects for top bar buttons
minimizeBtn.MouseEnter:Connect(function()
    ts:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonHoverPurple}):Play()
end)
minimizeBtn.MouseLeave:Connect(function()
    ts:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonPurple}):Play()
end)

closeBtn.MouseEnter:Connect(function()
    ts:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    ts:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ButtonPurple}):Play()
end)

-- Content container (adjusted for slimmer top bar)
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, 0, 1, -32)
contentContainer.Position = UDim2.new(0, 0, 0, 32)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.Parent = main

-- Button creator function
local function createButton(yPos, text, color, hoverColor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 38)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = COLORS.TextWhite
    btn.Font = Enum.Font.Bangers
    btn.TextSize = 16 -- Slightly smaller text
    btn.AutoButtonColor = false
    btn.Parent = contentContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    -- Status indicator dot
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8) -- Smaller dot
    dot.Position = UDim2.new(1, -22, 0.5, -4)
    dot.BackgroundColor3 = COLORS.StatusRed
    dot.Parent = btn
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    -- Click handler
    btn.MouseButton1Click:Connect(function()
        callback(btn, dot)
    end)
    
    return btn, dot
end

-- Button states
local antiState = false
local floatState = false
local infJumpState = false

-- Create buttons (adjusted Y positions for slimmer layout)
local antiBtn, antiDot = createButton(8, "ANTI RAGDOLL", COLORS.ButtonPurple, COLORS.ButtonHoverPurple, function(btn, dot)
    antiState = not antiState
    if antiState then
        dot.BackgroundColor3 = COLORS.StatusGreen
        enableAntiRagdoll()
    else
        dot.BackgroundColor3 = COLORS.StatusRed
        disableAntiRagdoll()
    end
end)

local floatBtn, floatDot = createButton(52, "FLOAT NEAREST", COLORS.ButtonBlue, COLORS.ButtonHoverBlue, function(btn, dot)
    floatState = not floatState
    if floatState then
        dot.BackgroundColor3 = COLORS.StatusGreen
        startFloat()
    else
        dot.BackgroundColor3 = COLORS.StatusRed
        stopFloat()
    end
end)

local infJumpBtn, infJumpDot = createButton(96, "INF JUMP", COLORS.ButtonPurple, COLORS.ButtonHoverPurple, function(btn, dot)
    infJumpState = not infJumpState
    if infJumpState then
        dot.BackgroundColor3 = COLORS.StatusGreen
        infjump = true
        print("Inf Jump ON")
    else
        dot.BackgroundColor3 = COLORS.StatusRed
        infjump = false
        print("Inf Jump OFF")
    end
end)

-- Inf Jump logic
uis.JumpRequest:Connect(function()
    if infjump and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        plr.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
            plr.Character.HumanoidRootPart.AssemblyLinearVelocity.X, 
            52, 
            plr.Character.HumanoidRootPart.AssemblyLinearVelocity.Z
        )
    end
end)

-- Minimize functionality
local function setMinimized(state)
    isMinimized = state
    if isMinimized then
        ts:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = minimizedSize,
            Position = UDim2.new(0.5, -110, 0.5, -16) -- Center properly when minimized
        }):Play()
        contentContainer.Visible = false
        minimizeBtn.Text = "□"
    else
        ts:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = originalSize,
            Position = UDim2.new(0.5, -110, 0.5, -90)
        }):Play()
        contentContainer.Visible = true
        minimizeBtn.Text = "−"
    end
end

minimizeBtn.MouseButton1Click:Connect(function()
    setMinimized(not isMinimized)
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Character respawn handling
plr.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    if antiState then
        enableAntiRagdoll()
    end
    if floatState then
        startFloat()
    end
end)

-- Cleanup
gui.Destroying:Connect(function()
    if strokeTween then
        strokeTween:Cancel()
    end
    if floatConn then
        floatConn:Disconnect()
    end
    killConns()
end)

-- Keyboard shortcut to toggle GUI (Right Control)
uis.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightControl then
        gui.Enabled = not gui.Enabled
    end
end)

-- Animate the appearance
local function animate()
    main.Visible = true
    ts:Create(main, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
    ts:Create(stroke, TweenInfo.new(0.8), {Transparency = 0}):Play()
    task.wait(0.3)
    contentContainer.Visible = true
end

task.spawn(animate)

print("Plexhub Duel Helper - Purple/Blue Theme Loaded")

-- Auto copy Discord invite
pcall(function()
    if setclipboard then
        setclipboard("https://discord.gg/hS9mQsrwbU")
        print("Discord invite copied to clipboard!")

        -- Optional: small notification in your GUI
        local notification = Instance.new("TextLabel")
        notification.Size = UDim2.new(0, 220, 0, 30)
        notification.Position = UDim2.new(0.5, -110, 0, 50)
        notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        notification.TextColor3 = Color3.fromRGB(255, 255, 255)
        notification.Text = "Discord invite copied!"
        notification.Font = Enum.Font.GothamBold
        notification.TextSize = 16
        notification.BackgroundTransparency = 0.2
        notification.BorderSizePixel = 0
        notification.Parent = game:GetService("CoreGui")

        -- Rounded corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notification

        -- Fade out after 3 seconds
        task.spawn(function()
            task.wait(3)
            notification:Destroy()
        end)
    end
end)

