-- --- UniversalAimbotGUI.lua ---

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AimbotConfig = {
    Enabled = false,
    TeamCheck = true,
    VisibleCheck = false,
    FOV = 120,
    Smoothing = 0.18,
    PredictionStrength = 0.12,
    AimPart = "Head",
    TriggerKey = Enum.UserInputType.MouseButton2,
    TriggerKeyCode = nil,
}

local TriggerbotConfig = {
    Enabled = false,
    TeamCheck = true,
    ShowIndicator = true,
    FireDelay = 0.05,
    ReleaseDelay = 0.02,
}

local ESPConfig = {
    Enabled    = false,
    TeamCheck  = true,
    Outline    = true,
    Box        = true,
    Skeleton   = true,
    Tracer     = true,
    EnemyColor = Color3.fromRGB(255, 60, 60),
    TeamColor  = Color3.fromRGB(60, 180, 255),
}

local FRAME_W = 260
local FRAME_H = 470
local TITLE_H = 36
local TAB_H   = 30
local SLIDE_Y = TITLE_H + TAB_H + 1
local TAB_W   = math.floor(FRAME_W / 3)

-- ── GUI root ──────────────────────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalAimbotGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
MainFrame.Position = UDim2.new(0.5, -FRAME_W/2, 0.5, -FRAME_H/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(80, 60, 200)
Stroke.Thickness = 1.5

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(0, FRAME_W, 0, TITLE_H)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 20, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.ZIndex = 20
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 180, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "UNIVERSAL AIMBOT"
TitleLabel.TextColor3 = Color3.fromRGB(160, 130, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 21
TitleLabel.Parent = TitleBar

-- Tab bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, FRAME_W, 0, TAB_H)
TabBar.Position = UDim2.new(0, 0, 0, TITLE_H + 1)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
TabBar.BorderSizePixel = 0
TabBar.ClipsDescendants = false
TabBar.ZIndex = 18
TabBar.Parent = MainFrame

local function MakeTabBtn(label, xPos)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, TAB_W, 0, TAB_H)
    Btn.Position = UDim2.new(0, xPos, 0, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    Btn.BorderSizePixel = 0
    Btn.Text = label
    Btn.TextColor3 = Color3.fromRGB(130, 120, 160)
    Btn.TextSize = 10
    Btn.Font = Enum.Font.GothamBold
    Btn.ZIndex = 19
    Btn.Parent = TabBar
    return Btn
end

local TabAimbot  = MakeTabBtn("AIMBOT",  0)
local TabTrigger = MakeTabBtn("TRIGGER", TAB_W)
local TabESP     = MakeTabBtn("ESP",     TAB_W * 2)
TabAimbot.TextColor3 = Color3.fromRGB(160, 130, 255)

local Underline = Instance.new("Frame")
Underline.Size = UDim2.new(0, TAB_W, 0, 2)
Underline.Position = UDim2.new(0, 0, 1, -2)
Underline.BackgroundColor3 = Color3.fromRGB(100, 70, 220)
Underline.BorderSizePixel = 0
Underline.ZIndex = 20
Underline.Parent = TabBar

-- Slide container — 3 panels
local SlideContainer = Instance.new("Frame")
SlideContainer.Size = UDim2.new(0, FRAME_W * 3, 0, FRAME_H - SLIDE_Y)
SlideContainer.Position = UDim2.new(0, 0, 0, SLIDE_Y)
SlideContainer.BackgroundTransparency = 1
SlideContainer.BorderSizePixel = 0
SlideContainer.ZIndex = 1
SlideContainer.Parent = MainFrame

local function MakePanel(xOffset)
    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(0, FRAME_W, 1, 0)
    Panel.Position = UDim2.new(0, xOffset, 0, 0)
    Panel.BackgroundTransparency = 1
    Panel.BorderSizePixel = 0
    Panel.Parent = SlideContainer

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -8)
    Content.Position = UDim2.new(0, 10, 0, 4)
    Content.BackgroundTransparency = 1
    Content.Parent = Panel

    local List = Instance.new("UIListLayout", Content)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Padding = UDim.new(0, 8)

    return Panel, Content
end

local _, AimbotContent  = MakePanel(0)
local _, TriggerContent = MakePanel(FRAME_W)
local _, ESPContent     = MakePanel(FRAME_W * 2)

-- Tab switching
local currentTab = "aimbot"
local tweenInfo  = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tabTitles  = {aimbot="UNIVERSAL AIMBOT", triggerbot="UNIVERSAL TRIGGER", esp="UNIVERSAL ESP"}

local function SwitchTab(tab)
    if tab == currentTab then return end
    currentTab = tab
    local slideX = (tab == "triggerbot") and -FRAME_W or (tab == "esp") and -FRAME_W*2 or 0
    local underX = (tab == "triggerbot") and TAB_W    or (tab == "esp") and TAB_W*2    or 0
    TweenService:Create(SlideContainer, tweenInfo, {Position = UDim2.new(0, slideX, 0, SLIDE_Y)}):Play()
    TweenService:Create(Underline,      tweenInfo, {Position = UDim2.new(0, underX, 1, -2)}):Play()
    local active, idle = Color3.fromRGB(160,130,255), Color3.fromRGB(130,120,160)
    TweenService:Create(TabAimbot,  tweenInfo, {TextColor3 = tab=="aimbot"     and active or idle}):Play()
    TweenService:Create(TabTrigger, tweenInfo, {TextColor3 = tab=="triggerbot" and active or idle}):Play()
    TweenService:Create(TabESP,     tweenInfo, {TextColor3 = tab=="esp"        and active or idle}):Play()
    TitleLabel.Text = tabTitles[tab]
end

TabAimbot.MouseButton1Click:Connect(function()  SwitchTab("aimbot")     end)
TabTrigger.MouseButton1Click:Connect(function() SwitchTab("triggerbot") end)
TabESP.MouseButton1Click:Connect(function()     SwitchTab("esp")        end)

-- Title-bar drag
local draggingGUI, dragStart, frameStart = false, nil, nil
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingGUI = true; dragStart = inp.Position; frameStart = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingGUI = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if draggingGUI and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset+d.X, frameStart.Y.Scale, frameStart.Y.Offset+d.Y)
    end
end)

-- ── Widget builders ───────────────────────────────────────────────────────────
local function MakeToggle(parent, label, default, layoutOrder, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 32)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Row.BorderSizePixel = 0; Row.LayoutOrder = layoutOrder; Row.Parent = parent
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1; Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(210, 210, 225); Lbl.TextSize = 12
    Lbl.Font = Enum.Font.Gotham; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Row

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 20); Btn.Position = UDim2.new(1, -50, 0.5, -10)
    Btn.BorderSizePixel = 0; Btn.Text = ""; Btn.Parent = Row
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    local state = default
    local function refresh()
        Btn.BackgroundColor3 = state and Color3.fromRGB(100,70,220) or Color3.fromRGB(50,50,65)
    end
    refresh()
    Btn.MouseButton1Click:Connect(function() state = not state; refresh(); callback(state) end)
    return Btn
end

local function MakeSlider(parent, label, min, max, default, layoutOrder, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 46); Row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Row.BorderSizePixel = 0; Row.LayoutOrder = layoutOrder; Row.Parent = parent
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.65, 0, 0, 20); Lbl.Position = UDim2.new(0, 10, 0, 4)
    Lbl.BackgroundTransparency = 1; Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(210,210,225); Lbl.TextSize = 12
    Lbl.Font = Enum.Font.Gotham; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Row

    local ValLbl = Instance.new("TextLabel")
    ValLbl.Size = UDim2.new(0.3, -10, 0, 20); ValLbl.Position = UDim2.new(0.7, 0, 0, 4)
    ValLbl.BackgroundTransparency = 1; ValLbl.Text = tostring(default)
    ValLbl.TextColor3 = Color3.fromRGB(140,110,255); ValLbl.TextSize = 12
    ValLbl.Font = Enum.Font.GothamBold; ValLbl.TextXAlignment = Enum.TextXAlignment.Right; ValLbl.Parent = Row

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1,-20,0,4); Track.Position = UDim2.new(0,10,0,32)
    Track.BackgroundColor3 = Color3.fromRGB(50,50,65); Track.BorderSizePixel = 0; Track.Parent = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    Fill.BackgroundColor3 = Color3.fromRGB(100,70,220); Fill.BorderSizePixel = 0; Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0,12,0,12); Knob.AnchorPoint = Vector2.new(0.5,0.5)
    Knob.Position = UDim2.new((default-min)/(max-min),0,0.5,0)
    Knob.BackgroundColor3 = Color3.fromRGB(160,130,255); Knob.BorderSizePixel = 0; Knob.ZIndex = 2; Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local sd = false
    Knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if sd and i.UserInputType==Enum.UserInputType.MouseMovement then
            local r = math.clamp((i.Position.X-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
            local v = math.floor(min+(max-min)*r)
            Fill.Size = UDim2.new(r,0,1,0); Knob.Position = UDim2.new(r,0,0.5,0)
            ValLbl.Text = tostring(v); callback(v)
        end
    end)
end

local function MakeColorPicker(parent, label, default, layoutOrder, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 32); Row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Row.BorderSizePixel = 0; Row.LayoutOrder = layoutOrder; Row.Parent = parent
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.6, 0, 1, 0); Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1; Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(210,210,225); Lbl.TextSize = 12
    Lbl.Font = Enum.Font.Gotham; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Row

    local Swatch = Instance.new("TextButton")
    Swatch.Size = UDim2.new(0, 48, 0, 20); Swatch.Position = UDim2.new(1, -58, 0.5, -10)
    Swatch.BackgroundColor3 = default; Swatch.BorderSizePixel = 0
    Swatch.Text = ""; Swatch.ZIndex = 5; Swatch.Parent = Row
    Instance.new("UICorner", Swatch).CornerRadius = UDim.new(0, 4)

    local Popup = Instance.new("Frame")
    Popup.Size = UDim2.new(0, FRAME_W - 20, 0, 110)
    Popup.Position = UDim2.new(0, 0, 1, 4)
    Popup.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    Popup.BorderSizePixel = 0; Popup.ZIndex = 50; Popup.Visible = false; Popup.Parent = Row
    Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Popup).Color = Color3.fromRGB(80, 60, 200)

    local r = math.floor(default.R*255)
    local g = math.floor(default.G*255)
    local b = math.floor(default.B*255)

    local function UpdateColor()
        local c = Color3.fromRGB(r,g,b); Swatch.BackgroundColor3 = c; callback(c)
    end

    local channels = {
        {lbl="R", col=Color3.fromRGB(220,60,60),  getv=function() return r end, setv=function(v) r=v end},
        {lbl="G", col=Color3.fromRGB(60,200,80),  getv=function() return g end, setv=function(v) g=v end},
        {lbl="B", col=Color3.fromRGB(60,120,220), getv=function() return b end, setv=function(v) b=v end},
    }
    for i, ch in ipairs(channels) do
        local yOff = (i-1)*34+8
        local CL = Instance.new("TextLabel")
        CL.Size=UDim2.new(0,14,0,16); CL.Position=UDim2.new(0,8,0,yOff+1)
        CL.BackgroundTransparency=1; CL.Text=ch.lbl; CL.TextColor3=ch.col
        CL.TextSize=11; CL.Font=Enum.Font.GothamBold; CL.ZIndex=51; CL.Parent=Popup

        local VL = Instance.new("TextLabel")
        VL.Size=UDim2.new(0,28,0,16); VL.Position=UDim2.new(1,-34,0,yOff+1)
        VL.BackgroundTransparency=1; VL.Text=tostring(ch.getv())
        VL.TextColor3=Color3.fromRGB(200,200,220); VL.TextSize=10
        VL.Font=Enum.Font.GothamBold; VL.TextXAlignment=Enum.TextXAlignment.Right
        VL.ZIndex=51; VL.Parent=Popup

        local Tr = Instance.new("Frame")
        Tr.Size=UDim2.new(1,-58,0,4); Tr.Position=UDim2.new(0,26,0,yOff+8)
        Tr.BackgroundColor3=Color3.fromRGB(50,50,65); Tr.BorderSizePixel=0; Tr.ZIndex=51; Tr.Parent=Popup
        Instance.new("UICorner",Tr).CornerRadius=UDim.new(1,0)

        local Fl = Instance.new("Frame")
        Fl.Size=UDim2.new(ch.getv()/255,0,1,0); Fl.BackgroundColor3=ch.col
        Fl.BorderSizePixel=0; Fl.ZIndex=51; Fl.Parent=Tr
        Instance.new("UICorner",Fl).CornerRadius=UDim.new(1,0)

        local Kn = Instance.new("Frame")
        Kn.Size=UDim2.new(0,10,0,10); Kn.AnchorPoint=Vector2.new(0.5,0.5)
        Kn.Position=UDim2.new(ch.getv()/255,0,0.5,0)
        Kn.BackgroundColor3=Color3.fromRGB(220,210,255); Kn.BorderSizePixel=0; Kn.ZIndex=52; Kn.Parent=Tr
        Instance.new("UICorner",Kn).CornerRadius=UDim.new(1,0)

        local sliding=false
        Kn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
        UserInputService.InputChanged:Connect(function(i)
            if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
                local ratio=math.clamp((i.Position.X-Tr.AbsolutePosition.X)/Tr.AbsoluteSize.X,0,1)
                local val=math.floor(ratio*255); ch.setv(val)
                Fl.Size=UDim2.new(ratio,0,1,0); Kn.Position=UDim2.new(ratio,0,0.5,0)
                VL.Text=tostring(val); UpdateColor()
            end
        end)
    end

    local open=false
    Swatch.MouseButton1Click:Connect(function() open=not open; Popup.Visible=open end)
end

local function GetBindLabel()
    local n={[Enum.UserInputType.MouseButton1]="LMB",[Enum.UserInputType.MouseButton2]="RMB",[Enum.UserInputType.MouseButton3]="MMB"}
    if AimbotConfig.TriggerKeyCode then return AimbotConfig.TriggerKeyCode.Name end
    return n[AimbotConfig.TriggerKey] or "RMB"
end

local function MakeKeybind(parent, label, layoutOrder)
    local Row = Instance.new("Frame")
    Row.Size=UDim2.new(1,0,0,32); Row.BackgroundColor3=Color3.fromRGB(22,22,30)
    Row.BorderSizePixel=0; Row.LayoutOrder=layoutOrder; Row.Parent=parent
    Instance.new("UICorner",Row).CornerRadius=UDim.new(0,6)

    local Lbl=Instance.new("TextLabel")
    Lbl.Size=UDim2.new(0.55,0,1,0); Lbl.Position=UDim2.new(0,10,0,0)
    Lbl.BackgroundTransparency=1; Lbl.Text=label
    Lbl.TextColor3=Color3.fromRGB(210,210,225); Lbl.TextSize=12
    Lbl.Font=Enum.Font.Gotham; Lbl.TextXAlignment=Enum.TextXAlignment.Left; Lbl.Parent=Row

    local Btn=Instance.new("TextButton")
    Btn.Size=UDim2.new(0,72,0,22); Btn.Position=UDim2.new(1,-80,0.5,-11)
    Btn.BackgroundColor3=Color3.fromRGB(35,30,60); Btn.BorderSizePixel=0
    Btn.Text=GetBindLabel(); Btn.TextColor3=Color3.fromRGB(160,130,255)
    Btn.TextSize=11; Btn.Font=Enum.Font.GothamBold; Btn.Parent=Row
    Instance.new("UICorner",Btn).CornerRadius=UDim.new(0,4)

    local capturing=false; local captureConn=nil
    local function StopCapture()
        capturing=false
        if captureConn then captureConn:Disconnect(); captureConn=nil end
        Btn.BackgroundColor3=Color3.fromRGB(35,30,60); Btn.TextColor3=Color3.fromRGB(160,130,255)
        Btn.Text=GetBindLabel()
    end
    local function StartCapture()
        capturing=true
        Btn.BackgroundColor3=Color3.fromRGB(80,60,150); Btn.TextColor3=Color3.fromRGB(255,220,100)
        Btn.Text="..."
        captureConn=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then StopCapture(); return end
            if inp.UserInputType==Enum.UserInputType.MouseButton2 then
                AimbotConfig.TriggerKey=Enum.UserInputType.MouseButton2; AimbotConfig.TriggerKeyCode=nil; StopCapture(); return
            end
            if inp.UserInputType==Enum.UserInputType.MouseButton3 then
                AimbotConfig.TriggerKey=Enum.UserInputType.MouseButton3; AimbotConfig.TriggerKeyCode=nil; StopCapture(); return
            end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                if inp.KeyCode==Enum.KeyCode.Escape then StopCapture(); return end
                AimbotConfig.TriggerKey=nil; AimbotConfig.TriggerKeyCode=inp.KeyCode; StopCapture(); return
            end
        end)
    end
    Btn.MouseButton1Click:Connect(function() if capturing then StopCapture() else StartCapture() end end)
end

-- ── Panel contents ────────────────────────────────────────────────────────────
-- Aimbot
MakeToggle(AimbotContent, "Aimbot Enabled",  false, 1, function(v) AimbotConfig.Enabled=v end)
MakeToggle(AimbotContent, "Team Check",      true,  2, function(v) AimbotConfig.TeamCheck=v end)
MakeToggle(AimbotContent, "Visible Only",    false, 3, function(v) AimbotConfig.VisibleCheck=v end)
MakeToggle(AimbotContent, "Show FOV Circle", true,  4, function(v)
    -- toggled via ESPConfig.FOVVisible handled in loop
    AimbotConfig.ShowFOV = v
end)
MakeKeybind(AimbotContent, "Activate Key", 5)
MakeSlider(AimbotContent, "FOV Radius",       20, 400, 120, 6, function(v) AimbotConfig.FOV=v end)
MakeSlider(AimbotContent, "Smoothing (x100)", 1,  50,  18,  7, function(v) AimbotConfig.Smoothing=v/100 end)
MakeSlider(AimbotContent, "Prediction (x100)",0,  40,  12,  8, function(v) AimbotConfig.PredictionStrength=v/100 end)
AimbotConfig.ShowFOV = true

-- Triggerbot
MakeToggle(TriggerContent, "Triggerbot Enabled", false, 1, function(v) TriggerbotConfig.Enabled=v end)
MakeToggle(TriggerContent, "Team Check",         true,  2, function(v) TriggerbotConfig.TeamCheck=v end)
MakeToggle(TriggerContent, "Show Indicator",     true,  3, function(v) TriggerbotConfig.ShowIndicator=v end)
MakeSlider(TriggerContent, "Fire Delay (ms)",    0, 300, 50, 4, function(v) TriggerbotConfig.FireDelay=v/1000 end)
MakeSlider(TriggerContent, "Release Delay (ms)", 0, 200, 20, 5, function(v) TriggerbotConfig.ReleaseDelay=v/1000 end)

-- ESP
MakeToggle(ESPContent, "ESP Enabled",  false, 1, function(v) ESPConfig.Enabled=v end)
MakeToggle(ESPContent, "Team Check",   true,  2, function(v) ESPConfig.TeamCheck=v end)
MakeToggle(ESPContent, "Outline ESP",  true,  3, function(v) ESPConfig.Outline=v end)
MakeToggle(ESPContent, "Box ESP",      true,  4, function(v) ESPConfig.Box=v end)
MakeToggle(ESPContent, "Skeleton ESP", true,  5, function(v) ESPConfig.Skeleton=v end)
MakeToggle(ESPContent, "Tracer ESP",   true,  6, function(v) ESPConfig.Tracer=v end)
MakeColorPicker(ESPContent, "Enemy Color", ESPConfig.EnemyColor, 7, function(v) ESPConfig.EnemyColor=v end)
MakeColorPicker(ESPContent, "Team Color",  ESPConfig.TeamColor,  8, function(v) ESPConfig.TeamColor=v end)

-- ── Drawing layer — pure Drawing API, no Quad (not supported on all executors) ──
-- We use Lines to draw boxes (4 lines), outlines (4 lines offset), skeleton, tracer.
-- FOV circle drawn as a 64-segment line polygon.

local function NewLine(zindex)
    local l = Drawing.new("Line")
    l.Visible   = false
    l.Thickness = 1
    l.Color     = Color3.fromRGB(255,60,60)
    l.ZIndex    = zindex or 1
    return l
end

local function NewText()
    local t = Drawing.new("Text")
    t.Visible = false
    t.Size    = 13
    t.Center  = true
    t.Outline = true
    t.Color   = Color3.fromRGB(255,255,255)
    t.ZIndex  = 3
    return t
end

-- FOV polygon — 64 line segments forming a circle
local FOV_SEGS = 64
local fovLines = {}
for i = 1, FOV_SEGS do
    fovLines[i] = NewLine(5)
    fovLines[i].Color = Color3.fromRGB(100, 70, 220)
    fovLines[i].Thickness = 1.5
end

local function DrawFOVCircle(cx, cy, radius, visible)
    for i = 1, FOV_SEGS do
        local a0 = (i-1)/FOV_SEGS * math.pi * 2
        local a1 = i    /FOV_SEGS * math.pi * 2
        local l  = fovLines[i]
        if visible then
            l.From    = Vector2.new(cx + math.cos(a0)*radius, cy + math.sin(a0)*radius)
            l.To      = Vector2.new(cx + math.cos(a1)*radius, cy + math.sin(a1)*radius)
            l.Visible = true
        else
            l.Visible = false
        end
    end
end

-- Trigger dot — small cross instead of circle
local trigDot = {NewLine(6), NewLine(6)}
for _, l in ipairs(trigDot) do
    l.Color = Color3.fromRGB(255, 80, 80)
    l.Thickness = 2
end

local function DrawTrigDot(cx, cy, visible)
    local S = 5
    if visible then
        trigDot[1].From=Vector2.new(cx-S,cy); trigDot[1].To=Vector2.new(cx+S,cy); trigDot[1].Visible=true
        trigDot[2].From=Vector2.new(cx,cy-S); trigDot[2].To=Vector2.new(cx,cy+S); trigDot[2].Visible=true
    else
        trigDot[1].Visible=false; trigDot[2].Visible=false
    end
end

-- ESP object pool
local SKELETON_PAIRS = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local ESPPool = {}  -- [char] = { box={4 lines}, outline={4 lines}, tracer=line, skeleton={N lines} }

local function GetESPEntry(char)
    if ESPPool[char] then return ESPPool[char] end
    local e = {
        box     = {NewLine(2),NewLine(2),NewLine(2),NewLine(2)},
        outline = {NewLine(1),NewLine(1),NewLine(1),NewLine(1)},
        tracer  = NewLine(2),
        skeleton= {},
    }
    for i=1,#SKELETON_PAIRS do e.skeleton[i]=NewLine(2) end
    ESPPool[char] = e
    return e
end

local function HideEntry(e)
    for _,l in ipairs(e.box)     do l.Visible=false end
    for _,l in ipairs(e.outline) do l.Visible=false end
    for _,l in ipairs(e.skeleton)do l.Visible=false end
    e.tracer.Visible=false
end

local function ClearEntry(char)
    local e = ESPPool[char]; if not e then return end
    for _,l in ipairs(e.box)     do l:Remove() end
    for _,l in ipairs(e.outline) do l:Remove() end
    for _,l in ipairs(e.skeleton)do l:Remove() end
    e.tracer:Remove()
    ESPPool[char]=nil
end

-- draw 4-line box given corners TL TR BR BL as Vector2
local function DrawBox4(lines, tl, tr, br, bl, color, thickness)
    local corners = {{tl,tr},{tr,br},{br,bl},{bl,tl}}
    for i,pair in ipairs(corners) do
        lines[i].From=pair[1]; lines[i].To=pair[2]
        lines[i].Color=color; lines[i].Thickness=thickness; lines[i].Visible=true
    end
end

local function HideLines(lines) for _,l in ipairs(lines) do l.Visible=false end end

-- ── Targeting helpers ─────────────────────────────────────────────────────────
local function W2S(pos)
    local sp, vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), vis
end

local function GetAllHumanoids()
    local out={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health>0 then
            local char=obj.Parent
            if char and char~=LocalPlayer.Character then
                local root=char:FindFirstChild("HumanoidRootPart")
                local aimPart=char:FindFirstChild(AimbotConfig.AimPart) or char:FindFirstChild("Head") or root
                if root and aimPart then
                    table.insert(out,{char=char,humanoid=obj,root=root,aimPart=aimPart})
                end
            end
        end
    end
    return out
end

local function IsTeammate(char)
    local tp=Players:GetPlayerFromCharacter(char)
    return tp and tp.Team==LocalPlayer.Team
end

local function IsVisible(part)
    local origin=Camera.CFrame.Position
    local dir=part.Position-origin
    local hit=workspace:FindPartOnRayWithIgnoreList(Ray.new(origin,dir.Unit*dir.Magnitude),{LocalPlayer.Character})
    return hit and hit:IsDescendantOf(part.Parent)
end

local function GetClosestTarget()
    local closest,closestDist=nil,math.huge
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    for _,t in ipairs(GetAllHumanoids()) do
        if AimbotConfig.TeamCheck and IsTeammate(t.char) then continue end
        if AimbotConfig.VisibleCheck and not IsVisible(t.aimPart) then continue end
        local sp,onScreen=Camera:WorldToViewportPoint(t.aimPart.Position)
        if not onScreen then continue end
        local dist=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if dist<AimbotConfig.FOV and dist<closestDist then closestDist=dist; closest=t end
    end
    return closest
end

local function GetMouseTarget()
    local ur=Camera:ScreenPointToRay(Mouse.X,Mouse.Y)
    local hit=workspace:FindPartOnRayWithIgnoreList(Ray.new(ur.Origin,ur.Direction*2000),{LocalPlayer.Character})
    if not hit then return nil end
    local cur=hit
    while cur and cur~=workspace do
        if cur:IsA("Model") then
            local hum=cur:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.Health>0 then
                if TriggerbotConfig.TeamCheck and IsTeammate(cur) then return nil end
                return {char=cur,humanoid=hum}
            end
        end
        cur=cur.Parent
    end
    return nil
end

-- ── Triggerbot state ──────────────────────────────────────────────────────────
local triggerActive=false; local triggerTarget=nil
local fireDelayThread=nil; local releaseDelayThread=nil
local VIM=game:GetService("VirtualInputManager")

local function ReleaseFire()
    if triggerActive then
        triggerActive=false
        VIM:SendMouseButtonEvent(Mouse.X,Mouse.Y,0,false,game,0)
    end
end
local function BeginFire()
    if not triggerActive then
        triggerActive=true
        VIM:SendMouseButtonEvent(Mouse.X,Mouse.Y,0,true,game,0)
    end
end

-- ── Aimbot input ──────────────────────────────────────────────────────────────
local aimbotHolding=false
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if AimbotConfig.TriggerKeyCode then
        if inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==AimbotConfig.TriggerKeyCode then aimbotHolding=true end
    else
        if inp.UserInputType==AimbotConfig.TriggerKey then aimbotHolding=true end
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if AimbotConfig.TriggerKeyCode then
        if inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==AimbotConfig.TriggerKeyCode then aimbotHolding=false end
    else
        if inp.UserInputType==AimbotConfig.TriggerKey then aimbotHolding=false end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if p.Character then ClearEntry(p.Character) end
end)

-- ── Main loop ─────────────────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    local vp     = Camera.ViewportSize
    local cx, cy = vp.X/2, vp.Y/2

    -- FOV circle
    DrawFOVCircle(cx, cy, AimbotConfig.FOV, AimbotConfig.ShowFOV)

    -- Aimbot
    if AimbotConfig.Enabled and aimbotHolding then
        local t=GetClosestTarget()
        if t then
            local predicted=t.aimPart.Position
                +t.root.Velocity*((Camera.CFrame.Position-t.aimPart.Position).Magnitude/500)*AimbotConfig.PredictionStrength
            Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,predicted),AimbotConfig.Smoothing)
        end
    end

    -- Triggerbot
    if TriggerbotConfig.Enabled then
        local mt=GetMouseTarget()
        if mt then
            triggerTarget=mt
            if releaseDelayThread then task.cancel(releaseDelayThread); releaseDelayThread=nil end
            if not triggerActive and not fireDelayThread then
                fireDelayThread=task.delay(TriggerbotConfig.FireDelay,function() fireDelayThread=nil; BeginFire() end)
            end
        else
            triggerTarget=nil
            if fireDelayThread then task.cancel(fireDelayThread); fireDelayThread=nil end
            if triggerActive and not releaseDelayThread then
                releaseDelayThread=task.delay(TriggerbotConfig.ReleaseDelay,function() releaseDelayThread=nil; ReleaseFire() end)
            end
        end
        if triggerTarget and triggerTarget.humanoid.Health<=0 then
            triggerTarget=nil
            if fireDelayThread    then task.cancel(fireDelayThread);    fireDelayThread=nil    end
            if releaseDelayThread then task.cancel(releaseDelayThread); releaseDelayThread=nil end
            ReleaseFire()
        end
        DrawTrigDot(cx, cy, triggerActive and TriggerbotConfig.ShowIndicator)
    else
        DrawTrigDot(cx, cy, false)
        if triggerActive then
            if fireDelayThread    then task.cancel(fireDelayThread);    fireDelayThread=nil    end
            if releaseDelayThread then task.cancel(releaseDelayThread); releaseDelayThread=nil end
            ReleaseFire()
        end
    end

    -- ESP
    local activeChars={}

    if ESPConfig.Enabled then
        for _,t in ipairs(GetAllHumanoids()) do
            local char=t.char
            local isTeam=IsTeammate(char)
            if ESPConfig.TeamCheck and isTeam then
                local e=ESPPool[char]; if e then HideEntry(e) end; continue
            end

            local sp,vis=W2S(t.root.Position)
            if not vis then
                local e=ESPPool[char]; if e then HideEntry(e) end; continue
            end

            activeChars[char]=true
            local color=isTeam and ESPConfig.TeamColor or ESPConfig.EnemyColor
            local e=GetESPEntry(char)

            -- Box: project head top and feet bottom into screen
            local head    = char:FindFirstChild("Head")
            local hrp     = t.root
            local topPos  = head and head.Position+Vector3.new(0,head.Size.Y/2,0) or hrp.Position+Vector3.new(0,2.5,0)
            local botPos  = hrp.Position - Vector3.new(0, 3, 0)

            local topSP, topVis = W2S(topPos)
            local botSP, botVis = W2S(botPos)

            if ESPConfig.Box and topVis and botVis then
                local halfW = math.abs(botSP.Y - topSP.Y) * 0.4
                local tl=Vector2.new(topSP.X-halfW, topSP.Y)
                local tr=Vector2.new(topSP.X+halfW, topSP.Y)
                local br=Vector2.new(botSP.X+halfW, botSP.Y)
                local bl=Vector2.new(botSP.X-halfW, botSP.Y)
                DrawBox4(e.box, tl, tr, br, bl, color, 1.5)

                if ESPConfig.Outline then
                    local ox=2
                    DrawBox4(e.outline,
                        Vector2.new(tl.X-ox,tl.Y-ox), Vector2.new(tr.X+ox,tr.Y-ox),
                        Vector2.new(br.X+ox,br.Y+ox), Vector2.new(bl.X-ox,bl.Y+ox),
                        Color3.fromRGB(0,0,0), 3
                    )
                else
                    HideLines(e.outline)
                end
            else
                HideLines(e.box); HideLines(e.outline)
            end

            -- Tracer from bottom-center of screen
            if ESPConfig.Tracer then
                e.tracer.From=Vector2.new(cx, vp.Y)
                e.tracer.To=sp
                e.tracer.Color=color; e.tracer.Thickness=1; e.tracer.Visible=true
            else
                e.tracer.Visible=false
            end

            -- Skeleton
            for i,pair in ipairs(SKELETON_PAIRS) do
                local line=e.skeleton[i]
                if ESPConfig.Skeleton then
                    local p0=char:FindFirstChild(pair[1])
                    local p1=char:FindFirstChild(pair[2])
                    if p0 and p1 then
                        local sp0,v0=W2S(p0.Position)
                        local sp1,v1=W2S(p1.Position)
                        if v0 and v1 then
                            line.From=sp0; line.To=sp1
                            line.Color=color; line.Thickness=1; line.Visible=true
                        else line.Visible=false end
                    else line.Visible=false end
                else line.Visible=false end
            end
        end
    end

    -- hide stale entries
    for char,e in pairs(ESPPool) do
        if not activeChars[char] then HideEntry(e) end
    end
end)
