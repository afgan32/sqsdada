--[[
    LiquidGlass UI Library
    Style: iOS 26 / Apple Liquid Glass
    - Frosted glass panels with real blur simulation
    - Colorful gradient accents (orange, blue, pink, green)
    - Soft glowing controls
    - All elements: Toggle, Slider, Checkbox, ComboBox,
      MultiComboBox, ColorPicker, Keybind, Button, TextInput
]]

local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

---------------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------------
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer

---------------------------------------------------------------------------
-- TWEENS
---------------------------------------------------------------------------
local TI = {
    Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.45, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.50, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

---------------------------------------------------------------------------
-- PALETTE  (Liquid Glass color system)
---------------------------------------------------------------------------
local P = {
    -- Glass surfaces
    Glass        = Color3.fromRGB(255, 255, 255),   -- tinted white
    GlassDark    = Color3.fromRGB(200, 210, 240),
    GlassBlue    = Color3.fromRGB(180, 210, 255),

    -- Sidebar
    Sidebar      = Color3.fromRGB(20,  22,  45),

    -- Text
    White        = Color3.fromRGB(255, 255, 255),
    TextSoft     = Color3.fromRGB(220, 225, 245),
    TextMuted    = Color3.fromRGB(150, 160, 200),
    TextDim      = Color3.fromRGB(100, 110, 150),
    TextSection  = Color3.fromRGB(140, 155, 200),

    -- Accents (Liquid Glass gradient palette)
    Blue         = Color3.fromRGB( 60, 140, 255),
    BlueLight    = Color3.fromRGB(120, 190, 255),
    Purple       = Color3.fromRGB(140,  80, 255),
    PurpleLight  = Color3.fromRGB(190, 140, 255),
    Orange       = Color3.fromRGB(255, 150,  40),
    OrangeLight  = Color3.fromRGB(255, 200, 100),
    Pink         = Color3.fromRGB(255,  80, 160),
    PinkLight    = Color3.fromRGB(255, 150, 200),
    Green        = Color3.fromRGB( 40, 210, 130),
    GreenLight   = Color3.fromRGB(100, 240, 180),
    Teal         = Color3.fromRGB( 40, 200, 220),
    TealLight    = Color3.fromRGB(100, 230, 245),

    -- Control states
    Off          = Color3.fromRGB( 60,  65,  90),
    OffLight     = Color3.fromRGB( 80,  88, 120),

    -- Borders / lines
    Border       = Color3.fromRGB(255, 255, 255),
    BorderDark   = Color3.fromRGB(180, 190, 220),
    Line         = Color3.fromRGB(255, 255, 255),

    -- Shadows / glows
    Shadow       = Color3.fromRGB(  0,   5,  20),
    GlowBlue     = Color3.fromRGB( 60, 140, 255),
    GlowOrange   = Color3.fromRGB(255, 150,  40),
    GlowGreen    = Color3.fromRGB( 40, 210, 130),
    GlowPink     = Color3.fromRGB(255,  80, 160),
}

---------------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------------
local function New(cls, props, kids)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k] = v end
    for _,c in pairs(kids  or {}) do c.Parent = o end
    return o
end

local function Corner(p, r)
    return New("UICorner",{CornerRadius = r or UDim.new(0,14), Parent=p})
end

local function Stroke(p, col, alpha, thick)
    return New("UIStroke",{
        Color=col or P.Border,
        Transparency=1-(alpha or 0.22),
        Thickness=thick or 1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
        Parent=p
    })
end

local function Pad(p, t,b,l,r)
    return New("UIPadding",{
        PaddingTop=UDim.new(0,t or 8), PaddingBottom=UDim.new(0,b or 8),
        PaddingLeft=UDim.new(0,l or 8), PaddingRight=UDim.new(0,r or 8),
        Parent=p
    })
end

local function List(p, dir, halign, spacing)
    return New("UIListLayout",{
        FillDirection=dir or Enum.FillDirection.Vertical,
        HorizontalAlignment=halign or Enum.HorizontalAlignment.Left,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,spacing or 4),
        Parent=p
    })
end

local function Tween(inst, info, props)
    TweenService:Create(inst, info, props):Play()
end

local function Lerp(a,b,t) return a+(b-a)*t end

local function LerpColor(a,b,t)
    return Color3.new(
        Lerp(a.R,b.R,t),
        Lerp(a.G,b.G,t),
        Lerp(a.B,b.B,t)
    )
end

---------------------------------------------------------------------------
-- GLASS FRAME  (the core visual building block)
-- Creates a frosted-glass card with:
--   - semi-transparent tinted background
--   - white border with low opacity
--   - inner top shimmer line
--   - optional colored glow underneath
---------------------------------------------------------------------------
local function GlassFrame(parent, size, pos, opts)
    opts = opts or {}
    local bgAlpha   = opts.BgAlpha   or 0.82     -- transparency (higher = more transparent)
    local bgColor   = opts.BgColor   or P.Glass
    local radius    = opts.Radius    or UDim.new(0,18)
    local glow      = opts.Glow                   -- Color3 or nil
    local glowAlpha = opts.GlowAlpha or 0.55
    local zIndex    = opts.ZIndex    or 5

    -- Outer glow layer (colored bloom behind card)
    if glow then
        local glowFrame = New("Frame",{
            Size             = UDim2.new(size.X.Scale, size.X.Offset+20,
                                         size.Y.Scale, size.Y.Offset+20),
            Position         = UDim2.new(
                                  pos.X.Scale, pos.X.Offset-10,
                                  pos.Y.Scale, pos.Y.Offset-10),
            BackgroundColor3 = glow,
            BackgroundTransparency = glowAlpha,
            BorderSizePixel  = 0,
            ZIndex           = zIndex-1,
            Parent           = parent,
        })
        Corner(glowFrame, UDim.new(radius.Scale, radius.Offset+6))
    end

    -- Main glass card
    local frame = New("Frame",{
        Size             = size,
        Position         = pos,
        BackgroundColor3 = bgColor,
        BackgroundTransparency = bgAlpha,
        BorderSizePixel  = 0,
        ZIndex           = zIndex,
        ClipsDescendants = opts.Clip or false,
        Parent           = parent,
    })
    Corner(frame, radius)

    -- Border
    Stroke(frame, P.Border, opts.BorderAlpha or 0.20, 1)

    -- Inner shimmer (top highlight line)
    local shimmer = New("Frame",{
        Size             = UDim2.new(1,-8,0,1),
        Position         = UDim2.new(0,4,0,2),
        BackgroundColor3 = P.White,
        BackgroundTransparency = 0.55,
        BorderSizePixel  = 0,
        ZIndex           = zIndex+1,
        Parent           = frame,
    })
    Corner(shimmer, UDim.new(1,0))

    -- Bottom subtle gradient overlay
    local grad = New("Frame",{
        Size             = UDim2.new(1,0,1,0),
        BackgroundColor3 = P.GlassBlue,
        BackgroundTransparency = 0.92,
        BorderSizePixel  = 0,
        ZIndex           = zIndex,
        Parent           = frame,
    })
    Corner(grad, radius)
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, P.GlassBlue),
        }),
        Rotation=135,
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.7),
            NumberSequenceKeypoint.new(1,0.3),
        }),
        Parent=grad,
    })

    return frame
end

---------------------------------------------------------------------------
-- GRADIENT PILL  (for toggle ON state, sliders, active buttons)
---------------------------------------------------------------------------
local function GradientPill(parent, size, pos, colA, colB, radius, zIndex)
    local pill = New("Frame",{
        Size=size, Position=pos,
        BackgroundColor3=colA,
        BorderSizePixel=0,
        ZIndex=zIndex or 10,
        Parent=parent,
    })
    Corner(pill, radius or UDim.new(1,0))
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, colA),
            ColorSequenceKeypoint.new(1, colB or LerpColor(colA,P.White,0.4)),
        }),
        Rotation=0,
        Parent=pill,
    })
    -- Top shimmer
    local sh = New("Frame",{
        Size=UDim2.new(0.7,0,0,1),
        Position=UDim2.new(0.15,0,0,2),
        BackgroundColor3=P.White,
        BackgroundTransparency=0.5,
        BorderSizePixel=0,
        ZIndex=(zIndex or 10)+1,
        Parent=pill,
    })
    Corner(sh, UDim.new(1,0))
    return pill
end

---------------------------------------------------------------------------
-- DRAGGABLE
---------------------------------------------------------------------------
local function Draggable(win, handle)
    handle = handle or win
    local drag,ds,sp = false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; sp=win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
end

---------------------------------------------------------------------------
-- ROW BUILDER  (item row inside a section card)
---------------------------------------------------------------------------
local function Row(section, height, order)
    section._rowCount = (section._rowCount or 0) + 1
    order = order or section._rowCount
    local row = New("Frame",{
        Name="Row_"..order,
        Size=UDim2.new(1,0,0,height or 38),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        LayoutOrder=order,
        ZIndex=section._z or 8,
        Parent=section._inner,
    })
    -- separator
    if section._rowCount > 1 then
        New("Frame",{
            Size=UDim2.new(1,-4,0,1),
            Position=UDim2.new(0,2,0,0),
            BackgroundColor3=P.Line,
            BackgroundTransparency=0.88,
            BorderSizePixel=0,
            ZIndex=(section._z or 8),
            Parent=row,
        })
    end
    return row
end

local function RowLabel(row, text, z)
    return New("TextLabel",{
        Size=UDim2.new(0.52,0,1,0),
        BackgroundTransparency=1,
        Text=text,
        TextColor3=P.TextSoft,
        TextSize=12,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=z or 9,
        Parent=row,
    })
end

---------------------------------------------------------------------------
-- ███████╗ ██████╗██████╗ ███████╗███████╗███╗   ██╗
-- ██╔════╝██╔════╝██╔══██╗██╔════╝██╔════╝████╗  ██║
-- ███████╗██║     ██████╔╝█████╗  █████╗  ██╔██╗ ██║
-- ╚════██║██║     ██╔══██╗██╔══╝  ██╔══╝  ██║╚██╗██║
-- ███████║╚██████╗██║  ██║███████╗███████╗██║ ╚████║
-- ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝
---------------------------------------------------------------------------
function LiquidGlass.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, LiquidGlass)
    self.Title     = cfg.Title    or "Menu"
    self.SubTitle  = cfg.SubTitle or "v1.0"
    self.Key       = cfg.ToggleKey or Enum.KeyCode.Insert
    self.Tabs      = {}
    self.Active    = nil
    self.Open      = true

    -- ScreenGui
    local ok,gui = pcall(function()
        return New("ScreenGui",{
            Name="LG_"..math.random(1e5),
            ResetOnSpawn=false,
            ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset=true,
            Parent=CoreGui,
        })
    end)
    if not ok then
        gui = New("ScreenGui",{
            Name="LG_"..math.random(1e5),
            ResetOnSpawn=false,
            IgnoreGuiInset=true,
            Parent=LocalPlayer:WaitForChild("PlayerGui"),
        })
    end
    self._gui = gui

    -----------------------------------------------------------------
    -- BACKDROP  (full-screen frosted overlay)
    -----------------------------------------------------------------
    local backdrop = New("Frame",{
        Name="Backdrop",
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.fromRGB(8,12,30),
        BackgroundTransparency=0.45,
        BorderSizePixel=0,
        ZIndex=1,
        Parent=gui,
    })
    -- subtle radial gradient on backdrop
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30,50,120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 8, 25)),
        }),
        Rotation=45,
        Parent=backdrop,
    })
    self._backdrop = backdrop

    -----------------------------------------------------------------
    -- WINDOW  (860×520 main container)
    -----------------------------------------------------------------
    local W,H = 860,520
    local win = New("Frame",{
        Name="Window",
        Size=UDim2.new(0,W,0,H),
        Position=UDim2.new(0.5,-W/2,0.5,-H/2),
        BackgroundColor3=Color3.fromRGB(14,18,40),
        BackgroundTransparency=0.08,
        BorderSizePixel=0,
        ZIndex=2,
        ClipsDescendants=true,
        Parent=gui,
    })
    Corner(win, UDim.new(0,22))
    -- window border
    Stroke(win, P.Border, 0.18, 1)

    -- Subtle blue-purple gradient wash on window
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60,80,180)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20,25,60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40,20,80)),
        }),
        Rotation=130,
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.78),
            NumberSequenceKeypoint.new(1,0.88),
        }),
        Parent=win,
    })
    -- Top shimmer on window
    local wsh = New("Frame",{
        Size=UDim2.new(1,-10,0,1),
        Position=UDim2.new(0,5,0,2),
        BackgroundColor3=P.White,
        BackgroundTransparency=0.50,
        BorderSizePixel=0,
        ZIndex=3,
        Parent=win,
    })
    Corner(wsh, UDim.new(1,0))

    self._win = win
    Draggable(win)

    -----------------------------------------------------------------
    -- SIDEBAR  (left 175px)
    -----------------------------------------------------------------
    local sidebar = New("Frame",{
        Name="Sidebar",
        Size=UDim2.new(0,175,1,0),
        Position=UDim2.new(0,0,0,0),
        BackgroundColor3=Color3.fromRGB(10,13,32),
        BackgroundTransparency=0.05,
        BorderSizePixel=0,
        ZIndex=3,
        Parent=win,
    })
    Corner(sidebar, UDim.new(0,22))
    -- right separator
    New("Frame",{
        Size=UDim2.new(0,1,1,0),
        Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=P.Border,
        BackgroundTransparency=0.82,
        BorderSizePixel=0,
        ZIndex=4,
        Parent=sidebar,
    })

    -- Logo
    local logoZone = New("Frame",{
        Size=UDim2.new(1,0,0,64),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=4,
        Parent=sidebar,
    })
    -- Liquid glass logo badge
    local logoBadge = GlassFrame(logoZone,
        UDim2.new(0,38,0,38),
        UDim2.new(0,12,0,13),
        {BgAlpha=0.70, Radius=UDim.new(0,12), ZIndex=5,
         Glow=P.Blue, GlowAlpha=0.75}
    )
    -- gradient icon inside badge
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,P.Blue),
            ColorSequenceKeypoint.new(1,P.Purple),
        }),
        Rotation=135,
        Parent=logoBadge,
    })
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="◈",
        TextColor3=P.White,
        TextSize=20,
        Font=Enum.Font.GothamBold,
        ZIndex=6,
        Parent=logoBadge,
    })
    New("TextLabel",{
        Size=UDim2.new(1,-60,0,22),
        Position=UDim2.new(0,58,0,14),
        BackgroundTransparency=1,
        Text=self.Title,
        TextColor3=P.White,
        TextSize=15,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=5,
        Parent=logoZone,
    })
    New("TextLabel",{
        Size=UDim2.new(1,-60,0,14),
        Position=UDim2.new(0,58,0,36),
        BackgroundTransparency=1,
        Text=self.SubTitle,
        TextColor3=P.TextDim,
        TextSize=10,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=5,
        Parent=logoZone,
    })

    -- Separator line
    New("Frame",{
        Size=UDim2.new(1,-20,0,1),
        Position=UDim2.new(0,10,0,64),
        BackgroundColor3=P.Border,
        BackgroundTransparency=0.80,
        ZIndex=4,
        BorderSizePixel=0,
        Parent=sidebar,
    })

    -- Nav scroll
    local nav = New("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-120),
        Position=UDim2.new(0,0,0,68),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ZIndex=4,
        Parent=sidebar,
    })
    Pad(nav,4,4,0,0)
    List(nav,nil,nil,2)
    self._nav = nav

    -- Bottom user card
    local userCard = GlassFrame(sidebar,
        UDim2.new(1,-16,0,44),
        UDim2.new(0,8,1,-52),
        {BgAlpha=0.75, Radius=UDim.new(0,14), ZIndex=5}
    )
    -- avatar circle with gradient
    local av = New("Frame",{
        Size=UDim2.new(0,30,0,30),
        Position=UDim2.new(0,8,0.5,-15),
        BackgroundColor3=P.Blue,
        BorderSizePixel=0,
        ZIndex=6,
        Parent=userCard,
    })
    Corner(av, UDim.new(1,0))
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,P.Blue),
            ColorSequenceKeypoint.new(1,P.Purple),
        }),
        Rotation=45,
        Parent=av,
    })
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=string.sub(LocalPlayer.Name,1,1):upper(),
        TextColor3=P.White,
        TextSize=13,
        Font=Enum.Font.GothamBold,
        ZIndex=7,
        Parent=av,
    })
    New("TextLabel",{
        Size=UDim2.new(1,-48,0,16),
        Position=UDim2.new(0,46,0,6),
        BackgroundTransparency=1,
        Text=LocalPlayer.Name,
        TextColor3=P.White,
        TextSize=11,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=6,
        Parent=userCard,
    })
    -- gradient "Lifetime" badge
    local lifeBadge = GradientPill(userCard,
        UDim2.new(0,52,0,14),
        UDim2.new(0,46,0,24),
        P.Blue, P.Purple, UDim.new(1,0), 6
    )
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="Lifetime",
        TextColor3=P.White,
        TextSize=9,
        Font=Enum.Font.GothamBold,
        ZIndex=7,
        Parent=lifeBadge,
    })

    -----------------------------------------------------------------
    -- CONTENT  (right side)
    -----------------------------------------------------------------
    local content = New("Frame",{
        Name="Content",
        Size=UDim2.new(1,-175,1,0),
        Position=UDim2.new(0,175,0,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=3,
        Parent=win,
    })
    self._content = content

    -- Top bar
    local topBar = New("Frame",{
        Size=UDim2.new(1,0,0,46),
        BackgroundColor3=P.White,
        BackgroundTransparency=0.96,
        BorderSizePixel=0,
        ZIndex=4,
        Parent=content,
    })
    -- bottom line
    New("Frame",{
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=P.Border,
        BackgroundTransparency=0.82,
        BorderSizePixel=0,
        ZIndex=5,
        Parent=topBar,
    })
    self._topBar = topBar

    -- Topbar right icons  (glass pill buttons)
    local tbRight = New("Frame",{
        Size=UDim2.new(0,100,1,0),
        Position=UDim2.new(1,-100,0,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=5,
        Parent=topBar,
    })
    List(tbRight,Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Right,4)
    Pad(tbRight,0,0,0,10)
    for _, ico in ipairs({"⚙","💬","🔍"}) do
        local ib = New("TextButton",{
            Size=UDim2.new(0,28,0,28),
            BackgroundColor3=P.White,
            BackgroundTransparency=0.88,
            BorderSizePixel=0,
            Text=ico,
            TextSize=13,
            TextColor3=P.TextMuted,
            Font=Enum.Font.Gotham,
            AutoButtonColor=false,
            ZIndex=6,
            Parent=tbRight,
        })
        Corner(ib, UDim.new(1,0))
        ib.MouseEnter:Connect(function()
            Tween(ib,TI.Fast,{BackgroundTransparency=0.72})
        end)
        ib.MouseLeave:Connect(function()
            Tween(ib,TI.Fast,{BackgroundTransparency=0.88})
        end)
    end

    -- Topbar tab strip
    local tabStrip = New("Frame",{
        Size=UDim2.new(1,-116,1,0),
        Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=5,
        Parent=topBar,
    })
    List(tabStrip,Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Left,2)
    self._tabStrip = tabStrip

    -- Pane host
    local paneHost = New("Frame",{
        Size=UDim2.new(1,0,1,-46),
        Position=UDim2.new(0,0,0,46),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=3,
        ClipsDescendants=true,
        Parent=content,
    })
    self._paneHost = paneHost

    -- Toggle key
    UserInputService.InputBegan:Connect(function(i,gpe)
        if gpe then return end
        if i.KeyCode==self.Key then self:Toggle() end
    end)

    return self
end

---------------------------------------------------------------------------
-- TOGGLE WINDOW
---------------------------------------------------------------------------
function LiquidGlass:Toggle()
    self.Open = not self.Open
    if self.Open then
        self._win.Visible     = true
        self._backdrop.Visible = true
    end
    Tween(self._win, TI.Slow, {
        Size = self.Open
            and UDim2.new(0,860,0,520)
            or  UDim2.new(0,860,0,0),
        BackgroundTransparency = self.Open and 0.08 or 1,
    })
    Tween(self._backdrop, TI.Slow, {
        BackgroundTransparency = self.Open and 0.45 or 1,
    })
    task.delay(0.42,function()
        if not self.Open then
            self._win.Visible     = false
            self._backdrop.Visible = false
        end
    end)
end

---------------------------------------------------------------------------
-- ADD CATEGORY LABEL  (sidebar section header)
---------------------------------------------------------------------------
function LiquidGlass:AddCategory(name)
    local lbl = New("TextLabel",{
        Size=UDim2.new(1,-16,0,18),
        BackgroundTransparency=1,
        Text=name:upper(),
        TextColor3=P.TextDim,
        TextSize=9,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        LayoutOrder=#self.Tabs*10-5,
        ZIndex=5,
        Parent=self._nav,
    })
    Pad(lbl,4,0,16,0)
    return lbl
end

---------------------------------------------------------------------------
-- ADD TAB
---------------------------------------------------------------------------
-- Accent colors cycle for tab active indicators
local TAB_ACCENTS = {
    {P.Blue,   P.BlueLight},
    {P.Orange, P.OrangeLight},
    {P.Pink,   P.PinkLight},
    {P.Green,  P.GreenLight},
    {P.Purple, P.PurpleLight},
    {P.Teal,   P.TealLight},
}

function LiquidGlass:AddTab(cfg)
    cfg = cfg or {}
    local name = cfg.Name or ("Tab "..(#self.Tabs+1))
    local icon = cfg.Icon or "●"
    local acIdx = (#self.Tabs % #TAB_ACCENTS)+1
    local acA,acB = TAB_ACCENTS[acIdx][1], TAB_ACCENTS[acIdx][2]

    ---------------------------------------------------------------
    -- Sidebar nav button
    ---------------------------------------------------------------
    local navBtn = New("TextButton",{
        Size=UDim2.new(1,-12,0,36),
        BackgroundColor3=P.White,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Text="",
        AutoButtonColor=false,
        LayoutOrder=#self.Tabs*10+1,
        ZIndex=5,
        Parent=self._nav,
    })
    Corner(navBtn, UDim.new(0,12))
    Pad(navBtn,0,0,8,8)

    -- Active background (gradient pill) — hidden by default
    local navBg = New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=acA,
        BackgroundTransparency=0.80,
        BorderSizePixel=0,
        ZIndex=5,
        Parent=navBtn,
    })
    Corner(navBg, UDim.new(0,12))
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,acA),
            ColorSequenceKeypoint.new(1,acB),
        }),
        Rotation=90,
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.75),
            NumberSequenceKeypoint.new(1,0.90),
        }),
        Parent=navBg,
    })
    navBg.Visible = false

    -- Colored left accent bar
    local acBar = GradientPill(navBtn,
        UDim2.new(0,3,0.55,0),
        UDim2.new(0,0,0.225,0),
        acA, acB, UDim.new(1,0), 6
    )
    acBar.Visible = false

    -- Icon badge  (small glass square)
    local iconBadge = New("Frame",{
        Size=UDim2.new(0,22,0,22),
        Position=UDim2.new(0,4,0.5,-11),
        BackgroundColor3=acA,
        BackgroundTransparency=0.80,
        BorderSizePixel=0,
        ZIndex=6,
        Parent=navBtn,
    })
    Corner(iconBadge, UDim.new(0,7))
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=icon,
        TextColor3=acA,
        TextSize=11,
        Font=Enum.Font.Gotham,
        ZIndex=7,
        Parent=iconBadge,
    })

    local navLbl = New("TextLabel",{
        Size=UDim2.new(1,-34,1,0),
        Position=UDim2.new(0,30,0,0),
        BackgroundTransparency=1,
        Text=name,
        TextColor3=P.TextMuted,
        TextSize=12,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=6,
        Parent=navBtn,
    })

    ---------------------------------------------------------------
    -- Topbar tab pill
    ---------------------------------------------------------------
    local topPill = New("TextButton",{
        Size=UDim2.new(0,0,0,30),
        AutomaticSize=Enum.AutomaticSize.X,
        BackgroundColor3=P.White,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Text="",
        AutoButtonColor=false,
        ZIndex=6,
        Parent=self._tabStrip,
    })
    Corner(topPill, UDim.new(0,10))
    Pad(topPill,0,0,12,12)
    local topPillBg = New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=acA,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=6,
        Parent=topPill,
    })
    Corner(topPillBg, UDim.new(0,10))
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,acA),
            ColorSequenceKeypoint.new(1,acB),
        }),
        Rotation=90,
        Parent=topPillBg,
    })
    local topPillLbl = New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=name,
        TextColor3=P.TextMuted,
        TextSize=12,
        Font=Enum.Font.Gotham,
        ZIndex=7,
        Parent=topPill,
    })

    ---------------------------------------------------------------
    -- Content pane  (two-column scrolling layout)
    ---------------------------------------------------------------
    local pane = New("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=3,
        ScrollBarImageColor3=P.Border,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false,
        ZIndex=4,
        Parent=self._paneHost,
    })
    Pad(pane,14,14,14,14)

    local colHost = New("Frame",{
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=4,
        Parent=pane,
    })
    List(colHost,Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Left,12)

    local colL = New("Frame",{
        Size=UDim2.new(0.5,-6,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        LayoutOrder=1,
        ZIndex=4,
        Parent=colHost,
    })
    List(colL,nil,nil,10)

    local colR = New("Frame",{
        Size=UDim2.new(0.5,-6,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        LayoutOrder=2,
        ZIndex=4,
        Parent=colHost,
    })
    List(colR,nil,nil,10)

    local tab = {
        Name=name, Icon=icon,
        AccentA=acA, AccentB=acB,
        NavBtn=navBtn, NavBg=navBg, AcBar=acBar,
        NavLbl=navLbl, IconBadge=iconBadge,
        TopPill=topPill, TopPillBg=topPillBg, TopPillLbl=topPillLbl,
        Pane=pane, ColL=colL, ColR=colR,
        Sections={},
    }
    table.insert(self.Tabs, tab)

    -- Click handlers
    local function sel() self:SelectTab(tab) end
    navBtn.MouseButton1Click:Connect(sel)
    topPill.MouseButton1Click:Connect(sel)

    -- Hover
    navBtn.MouseEnter:Connect(function()
        if self.Active~=tab then
            Tween(navBtn,TI.Fast,{BackgroundTransparency=0.94})
        end
    end)
    navBtn.MouseLeave:Connect(function()
        if self.Active~=tab then
            Tween(navBtn,TI.Fast,{BackgroundTransparency=1})
        end
    end)

    if #self.Tabs==1 then self:SelectTab(tab) end
    return tab
end

---------------------------------------------------------------------------
-- SELECT TAB
---------------------------------------------------------------------------
function LiquidGlass:SelectTab(tab)
    for _,t in ipairs(self.Tabs) do
        t.Pane.Visible         = false
        t.NavBg.Visible        = false
        t.AcBar.Visible        = false
        t.TopPillBg.BackgroundTransparency = 1
        Tween(t.NavLbl,TI.Fast,{TextColor3=P.TextMuted, TextSize=12})
        t.NavLbl.Font          = Enum.Font.Gotham
        Tween(t.TopPillLbl,TI.Fast,{TextColor3=P.TextMuted})
        t.TopPillLbl.Font      = Enum.Font.Gotham
        Tween(t.IconBadge,TI.Fast,{BackgroundTransparency=0.80})
        t.IconBadge:FindFirstChildOfClass("TextLabel").TextColor3 = t.AccentA
    end
    tab.Pane.Visible   = true
    tab.NavBg.Visible  = true
    tab.AcBar.Visible  = true
    Tween(tab.TopPillBg,TI.Fast,{BackgroundTransparency=0.18})
    Tween(tab.NavLbl,TI.Fast,{TextColor3=P.White, TextSize=12})
    tab.NavLbl.Font    = Enum.Font.GothamBold
    Tween(tab.TopPillLbl,TI.Fast,{TextColor3=P.White})
    tab.TopPillLbl.Font= Enum.Font.GothamBold
    Tween(tab.IconBadge,TI.Fast,{BackgroundTransparency=0.55})
    tab.IconBadge:FindFirstChildOfClass("TextLabel").TextColor3 = P.White
    self.Active = tab
end

---------------------------------------------------------------------------
-- ADD SECTION  (glass card inside a column)
---------------------------------------------------------------------------
function LiquidGlass:AddSection(tab, cfg)
    cfg = cfg or {}
    local title  = cfg.Title  or "Section"
    local col    = cfg.Column or "Left"
    local acA    = cfg.AccentA or tab.AccentA
    local acB    = cfg.AccentB or tab.AccentB
    local parent = col=="Right" and tab.ColR or tab.ColL

    -- Glass card
    local card = GlassFrame(parent,
        UDim2.new(1,0,0,0),
        UDim2.new(0,0,0,0),
        {BgAlpha=0.82, BgColor=P.Glass,
         Radius=UDim.new(0,16), ZIndex=6,
         BorderAlpha=0.16}
    )
    card.AutomaticSize = Enum.AutomaticSize.Y

    -- Subtle colored top accent strip
    local strip = New("Frame",{
        Size=UDim2.new(1,0,0,2),
        Position=UDim2.new(0,0,0,0),
        BackgroundColor3=acA,
        BackgroundTransparency=0.35,
        BorderSizePixel=0,
        ZIndex=7,
        Parent=card,
    })
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,acA),
            ColorSequenceKeypoint.new(0.6,acB),
            ColorSequenceKeypoint.new(1,P.White),
        }),
        Rotation=0,
        Parent=strip,
    })
    -- round only top corners of strip
    Corner(strip, UDim.new(0,16))

    local inner = New("Frame",{
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=7,
        Parent=card,
    })
    Pad(inner,8,10,12,12)
    List(inner,nil,nil,0)

    -- Section header row
    local hdr = New("Frame",{
        Size=UDim2.new(1,0,0,20),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        LayoutOrder=0,
        ZIndex=8,
        Parent=inner,
    })
    -- Tiny colored dot
    local dot = New("Frame",{
        Size=UDim2.new(0,6,0,6),
        Position=UDim2.new(0,0,0.5,-3),
        BackgroundColor3=acA,
        BorderSizePixel=0,
        ZIndex=9,
        Parent=hdr,
    })
    Corner(dot, UDim.new(1,0))
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,acA),
            ColorSequenceKeypoint.new(1,acB),
        }),
        Rotation=45,
        Parent=dot,
    })
    New("TextLabel",{
        Size=UDim2.new(1,-14,1,0),
        Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1,
        Text=title:upper(),
        TextColor3=P.TextSection,
        TextSize=9,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=9,
        Parent=hdr,
    })

    local section = {
        _card=card, _inner=inner,
        _acA=acA, _acB=acB,
        _rowCount=0, _z=8,
    }
    table.insert(tab.Sections, section)
    return section
end

---------------------------------------------------------------------------
-- ████████╗ ██████╗  ██████╗  ██████╗ ██╗     ███████╗
-- ╚══██╔══╝██╔═══██╗██╔════╝ ██╔════╝ ██║     ██╔════╝
--    ██║   ██║   ██║██║  ███╗██║  ███╗██║     █████╗
--    ██║   ██║   ██║██║   ██║██║   ██║██║     ██╔══╝
--    ██║   ╚██████╔╝╚██████╔╝╚██████╔╝███████╗███████╗
--    ╚═╝    ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- TOGGLE  (animated gradient pill)
---------------------------------------------------------------------------
function LiquidGlass:AddToggle(sec, cfg)
    cfg = cfg or {}
    local label = cfg.Label or "Toggle"
    local state = cfg.Default ~= false
    local cb    = cfg.Callback or function() end
    local acA   = cfg.AccentA or sec._acA
    local acB   = cfg.AccentB or sec._acB

    local row = Row(sec, 38)
    RowLabel(row, label, sec._z+1)

    -- Pill container
    local pillW,pillH = 48,26
    local pillOuter = New("Frame",{
        Size=UDim2.new(0,pillW,0,pillH),
        Position=UDim2.new(1,-(pillW+2),0.5,-pillH/2),
        BackgroundColor3=P.Off,
        BackgroundTransparency=0,
        BorderSizePixel=0,
        ZIndex=sec._z+2,
        Parent=row,
    })
    Corner(pillOuter, UDim.new(1,0))
    Stroke(pillOuter, P.Border, 0.12, 1)

    -- ON gradient fill (slides in/out)
    local pillOn = GradientPill(pillOuter,
        UDim2.new(1,0,1,0),
        UDim2.new(0,0,0,0),
        acA, acB, UDim.new(1,0), sec._z+3
    )
    pillOn.BackgroundTransparency = state and 0 or 1
    pillOn.Size = state and UDim2.new(1,0,1,0) or UDim2.new(0,0,1,0)

    -- Glow behind pill when ON
    local pillGlow = New("Frame",{
        Size=UDim2.new(1,8,1,8),
        Position=UDim2.new(0,-4,0,-4),
        BackgroundColor3=acA,
        BackgroundTransparency=state and 0.55 or 1,
        BorderSizePixel=0,
        ZIndex=sec._z+1,
        Parent=pillOuter,
    })
    Corner(pillGlow, UDim.new(1,0))

    -- Knob (white circle)
    local knobS = 20
    local knob = New("Frame",{
        Size=UDim2.new(0,knobS,0,knobS),
        Position=state
            and UDim2.new(1,-(knobS+3),0.5,-knobS/2)
            or  UDim2.new(0,3,0.5,-knobS/2),
        BackgroundColor3=P.White,
        BorderSizePixel=0,
        ZIndex=sec._z+4,
        Parent=pillOuter,
    })
    Corner(knob, UDim.new(1,0))
    -- knob shadow
    New("UIStroke",{Color=P.Shadow,Transparency=0.65,Thickness=1,Parent=knob})

    -- Click area
    local btn = New("TextButton",{
        Size=UDim2.new(1,10,1,10),
        Position=UDim2.new(0,-5,0,-5),
        BackgroundTransparency=1,
        Text="",
        ZIndex=sec._z+5,
        Parent=pillOuter,
    })

    local function set(val, fire)
        state = val
        if state then
            Tween(pillOn, TI.Medium,{
                Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=0,
            })
            Tween(knob,   TI.Medium,{Position=UDim2.new(1,-(knobS+3),0.5,-knobS/2)})
            Tween(pillGlow,TI.Medium,{BackgroundTransparency=0.55})
            Tween(pillOuter,TI.Medium,{BackgroundColor3=LerpColor(acA,P.Off,0.3)})
        else
            Tween(pillOn, TI.Medium,{
                Size=UDim2.new(0,0,1,0),
                BackgroundTransparency=1,
            })
            Tween(knob,   TI.Medium,{Position=UDim2.new(0,3,0.5,-knobS/2)})
            Tween(pillGlow,TI.Medium,{BackgroundTransparency=1})
            Tween(pillOuter,TI.Medium,{BackgroundColor3=P.Off})
        end
        if fire then cb(state) end
    end

    btn.MouseButton1Click:Connect(function() set(not state, true) end)

    return {
        Type="Toggle",
        Get=function() return state end,
        Set=function(_,v) set(v,false) end,
    }
end

---------------------------------------------------------------------------
-- CHECKBOX  (square tick box — distinct from toggle)
---------------------------------------------------------------------------
function LiquidGlass:AddCheckbox(sec, cfg)
    cfg = cfg or {}
    local label = cfg.Label or "Checkbox"
    local state = cfg.Default ~= false
    local cb    = cfg.Callback or function() end
    local acA   = cfg.AccentA or sec._acA
    local acB   = cfg.AccentB or sec._acB

    local row = Row(sec, 36)
    RowLabel(row, label, sec._z+1)

    local boxS = 20
    local box = New("Frame",{
        Size=UDim2.new(0,boxS,0,boxS),
        Position=UDim2.new(1,-(boxS+4),0.5,-boxS/2),
        BackgroundColor3=state and acA or P.Off,
        BorderSizePixel=0,
        ZIndex=sec._z+2,
        Parent=row,
    })
    Corner(box, UDim.new(0,6))
    Stroke(box, P.Border, 0.15, 1)

    -- Gradient fill when ON
    if state then
        New("UIGradient",{
            Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,acA),
                ColorSequenceKeypoint.new(1,acB),
            }),
            Rotation=135,
            Parent=box,
        })
    end

    -- Checkmark
    local tick = New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="✓",
        TextColor3=P.White,
        TextSize=13,
        Font=Enum.Font.GothamBold,
        TextTransparency=state and 0 or 1,
        ZIndex=sec._z+3,
        Parent=box,
    })

    -- Glow
    local boxGlow = New("Frame",{
        Size=UDim2.new(1,8,1,8),
        Position=UDim2.new(0,-4,0,-4),
        BackgroundColor3=acA,
        BackgroundTransparency=state and 0.60 or 1,
        BorderSizePixel=0,
        ZIndex=sec._z+1,
        Parent=box,
    })
    Corner(boxGlow, UDim.new(0,10))

    local btn = New("TextButton",{
        Size=UDim2.new(1,10,1,10),
        Position=UDim2.new(0,-5,0,-5),
        BackgroundTransparency=1,
        Text="",
        ZIndex=sec._z+4,
        Parent=box,
    })

    local uig -- gradient instance ref
    local function set(val, fire)
        state = val
        if state then
            if uig then uig:Destroy() end
            uig = New("UIGradient",{
                Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,acA),
                    ColorSequenceKeypoint.new(1,acB),
                }),
                Rotation=135,
                Parent=box,
            })
            Tween(box,     TI.Fast,{BackgroundColor3=acA})
            Tween(tick,    TI.Fast,{TextTransparency=0})
            Tween(boxGlow, TI.Fast,{BackgroundTransparency=0.60})
        else
            if uig then uig:Destroy() uig=nil end
            Tween(box,     TI.Fast,{BackgroundColor3=P.Off})
            Tween(tick,    TI.Fast,{TextTransparency=1})
            Tween(boxGlow, TI.Fast,{BackgroundTransparency=1})
        end
        if fire then cb(state) end
    end

    btn.MouseButton1Click:Connect(function() set(not state,true) end)

    return {
        Type="Checkbox",
        Get=function() return state end,
        Set=function(_,v) set(v,false) end,
    }
end

---------------------------------------------------------------------------
-- SLIDER  (liquid glass styled, gradient fill + glowing knob)
---------------------------------------------------------------------------
function LiquidGlass:AddSlider(sec, cfg)
    cfg = cfg or {}
    local label  = cfg.Label   or "Slider"
    local min    = cfg.Min     or 0
    local max    = cfg.Max     or 100
    local val    = math.clamp(cfg.Default or min, min, max)
    local step   = cfg.Step    or 1
    local suffix = cfg.Suffix  or ""
    local cb     = cfg.Callback or function() end
    local acA    = cfg.AccentA or sec._acA
    local acB    = cfg.AccentB or sec._acB

    local row = Row(sec, 50)

    -- Label + value row
    local topR = New("Frame",{
        Size=UDim2.new(1,0,0,18),
        Position=UDim2.new(0,0,0,4),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=sec._z+1,
        Parent=row,
    })
    RowLabel(topR, label, sec._z+2)
    local valLbl = New("TextLabel",{
        Size=UDim2.new(0.48,0,1,0),
        Position=UDim2.new(0.52,0,0,0),
        BackgroundTransparency=1,
        Text=tostring(val)..suffix,
        TextColor3=acA,
        TextSize=12,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=sec._z+2,
        Parent=topR,
    })

    -- Track
    local trackH = 7
    local track = New("Frame",{
        Size=UDim2.new(1,0,0,trackH),
        Position=UDim2.new(0,0,1,-trackH-5),
        BackgroundColor3=P.White,
        BackgroundTransparency=0.88,
        BorderSizePixel=0,
        ZIndex=sec._z+2,
        Parent=row,
    })
    Corner(track, UDim.new(1,0))
    Stroke(track, P.Border, 0.08, 1)

    -- Fill (gradient)
    local function pct() return (val-min)/(max-min) end
    local fill = New("Frame",{
        Size=UDim2.new(pct(),0,1,0),
        BackgroundColor3=acA,
        BorderSizePixel=0,
        ZIndex=sec._z+3,
        Parent=track,
    })
    Corner(fill, UDim.new(1,0))
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,acA),
            ColorSequenceKeypoint.new(1,acB),
        }),
        Parent=fill,
    })
    -- shimmer on fill
    local fsh = New("Frame",{
        Size=UDim2.new(1,0,0,2),
        Position=UDim2.new(0,0,0,1),
        BackgroundColor3=P.White,
        BackgroundTransparency=0.55,
        BorderSizePixel=0,
        ZIndex=sec._z+4,
        Parent=fill,
    })
    Corner(fsh, UDim.new(1,0))

    -- Knob
    local kS = 16
    local knob = New("Frame",{
        Size=UDim2.new(0,kS,0,kS),
        Position=UDim2.new(pct(),-kS/2,0.5,-kS/2),
        BackgroundColor3=P.White,
        BorderSizePixel=0,
        ZIndex=sec._z+5,
        Parent=track,
    })
    Corner(knob, UDim.new(1,0))
    -- colored knob ring
    New("UIStroke",{Color=acA,Transparency=0.25,Thickness=2,Parent=knob})
    -- knob inner dot
    local kDot = New("Frame",{
        Size=UDim2.new(0,6,0,6),
        Position=UDim2.new(0.5,-3,0.5,-3),
        BackgroundColor3=acA,
        BorderSizePixel=0,
        ZIndex=sec._z+6,
        Parent=knob,
    })
    Corner(kDot, UDim.new(1,0))
    -- knob glow
    local kGlow = New("Frame",{
        Size=UDim2.new(1,8,1,8),
        Position=UDim2.new(0,-4,0,-4),
        BackgroundColor3=acA,
        BackgroundTransparency=0.65,
        BorderSizePixel=0,
        ZIndex=sec._z+4,
        Parent=knob,
    })
    Corner(kGlow, UDim.new(1,0))

    -- Input overlay
    local inpArea = New("TextButton",{
        Size=UDim2.new(1,20,2,20),
        Position=UDim2.new(0,-10,-0.5,-10),
        BackgroundTransparency=1,
        Text="",
        ZIndex=sec._z+7,
        Parent=track,
    })

    local sliding = false
    local function upd(x)
        local ap = track.AbsolutePosition
        local aw = track.AbsoluteSize.X
        local r  = math.clamp((x-ap.X)/aw,0,1)
        local raw = min + r*(max-min)
        val = math.floor(raw/step+0.5)*step
        val = math.clamp(val,min,max)
        local p = pct()
        fill.Size     = UDim2.new(p,0,1,0)
        knob.Position = UDim2.new(p,-kS/2,0.5,-kS/2)
        valLbl.Text   = tostring(val)..suffix
        cb(val)
    end

    inpArea.MouseButton1Down:Connect(function(_,y) sliding=true end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
            upd(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
    end)

    -- Hover expand knob
    inpArea.MouseEnter:Connect(function()
        Tween(knob,TI.Fast,{Size=UDim2.new(0,kS+4,0,kS+4),
            Position=UDim2.new(pct(),-(kS+4)/2,0.5,-(kS+4)/2)})
        Tween(kGlow,TI.Fast,{BackgroundTransparency=0.45})
    end)
    inpArea.MouseLeave:Connect(function()
        Tween(knob,TI.Fast,{Size=UDim2.new(0,kS,0,kS),
            Position=UDim2.new(pct(),-kS/2,0.5,-kS/2)})
        Tween(kGlow,TI.Fast,{BackgroundTransparency=0.65})
    end)

    return {
        Type="Slider",
        Get=function() return val end,
        Set=function(_,v)
            val=math.clamp(v,min,max)
            local p=pct()
            fill.Size=UDim2.new(p,0,1,0)
            knob.Position=UDim2.new(p,-kS/2,0.5,-kS/2)
            valLbl.Text=tostring(val)..suffix
        end,
    }
end

---------------------------------------------------------------------------
-- COMBOBOX  (glass dropdown)
---------------------------------------------------------------------------
function LiquidGlass:AddComboBox(sec, cfg)
    cfg = cfg or {}
    local label   = cfg.Label   or "Dropdown"
    local opts    = cfg.Options  or {}
    local sel     = cfg.Default  or opts[1]
    local cb      = cfg.Callback or function() end
    local acA     = cfg.AccentA or sec._acA
    local acB     = cfg.AccentB or sec._acB
    local isOpen  = false

    local row = Row(sec, 38)
    RowLabel(row, label, sec._z+1)

    local BW = 125
    -- Glass button
    local dropBtn = GlassFrame(row,
        UDim2.new(0,BW,0,27),
        UDim2.new(1,-(BW+2),0.5,-13.5),
        {BgAlpha=0.78, BgColor=P.Glass, Radius=UDim.new(0,10), ZIndex=sec._z+2, BorderAlpha=0.18}
    )

    local selLbl = New("TextLabel",{
        Size=UDim2.new(1,-22,1,0),
        Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,
        Text=tostring(sel),
        TextColor3=P.White,
        TextSize=11,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=sec._z+4,
        Parent=dropBtn,
    })

    -- Chevron with accent color
    local chev = New("TextLabel",{
        Size=UDim2.new(0,16,1,0),
        Position=UDim2.new(1,-18,0,0),
        BackgroundTransparency=1,
        Text="⌄",
        TextColor3=acA,
        TextSize=13,
        Font=Enum.Font.GothamBold,
        ZIndex=sec._z+4,
        Parent=dropBtn,
    })

    local clickBtn = New("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="",
        ZIndex=sec._z+5,
        Parent=dropBtn,
    })

    -- Dropdown list (glass panel)
    local listH = math.min(#opts,6)*28+10
    local list = GlassFrame(row,
        UDim2.new(0,BW,0,listH),
        UDim2.new(1,-(BW+2),1,4),
        {BgAlpha=0.12, BgColor=P.Sidebar, Radius=UDim.new(0,12),
         ZIndex=30, BorderAlpha=0.22, Clip=true}
    )
    list.Visible = false
    list.BackgroundColor3 = Color3.fromRGB(18,22,50)
    Pad(list,4,4,4,4)
    List(list,nil,nil,2)

    for _,opt in ipairs(opts) do
        local ob = New("TextButton",{
            Size=UDim2.new(1,0,0,24),
            BackgroundColor3=P.White,
            BackgroundTransparency=1,
            BorderSizePixel=0,
            Text=tostring(opt),
            TextColor3=P.TextMuted,
            TextSize=11,
            Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
            AutoButtonColor=false,
            ZIndex=32,
            Parent=list,
        })
        Corner(ob, UDim.new(0,7))
        Pad(ob,0,0,8,0)

        ob.MouseEnter:Connect(function()
            Tween(ob,TI.Fast,{BackgroundTransparency=0.88,TextColor3=P.White})
        end)
        ob.MouseLeave:Connect(function()
            Tween(ob,TI.Fast,{BackgroundTransparency=1,TextColor3=P.TextMuted})
        end)
        ob.MouseButton1Click:Connect(function()
            sel=opt
            selLbl.Text=tostring(opt)
            isOpen=false
            list.Visible=false
            Tween(chev,TI.Fast,{Rotation=0})
            cb(sel)
        end)
    end

    clickBtn.MouseButton1Click:Connect(function()
        isOpen=not isOpen
        list.Visible=isOpen
        Tween(chev,TI.Fast,{Rotation=isOpen and 180 or 0})
    end)

    return {
        Type="ComboBox",
        Get=function() return sel end,
        Set=function(_,v) sel=v; selLbl.Text=tostring(v) end,
    }
end

---------------------------------------------------------------------------
-- MULTI COMBOBOX
---------------------------------------------------------------------------
function LiquidGlass:AddMultiComboBox(sec, cfg)
    cfg = cfg or {}
    local label    = cfg.Label   or "MultiSelect"
    local opts     = cfg.Options  or {}
    local defs     = cfg.Defaults or {}
    local cb       = cfg.Callback or function() end
    local acA      = cfg.AccentA or sec._acA
    local acB      = cfg.AccentB or sec._acB
    local isOpen   = false

    local selected = {}
    for _,v in ipairs(defs) do selected[v]=true end

    local function getText()
        local p={}
        for _,o in ipairs(opts) do if selected[o] then table.insert(p,o) end end
        if #p==0 then return "None"
        elseif #p==#opts then return "All"
        elseif #p<=2 then return table.concat(p,", ")
        else return p[1]..", +"..#p-1 end
    end

    local row = Row(sec,38)
    RowLabel(row,label,sec._z+1)

    local BW=130
    local dropBtn = GlassFrame(row,
        UDim2.new(0,BW,0,27),
        UDim2.new(1,-(BW+2),0.5,-13.5),
        {BgAlpha=0.78, BgColor=P.Glass, Radius=UDim.new(0,10), ZIndex=sec._z+2, BorderAlpha=0.18}
    )
    local selLbl = New("TextLabel",{
        Size=UDim2.new(1,-22,1,0),
        Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,
        Text=getText(),
        TextColor3=P.White,
        TextSize=11,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
        ZIndex=sec._z+4,
        Parent=dropBtn,
    })
    local chev=New("TextLabel",{
        Size=UDim2.new(0,16,1,0),
        Position=UDim2.new(1,-18,0,0),
        BackgroundTransparency=1,
        Text="⌄",
        TextColor3=acA,
        TextSize=13,
        Font=Enum.Font.GothamBold,
        ZIndex=sec._z+4,
        Parent=dropBtn,
    })
    local clickBtn=New("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="",
        ZIndex=sec._z+5,
        Parent=dropBtn,
    })

    local listH=math.min(#opts,6)*30+10
    local list=GlassFrame(row,
        UDim2.new(0,BW,0,listH),
        UDim2.new(1,-(BW+2),1,4),
        {BgAlpha=0.12, BgColor=P.Sidebar, Radius=UDim.new(0,12),
         ZIndex=30, BorderAlpha=0.22, Clip=true}
    )
    list.Visible=false
    list.BackgroundColor3=Color3.fromRGB(18,22,50)
    Pad(list,4,4,4,4)
    List(list,nil,nil,2)

    for _,opt in ipairs(opts) do
        local ob=New("TextButton",{
            Size=UDim2.new(1,0,0,26),
            BackgroundColor3=P.White,
            BackgroundTransparency=1,
            BorderSizePixel=0,
            Text="",
            AutoButtonColor=false,
            ZIndex=32,
            Parent=list,
        })
        Corner(ob,UDim.new(0,7))
        Pad(ob,0,0,6,6)

        -- Mini checkbox inside dropdown
        local cbBox=New("Frame",{
            Size=UDim2.new(0,14,0,14),
            Position=UDim2.new(0,0,0.5,-7),
            BackgroundColor3=selected[opt] and acA or P.Off,
            BorderSizePixel=0,
            ZIndex=33,
            Parent=ob,
        })
        Corner(cbBox,UDim.new(0,4))
        if selected[opt] then
            New("UIGradient",{
                Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,acA),
                    ColorSequenceKeypoint.new(1,acB),
                }),
                Rotation=45,
                Parent=cbBox,
            })
        end
        local cbTick=New("TextLabel",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            Text="✓",
            TextColor3=P.White,
            TextSize=10,
            Font=Enum.Font.GothamBold,
            TextTransparency=selected[opt] and 0 or 1,
            ZIndex=34,
            Parent=cbBox,
        })
        New("TextLabel",{
            Size=UDim2.new(1,-22,1,0),
            Position=UDim2.new(0,20,0,0),
            BackgroundTransparency=1,
            Text=tostring(opt),
            TextColor3=selected[opt] and P.White or P.TextMuted,
            TextSize=11,
            Font=selected[opt] and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=33,
            Parent=ob,
        })

        ob.MouseEnter:Connect(function()
            Tween(ob,TI.Fast,{BackgroundTransparency=0.88})
        end)
        ob.MouseLeave:Connect(function()
            Tween(ob,TI.Fast,{BackgroundTransparency=1})
        end)
        ob.MouseButton1Click:Connect(function()
            selected[opt]=not selected[opt]
            local on=selected[opt]
            -- update mini checkbox
            if on then
                New("UIGradient",{
                    Color=ColorSequence.new({
                        ColorSequenceKeypoint.new(0,acA),
                        ColorSequenceKeypoint.new(1,acB),
                    }),
                    Rotation=45,
                    Parent=cbBox,
                })
            else
                local g=cbBox:FindFirstChildOfClass("UIGradient")
                if g then g:Destroy() end
            end
            Tween(cbBox,TI.Fast,{BackgroundColor3=on and acA or P.Off})
            Tween(cbTick,TI.Fast,{TextTransparency=on and 0 or 1})
            ob:FindFirstChildOfClass("TextLabel").TextColor3=on and P.White or P.TextMuted
            ob:FindFirstChildOfClass("TextLabel").Font=on and Enum.Font.GothamBold or Enum.Font.Gotham
            selLbl.Text=getText()
            cb(selected)
        end)
    end

    clickBtn.MouseButton1Click:Connect(function()
        isOpen=not isOpen
        list.Visible=isOpen
        Tween(chev,TI.Fast,{Rotation=isOpen and 180 or 0})
    end)

    return {
        Type="MultiComboBox",
        Get=function() return selected end,
    }
end

---------------------------------------------------------------------------
-- COLOR PICKER  (full HSV + Alpha, liquid glass styled)
---------------------------------------------------------------------------
function LiquidGlass:AddColorPicker(sec, cfg)
    cfg = cfg or {}
    local label   = cfg.Label   or "Color"
    local default = cfg.Default or Color3.fromRGB(100,160,255)
    local cb      = cfg.Callback or function() end

    local h,s,v  = Color3.toHSV(default)
    local alpha   = 1
    local cur     = default
    local isOpen  = false

    local row = Row(sec,38)
    RowLabel(row,label,sec._z+1)

    -- Swatch button (gradient preview)
    local swW,swH = 64,26
    local swOuter = New("Frame",{
        Size=UDim2.new(0,swW,0,swH),
        Position=UDim2.new(1,-(swW+2),0.5,-swH/2),
        BackgroundColor3=cur,
        BorderSizePixel=0,
        ZIndex=sec._z+2,
        Parent=row,
    })
    Corner(swOuter,UDim.new(0,10))
    Stroke(swOuter,P.Border,0.18,1)
    -- Shimmer on swatch
    local swSh=New("Frame",{
        Size=UDim2.new(1,-4,0,1),
        Position=UDim2.new(0,2,0,2),
        BackgroundColor3=P.White,
        BackgroundTransparency=0.55,
        BorderSizePixel=0,
        ZIndex=sec._z+3,
        Parent=swOuter,
    })
    Corner(swSh,UDim.new(1,0))

    local swBtn=New("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="",
        ZIndex=sec._z+4,
        Parent=swOuter,
    })

    -- Picker popup panel
    local PW,PH = 200,240
    local picker = GlassFrame(row,
        UDim2.new(0,PW,0,PH),
        UDim2.new(1,-(PW+2),1,5),
        {BgAlpha=0.08, BgColor=P.Sidebar, Radius=UDim.new(0,16),
         ZIndex=40, BorderAlpha=0.25}
    )
    picker.BackgroundColor3=Color3.fromRGB(16,20,48)
    picker.Visible=false
    Pad(picker,10,10,10,10)

    -- SV canvas
    local svS=PW-20
    local svH2=math.floor(svS*0.58)
    local sv=New("Frame",{
        Size=UDim2.new(0,svS,0,svH2),
        Position=UDim2.new(0,0,0,0),
        BackgroundColor3=Color3.fromHSV(h,1,1),
        BorderSizePixel=0,
        ZIndex=42,
        ClipsDescendants=true,
        Parent=picker,
    })
    Corner(sv,UDim.new(0,10))
    -- White→transparent (saturation)
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1,Color3.new(1,1,1)),
        }),
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(1,1),
        }),
        Parent=sv,
    })
    -- Black→transparent (value)
    local svDark=New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=43,
        Parent=sv,
    })
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(1,Color3.new(0,0,0)),
        }),
        Rotation=90,
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(1,0),
        }),
        Parent=svDark,
    })
    -- SV cursor (crosshair style)
    local svc=New("Frame",{
        Size=UDim2.new(0,12,0,12),
        Position=UDim2.new(s,-6,1-v,-6),
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=0.4,
        BorderSizePixel=0,
        ZIndex=45,
        Parent=sv,
    })
    Corner(svc,UDim.new(1,0))
    New("UIStroke",{Color=P.White,Transparency=0,Thickness=2,Parent=svc})

    -- Hue bar
    local hueH=10
    local hueColors={}
    for i=0,6 do
        table.insert(hueColors,ColorSequenceKeypoint.new(i/6,Color3.fromHSV(i/6,1,1)))
    end
    local hueBar=New("Frame",{
        Size=UDim2.new(0,svS,0,hueH),
        Position=UDim2.new(0,0,0,svH2+8),
        BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0,
        ZIndex=42,
        Parent=picker,
    })
    Corner(hueBar,UDim.new(1,0))
    New("UIGradient",{Color=ColorSequence.new(hueColors),Parent=hueBar})

    local hueCur=New("Frame",{
        Size=UDim2.new(0,4,1,4),
        Position=UDim2.new(h,-2,0,-2),
        BackgroundColor3=P.White,
        BorderSizePixel=0,
        ZIndex=43,
        Parent=hueBar,
    })
    Corner(hueCur,UDim.new(0,3))
    New("UIStroke",{Color=P.Shadow,Transparency=0.5,Thickness=1,Parent=hueCur})

    -- Alpha bar (checkerboard not possible in Roblox, use gradient)
    local alphaBar=New("Frame",{
        Size=UDim2.new(0,svS,0,hueH),
        Position=UDim2.new(0,0,0,svH2+8+hueH+6),
        BackgroundColor3=Color3.new(0,0,0),
        BorderSizePixel=0,
        ZIndex=42,
        Parent=picker,
    })
    Corner(alphaBar,UDim.new(1,0))
    New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(1,cur),
        }),
        Parent=alphaBar,
    })
    local alphaCur=New("Frame",{
        Size=UDim2.new(0,4,1,4),
        Position=UDim2.new(alpha,-2,0,-2),
        BackgroundColor3=P.White,
        BorderSizePixel=0,
        ZIndex=43,
        Parent=alphaBar,
    })
    Corner(alphaCur,UDim.new(0,3))
    New("UIStroke",{Color=P.Shadow,Transparency=0.5,Thickness=1,Parent=alphaCur})

    -- Hex + output preview
    local function toHex(c)
        return string.format("#%02X%02X%02X",
            math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255))
    end
    local outRow=New("Frame",{
        Size=UDim2.new(0,svS,0,22),
        Position=UDim2.new(0,0,1,-22),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=42,
        Parent=picker,
    })
    local outSwatch=New("Frame",{
        Size=UDim2.new(0,22,1,0),
        BackgroundColor3=cur,
        BorderSizePixel=0,
        ZIndex=43,
        Parent=outRow,
    })
    Corner(outSwatch,UDim.new(0,6))
    local outHex=New("TextLabel",{
        Size=UDim2.new(1,-28,1,0),
        Position=UDim2.new(0,26,0,0),
        BackgroundTransparency=1,
        Text=toHex(cur),
        TextColor3=P.TextSoft,
        TextSize=10,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=43,
        Parent=outRow,
    })

    local function updColor()
        cur=Color3.fromHSV(h,s,v)
        sv.BackgroundColor3=Color3.fromHSV(h,1,1)
        svc.Position=UDim2.new(s,-6,1-v,-6)
        hueCur.Position=UDim2.new(h,-2,0,-2)
        swOuter.BackgroundColor3=cur
        outSwatch.BackgroundColor3=cur
        outHex.Text=toHex(cur)
        New("UIGradient",{
            Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),
                ColorSequenceKeypoint.new(1,cur),
            }),
            Parent=alphaBar,
        })
        cb(cur,alpha)
    end

    -- SV drag
    local dSV=false
    local svBtn=New("TextButton",{Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,Text="",ZIndex=46,Parent=sv})
    svBtn.MouseButton1Down:Connect(function() dSV=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dSV=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dSV and i.UserInputType==Enum.UserInputType.MouseMovement then
            local ap=sv.AbsolutePosition; local as=sv.AbsoluteSize
            s=math.clamp((i.Position.X-ap.X)/as.X,0,1)
            v=1-math.clamp((i.Position.Y-ap.Y)/as.Y,0,1)
            updColor()
        end
    end)

    -- Hue drag
    local dHue=false
    local hueBtn=New("TextButton",{Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,Text="",ZIndex=44,Parent=hueBar})
    hueBtn.MouseButton1Down:Connect(function() dHue=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dHue=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dHue and i.UserInputType==Enum.UserInputType.MouseMovement then
            local ap=hueBar.AbsolutePosition; local as=hueBar.AbsoluteSize
            h=math.clamp((i.Position.X-ap.X)/as.X,0,1)
            updColor()
        end
    end)

    -- Alpha drag
    local dAlpha=false
    local alphaBtn=New("TextButton",{Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,Text="",ZIndex=44,Parent=alphaBar})
    alphaBtn.MouseButton1Down:Connect(function() dAlpha=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dAlpha=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dAlpha and i.UserInputType==Enum.UserInputType.MouseMovement then
            local ap=alphaBar.AbsolutePosition; local as=alphaBar.AbsoluteSize
            alpha=math.clamp((i.Position.X-ap.X)/as.X,0,1)
            alphaCur.Position=UDim2.new(alpha,-2,0,-2)
            cb(cur,alpha)
        end
    end)

    swBtn.MouseButton1Click:Connect(function()
        isOpen=not isOpen
        picker.Visible=isOpen
    end)

    return {
        Type="ColorPicker",
        Get=function() return cur,alpha end,
        Set=function(_,c,a)
            h,s,v=Color3.toHSV(c)
            if a then alpha=a end
            updColor()
        end,
    }
end

---------------------------------------------------------------------------
-- KEYBINDER
---------------------------------------------------------------------------
function LiquidGlass:AddKeybind(sec, cfg)
    cfg = cfg or {}
    local label   = cfg.Label   or "Keybind"
    local bound   = cfg.Default or Enum.KeyCode.F
    local cb      = cfg.Callback or function() end
    local acA     = cfg.AccentA or sec._acA
    local listening = false

    local row = Row(sec,38)
    RowLabel(row,label,sec._z+1)

    local BW=82
    -- Liquid glass key badge
    local keyFrame = GlassFrame(row,
        UDim2.new(0,BW,0,26),
        UDim2.new(1,-(BW+2),0.5,-13),
        {BgAlpha=0.78, BgColor=P.Glass, Radius=UDim.new(0,10), ZIndex=sec._z+2, BorderAlpha=0.18}
    )

    local keyLbl=New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="[ "..bound.Name.." ]",
        TextColor3=acA,
        TextSize=11,
        Font=Enum.Font.GothamBold,
        ZIndex=sec._z+4,
        Parent=keyFrame,
    })

    local keyBtn=New("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="",
        ZIndex=sec._z+5,
        Parent=keyFrame,
    })

    -- Listening pulse
    local pulse
    local function startPulse()
        pulse = RunService.Heartbeat:Connect(function(dt)
            local t = tick()%1
            local tr = 0.5+0.4*math.sin(t*math.pi*2)
            keyFrame.BackgroundTransparency = tr
        end)
    end
    local function stopPulse()
        if pulse then pulse:Disconnect(); pulse=nil end
        keyFrame.BackgroundTransparency = 0.78
    end

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening=true
        keyLbl.Text="[ ??? ]"
        keyLbl.TextColor3=P.Orange
        startPulse()
    end)

    UserInputService.InputBegan:Connect(function(i,gpe)
        if listening and i.UserInputType==Enum.UserInputType.Keyboard then
            bound=i.KeyCode
            keyLbl.Text="[ "..bound.Name.." ]"
            keyLbl.TextColor3=acA
            stopPulse()
            listening=false
        elseif not gpe and not listening and i.KeyCode==bound then
            cb(bound)
        end
    end)

    return {
        Type="Keybind",
        Get=function() return bound end,
        Set=function(_,k) bound=k; keyLbl.Text="[ "..k.Name.." ]" end,
    }
end

---------------------------------------------------------------------------
-- BUTTON  (gradient pill button)
---------------------------------------------------------------------------
function LiquidGlass:AddButton(sec, cfg)
    cfg = cfg or {}
    local label = cfg.Label or ""
    local text  = cfg.Text  or "Click"
    local cb    = cfg.Callback or function() end
    local acA   = cfg.AccentA or sec._acA
    local acB   = cfg.AccentB or sec._acB

    local row = Row(sec,38)
    if label~="" then RowLabel(row,label,sec._z+1) end

    local BW = label~="" and 90 or 120
    local XP = label~="" and -(BW+2) or -(BW+2)

    local pill = GradientPill(row,
        UDim2.new(0,BW,0,27),
        UDim2.new(1,XP,0.5,-13.5),
        acA, acB, UDim.new(0,10), sec._z+2
    )
    Stroke(pill,P.Border,0.12,1)
    -- glow
    local pillGlow=New("Frame",{
        Size=UDim2.new(1,10,1,10),
        Position=UDim2.new(0,-5,0,-5),
        BackgroundColor3=acA,
        BackgroundTransparency=0.72,
        BorderSizePixel=0,
        ZIndex=sec._z+1,
        Parent=pill,
    })
    Corner(pillGlow,UDim.new(0,14))

    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=text,
        TextColor3=P.White,
        TextSize=11,
        Font=Enum.Font.GothamBold,
        ZIndex=sec._z+4,
        Parent=pill,
    })

    local btn=New("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="",
        ZIndex=sec._z+5,
        Parent=pill,
    })

    btn.MouseEnter:Connect(function()
        Tween(pillGlow,TI.Fast,{BackgroundTransparency=0.55})
        Tween(pill,TI.Fast,{BackgroundTransparency=0})
    end)
    btn.MouseLeave:Connect(function()
        Tween(pillGlow,TI.Fast,{BackgroundTransparency=0.72})
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(pill,TI.Fast,{
            Size=UDim2.new(0,BW-4,0,25),
            Position=UDim2.new(1,XP+2,0.5,-12.5),
        })
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(pill,TI.Bounce,{
            Size=UDim2.new(0,BW,0,27),
            Position=UDim2.new(1,XP,0.5,-13.5),
        })
        cb()
    end)

    return {Type="Button"}
end

---------------------------------------------------------------------------
-- TEXT INPUT
---------------------------------------------------------------------------
function LiquidGlass:AddTextInput(sec, cfg)
    cfg = cfg or {}
    local label = cfg.Label or "Input"
    local ph    = cfg.Placeholder or "..."
    local def   = cfg.Default or ""
    local cb    = cfg.Callback or function() end
    local acA   = cfg.AccentA or sec._acA

    local row = Row(sec,38)
    RowLabel(row,label,sec._z+1)

    local BW=130
    local inpFrame = GlassFrame(row,
        UDim2.new(0,BW,0,26),
        UDim2.new(1,-(BW+2),0.5,-13),
        {BgAlpha=0.78, BgColor=P.Glass, Radius=UDim.new(0,10), ZIndex=sec._z+2, BorderAlpha=0.16}
    )
    local stroke=inpFrame:FindFirstChildOfClass("UIStroke")

    local tb=New("TextBox",{
        Size=UDim2.new(1,-12,1,0),
        Position=UDim2.new(0,6,0,0),
        BackgroundTransparency=1,
        Text=def,
        PlaceholderText=ph,
        PlaceholderColor3=P.TextDim,
        TextColor3=P.White,
        TextSize=11,
        Font=Enum.Font.Gotham,
        ClearTextOnFocus=false,
        ZIndex=sec._z+4,
        Parent=inpFrame,
    })

    tb.Focused:Connect(function()
        if stroke then stroke.Color=acA; stroke.Transparency=0.4 end
        Tween(inpFrame,TI.Fast,{BackgroundTransparency=0.68})
    end)
    tb.FocusLost:Connect(function(enter)
        if stroke then stroke.Color=P.Border; stroke.Transparency=0.84 end
        Tween(inpFrame,TI.Fast,{BackgroundTransparency=0.78})
        if enter then cb(tb.Text) end
    end)

    return {
        Type="TextInput",
        Get=function() return tb.Text end,
        Set=function(_,v) tb.Text=v end,
    }
end

---------------------------------------------------------------------------
-- LABEL
---------------------------------------------------------------------------
function LiquidGlass:AddLabel(sec, cfg)
    cfg = cfg or {}
    local row = Row(sec, cfg.Height or 28)
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=cfg.Text or "",
        TextColor3=cfg.Color or P.TextMuted,
        TextSize=cfg.Size or 11,
        Font=cfg.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true,
        ZIndex=sec._z+1,
        Parent=row,
    })
end

---------------------------------------------------------------------------
-- SEPARATOR
---------------------------------------------------------------------------
function LiquidGlass:AddSeparator(sec)
    local row=Row(sec,14)
    local sep=New("Frame",{
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,0.5,0),
        BackgroundColor3=P.Line,
        BackgroundTransparency=0.82,
        BorderSizePixel=0,
        ZIndex=sec._z+1,
        Parent=row,
    })
    -- Gradient fade on separator
    New("UIGradient",{
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(0.1,0),
            NumberSequenceKeypoint.new(0.9,0),
            NumberSequenceKeypoint.new(1,1),
        }),
        Parent=sep,
    })
end

---------------------------------------------------------------------------
-- NOTIFY  (toast with liquid glass style)
---------------------------------------------------------------------------
function LiquidGlass:Notify(cfg)
    cfg = cfg or {}
    local title   = cfg.Title    or "Notice"
    local msg     = cfg.Message  or ""
    local dur     = cfg.Duration or 4
    local acA     = cfg.Accent   or P.Blue
    local acB     = cfg.AccentB  or LerpColor(acA,P.White,0.35)

    local nc = self._gui:FindFirstChild("_NC")
    if not nc then
        nc = New("Frame",{
            Name="_NC",
            Size=UDim2.new(0,310,1,0),
            Position=UDim2.new(1,-322,0,0),
            BackgroundTransparency=1,
            BorderSizePixel=0,
            ZIndex=100,
            Parent=self._gui,
        })
        Pad(nc,14,14,0,0)
        List(nc,nil,Enum.HorizontalAlignment.Right,8)
    end

    local card = GlassFrame(nc,
        UDim2.new(1,0,0,74),
        UDim2.new(0,0,0,0),
        {BgAlpha=0.10, BgColor=Color3.fromRGB(16,20,48),
         Radius=UDim.new(0,16), ZIndex=101, BorderAlpha=0.22,
         Glow=acA, GlowAlpha=0.82}
    )
    card.BackgroundColor3=Color3.fromRGB(16,20,50)

    -- Colored left bar
    local lbar=GradientPill(card,
        UDim2.new(0,3,1,-16),
        UDim2.new(0,0,0,8),
        acA, acB, UDim.new(1,0), 102
    )

    New("TextLabel",{
        Size=UDim2.new(1,-20,0,20),
        Position=UDim2.new(0,14,0,8),
        BackgroundTransparency=1,
        Text=title,
        TextColor3=P.White,
        TextSize=13,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=103,
        Parent=card,
    })
    New("TextLabel",{
        Size=UDim2.new(1,-20,0,28),
        Position=UDim2.new(0,14,0,28),
        BackgroundTransparency=1,
        Text=msg,
        TextColor3=P.TextSoft,
        TextSize=11,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true,
        ZIndex=103,
        Parent=card,
    })

    -- Progress bar
    local prog=GradientPill(card,
        UDim2.new(1,0,0,3),
        UDim2.new(0,0,1,-3),
        acA, acB, UDim.new(1,0), 103
    )
    prog.BackgroundTransparency=0.35
    TweenService:Create(prog,TweenInfo.new(dur,Enum.EasingStyle.Linear),{
        Size=UDim2.new(0,0,0,3),
    }):Play()

    -- Slide in from right
    card.Position=UDim2.new(1,20,0,0)
    Tween(card,TI.Slow,{Position=UDim2.new(0,0,0,0)})

    task.delay(dur,function()
        Tween(card,TI.Slow,{
            Position=UDim2.new(1,20,0,0),
            BackgroundTransparency=1,
        })
        task.delay(0.45,function() card:Destroy() end)
    end)

    return card
end

---------------------------------------------------------------------------
-- DESTROY
---------------------------------------------------------------------------
function LiquidGlass:Destroy()
    if self._gui then self._gui:Destroy() end
end

return LiquidGlass
