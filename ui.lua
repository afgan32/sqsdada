-- LiquidGlass UI Library
-- Style: iOS 26 Liquid Glass
-- Compatible with: Velocity, Script-Ware, and other client executors

local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Theme Configuration
local Theme = {
    -- Glass colors
    GlassBackground    = Color3.fromRGB(255, 255, 255),
    GlassBackgroundAlpha = 0.08,
    GlassBorder        = Color3.fromRGB(255, 255, 255),
    GlassBorderAlpha   = 0.25,
    GlassHighlight     = Color3.fromRGB(255, 255, 255),
    GlassHighlightAlpha= 0.15,

    -- Sidebar
    SidebarBG          = Color3.fromRGB(10, 10, 20),
    SidebarBGAlpha     = 0.75,
    SidebarAccent      = Color3.fromRGB(255, 255, 255),
    SidebarAccentAlpha = 0.05,

    -- Text
    TextPrimary        = Color3.fromRGB(255, 255, 255),
    TextSecondary      = Color3.fromRGB(180, 180, 200),
    TextMuted          = Color3.fromRGB(120, 120, 150),
    TextDark           = Color3.fromRGB(30,  30,  50),

    -- Accent / Controls
    Accent             = Color3.fromRGB(100, 160, 255),
    AccentGlow         = Color3.fromRGB(80,  140, 255),
    AccentOrange       = Color3.fromRGB(255, 160, 60),
    AccentGreen        = Color3.fromRGB(60,  220, 120),
    AccentRed          = Color3.fromRGB(255, 80,  80),

    -- Toggle / Checkbox
    ToggleOff          = Color3.fromRGB(60,  60,  80),
    ToggleOn           = Color3.fromRGB(100, 160, 255),

    -- Slider
    SliderTrack        = Color3.fromRGB(255, 255, 255),
    SliderTrackAlpha   = 0.12,
    SliderFill         = Color3.fromRGB(100, 160, 255),
    SliderKnob         = Color3.fromRGB(255, 255, 255),

    -- Dropdown
    DropdownBG         = Color3.fromRGB(20,  20,  40),
    DropdownBGAlpha    = 0.92,
    DropdownHover      = Color3.fromRGB(255, 255, 255),
    DropdownHoverAlpha = 0.06,

    -- ColorPicker
    CPBorder           = Color3.fromRGB(255, 255, 255),
    CPBorderAlpha      = 0.2,

    -- Section header
    SectionText        = Color3.fromRGB(150, 160, 200),

    -- Separator
    Separator          = Color3.fromRGB(255, 255, 255),
    SeparatorAlpha     = 0.06,

    -- Tween speeds
    TweenFast          = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenMedium        = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenOpen          = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenBounce        = TweenInfo.new(0.4,  Enum.EasingStyle.Back,  Enum.EasingDirection.Out),

    -- Sizing
    CornerRadius       = UDim.new(0, 16),
    CornerRadiusSmall  = UDim.new(0, 10),
    CornerRadiusLarge  = UDim.new(0, 20),
    CornerRadiusFull   = UDim.new(1, 0),
}

LiquidGlass.Theme = Theme

-----------------------------------------------------------------------
-- UTILITY FUNCTIONS
-----------------------------------------------------------------------

local function Create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do
        inst[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function AddCorner(parent, radius)
    return Create("UICorner", {CornerRadius = radius or Theme.CornerRadius, Parent = parent})
end

local function AddStroke(parent, color, alpha, thickness)
    return Create("UIStroke", {
        Color      = color or Theme.GlassBorder,
        Transparency = 1 - (alpha or Theme.GlassBorderAlpha),
        Thickness  = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent     = parent,
    })
end

local function AddPadding(parent, top, bottom, left, right)
    return Create("UIPadding", {
        PaddingTop    = UDim.new(0, top    or 8),
        PaddingBottom = UDim.new(0, bottom or 8),
        PaddingLeft   = UDim.new(0, left   or 8),
        PaddingRight  = UDim.new(0, right  or 8),
        Parent        = parent,
    })
end

local function AddListLayout(parent, dir, align, spacing)
    return Create("UIListLayout", {
        FillDirection      = dir   or Enum.FillDirection.Vertical,
        HorizontalAlignment= align or Enum.HorizontalAlignment.Left,
        SortOrder          = Enum.SortOrder.LayoutOrder,
        Padding            = UDim.new(0, spacing or 4),
        Parent             = parent,
    })
end

local function Tween(instance, info, props)
    return TweenService:Create(instance, info, props):Play()
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Glass frame factory
local function MakeGlassFrame(parent, size, pos, bgAlpha, cornerRadius)
    local frame = Create("Frame", {
        Size              = size or UDim2.new(1, 0, 1, 0),
        Position          = pos  or UDim2.new(0, 0, 0, 0),
        BackgroundColor3  = Theme.GlassBackground,
        BackgroundTransparency = 1 - (bgAlpha or Theme.GlassBackgroundAlpha),
        BorderSizePixel   = 0,
        ClipsDescendants  = false,
        Parent            = parent,
    })
    AddCorner(frame, cornerRadius or Theme.CornerRadius)
    AddStroke(frame)
    return frame
end

-- Shimmer highlight at top of glass panels
local function AddGlassShimmer(parent)
    local shimmer = Create("Frame", {
        Size             = UDim2.new(1, -4, 0, 1),
        Position         = UDim2.new(0, 2, 0, 1),
        BackgroundColor3 = Theme.GlassHighlight,
        BackgroundTransparency = 1 - Theme.GlassHighlightAlpha,
        BorderSizePixel  = 0,
        ZIndex           = parent.ZIndex + 1,
        Parent           = parent,
    })
    AddCorner(shimmer, UDim.new(1, 0))
    return shimmer
end

-----------------------------------------------------------------------
-- BLUR EFFECT (uses DepthOfField as blur approximation in Roblox)
-----------------------------------------------------------------------
local function CreateBlur(parent)
    -- BlurEffect only works in Lighting; we fake it with a semi-transparent
    -- layered frame approach since executors can't always add to Lighting.
    local blurLayer = Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(10, 15, 30),
        BackgroundTransparency = 0.55,
        BorderSizePixel  = 0,
        ZIndex           = 1,
        Parent           = parent,
    })
    -- Subtle noise texture overlay for glass look
    local noise = Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.97,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = parent,
    })
    return blurLayer, noise
end

-----------------------------------------------------------------------
-- WINDOW
-----------------------------------------------------------------------
function LiquidGlass.new(config)
    config = config or {}

    local self = setmetatable({}, LiquidGlass)
    self.Title        = config.Title   or "LiquidGlass"
    self.SubTitle     = config.SubTitle or "v1.0"
    self.ToggleKey    = config.ToggleKey or Enum.KeyCode.Insert
    self.Tabs         = {}
    self.ActiveTab    = nil
    self.Visible      = true
    self.Callbacks    = {}

    -- Root ScreenGui
    local ok, gui = pcall(function()
        return Create("ScreenGui", {
            Name           = "LiquidGlassUI_" .. math.random(1e6),
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
            Parent         = CoreGui,
        })
    end)
    if not ok then
        gui = Create("ScreenGui", {
            Name           = "LiquidGlassUI_" .. math.random(1e6),
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
            Parent         = LocalPlayer:WaitForChild("PlayerGui"),
        })
    end
    self.Gui = gui

    -- Main container (full screen dim)
    local screenDim = Create("Frame", {
        Name             = "ScreenDim",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        BorderSizePixel  = 0,
        ZIndex           = 1,
        Parent           = gui,
    })
    self.ScreenDim = screenDim

    -- Window frame
    local windowSize = UDim2.new(0, 860, 0, 520)
    local window = Create("Frame", {
        Name             = "Window",
        Size             = windowSize,
        Position         = UDim2.new(0.5, -430, 0.5, -260),
        BackgroundColor3 = Color3.fromRGB(12, 14, 28),
        BackgroundTransparency = 0.05,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        ClipsDescendants = true,
        Parent           = gui,
    })
    AddCorner(window, Theme.CornerRadiusLarge)
    AddStroke(window, Theme.GlassBorder, 0.18, 1)
    self.Window = window

    -- Window glass shimmer
    AddGlassShimmer(window)

    -- Make draggable by title bar area
    MakeDraggable(window)

    -- ===== SIDEBAR =====
    local sidebar = Create("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 180, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.SidebarBG,
        BackgroundTransparency = 1 - Theme.SidebarBGAlpha,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = window,
    })
    -- Only round left corners
    AddCorner(sidebar, Theme.CornerRadiusLarge)

    -- Sidebar right separator line
    Create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Separator,
        BackgroundTransparency = 1 - Theme.SeparatorAlpha,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = sidebar,
    })

    -- Logo area
    local logoArea = Create("Frame", {
        Name             = "LogoArea",
        Size             = UDim2.new(1, 0, 0, 60),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = sidebar,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, -24, 0, 28),
        Position         = UDim2.new(0, 16, 0, 16),
        BackgroundTransparency = 1,
        Text             = self.Title,
        TextColor3       = Theme.TextPrimary,
        TextSize         = 18,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 5,
        Parent           = logoArea,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, -24, 0, 14),
        Position         = UDim2.new(0, 16, 0, 42),
        BackgroundTransparency = 1,
        Text             = self.SubTitle,
        TextColor3       = Theme.TextMuted,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 5,
        Parent           = logoArea,
    })

    -- Sidebar separator under logo
    Create("Frame", {
        Size             = UDim2.new(1, -24, 0, 1),
        Position         = UDim2.new(0, 12, 0, 60),
        BackgroundColor3 = Theme.Separator,
        BackgroundTransparency = 1 - Theme.SeparatorAlpha,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = sidebar,
    })

    -- Sidebar nav scroll
    local sidebarNav = Create("ScrollingFrame", {
        Name             = "Nav",
        Size             = UDim2.new(1, 0, 1, -120),
        Position         = UDim2.new(0, 0, 0, 64),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 0,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex           = 4,
        Parent           = sidebar,
    })
    AddPadding(sidebarNav, 4, 4, 0, 0)
    AddListLayout(sidebarNav, nil, nil, 2)
    self.SidebarNav = sidebarNav

    -- Bottom user badge
    local userBadge = Create("Frame", {
        Name             = "UserBadge",
        Size             = UDim2.new(1, 0, 0, 52),
        Position         = UDim2.new(0, 0, 1, -52),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = sidebar,
    })
    -- separator above
    Create("Frame", {
        Size             = UDim2.new(1, -24, 0, 1),
        Position         = UDim2.new(0, 12, 0, 0),
        BackgroundColor3 = Theme.Separator,
        BackgroundTransparency = 1 - Theme.SeparatorAlpha,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = userBadge,
    })
    -- Avatar circle
    local avatarCircle = Create("Frame", {
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 12, 0, 10),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.5,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = userBadge,
    })
    AddCorner(avatarCircle, UDim.new(1, 0))
    Create("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = string.sub(LocalPlayer.Name, 1, 1):upper(),
        TextColor3       = Theme.TextPrimary,
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 6,
        Parent           = avatarCircle,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, -56, 0, 16),
        Position         = UDim2.new(0, 52, 0, 10),
        BackgroundTransparency = 1,
        Text             = LocalPlayer.Name,
        TextColor3       = Theme.TextPrimary,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 5,
        Parent           = userBadge,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, -56, 0, 12),
        Position         = UDim2.new(0, 52, 0, 28),
        BackgroundTransparency = 1,
        Text             = "Lifetime",
        TextColor3       = Theme.Accent,
        TextSize         = 10,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 5,
        Parent           = userBadge,
    })

    -- ===== CONTENT AREA =====
    local contentArea = Create("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -180, 1, 0),
        Position         = UDim2.new(0, 180, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = window,
    })
    self.ContentArea = contentArea

    -- Top bar
    local topBar = Create("Frame", {
        Name             = "TopBar",
        Size             = UDim2.new(1, 0, 0, 48),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.97,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = contentArea,
    })
    -- bottom border on topbar
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Separator,
        BackgroundTransparency = 1 - Theme.SeparatorAlpha,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = topBar,
    })
    self.TopBar = topBar

    -- Topbar action icons (right side)
    local topBarActions = Create("Frame", {
        Size             = UDim2.new(0, 90, 1, 0),
        Position         = UDim2.new(1, -90, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = topBar,
    })
    local topBarLayout = Create("UIListLayout", {
        FillDirection      = Enum.FillDirection.Horizontal,
        HorizontalAlignment= Enum.HorizontalAlignment.Right,
        VerticalAlignment  = Enum.VerticalAlignment.Center,
        Padding            = UDim.new(0, 4),
        SortOrder          = Enum.SortOrder.LayoutOrder,
        Parent             = topBarActions,
    })
    AddPadding(topBarActions, 0, 0, 0, 12)

    for _, icon in ipairs({"⚙", "💬", "🔍"}) do
        local btn = Create("TextButton", {
            Size             = UDim2.new(0, 28, 0, 28),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.9,
            BorderSizePixel  = 0,
            Text             = icon,
            TextSize         = 14,
            TextColor3       = Theme.TextSecondary,
            Font             = Enum.Font.Gotham,
            ZIndex           = 6,
            Parent           = topBarActions,
        })
        AddCorner(btn, UDim.new(1, 0))
    end

    -- Tab bar (horizontal tabs in topbar)
    local tabBar = Create("Frame", {
        Name             = "TabBar",
        Size             = UDim2.new(1, -120, 1, 0),
        Position         = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = topBar,
    })
    local tabBarLayout = Create("UIListLayout", {
        FillDirection      = Enum.FillDirection.Horizontal,
        HorizontalAlignment= Enum.HorizontalAlignment.Left,
        VerticalAlignment  = Enum.VerticalAlignment.Center,
        Padding            = UDim.new(0, 2),
        SortOrder          = Enum.SortOrder.LayoutOrder,
        Parent             = tabBar,
    })
    self.TabBar = tabBar

    -- Pane container (pages)
    local paneContainer = Create("Frame", {
        Name             = "PaneContainer",
        Size             = UDim2.new(1, 0, 1, -48),
        Position         = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        ClipsDescendants = true,
        Parent           = contentArea,
    })
    self.PaneContainer = paneContainer

    -- Toggle key
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)

    return self
end

-----------------------------------------------------------------------
-- TOGGLE VISIBILITY
-----------------------------------------------------------------------
function LiquidGlass:Toggle()
    self.Visible = not self.Visible
    local target = self.Visible and 1 or 0
    local dimTarget = self.Visible and 0.6 or 1

    if self.Visible then
        self.Window.Visible  = true
        self.ScreenDim.Visible = true
    end

    Tween(self.Window, Theme.TweenOpen, {
        Size = self.Visible
            and UDim2.new(0, 860, 0, 520)
            or  UDim2.new(0, 860, 0, 0),
    })
    Tween(self.ScreenDim, Theme.TweenOpen, {
        BackgroundTransparency = dimTarget,
    })

    task.delay(0.35, function()
        if not self.Visible then
            self.Window.Visible   = false
            self.ScreenDim.Visible = false
        end
    end)
end

-----------------------------------------------------------------------
-- ADD SIDEBAR CATEGORY / GROUP
-----------------------------------------------------------------------
function LiquidGlass:AddCategory(name)
    local label = Create("TextLabel", {
        Name             = "Category_" .. name,
        Size             = UDim2.new(1, -16, 0, 22),
        BackgroundTransparency = 1,
        Text             = name:upper(),
        TextColor3       = Theme.SectionText,
        TextSize         = 9,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        LayoutOrder      = #self.Tabs * 10,
        ZIndex           = 5,
        Parent           = self.SidebarNav,
    })
    AddPadding(label, 4, 0, 16, 0)
    return label
end

-----------------------------------------------------------------------
-- ADD TAB (Sidebar nav item + content pane)
-----------------------------------------------------------------------
function LiquidGlass:AddTab(config)
    config = config or {}
    local tabName  = config.Name   or ("Tab " .. (#self.Tabs + 1))
    local tabIcon  = config.Icon   or "○"
    local category = config.Category

    -- Sidebar nav button
    local navBtn = Create("TextButton", {
        Name             = "NavBtn_" .. tabName,
        Size             = UDim2.new(1, -16, 0, 34),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 5,
        LayoutOrder      = #self.Tabs * 10 + 5,
        Parent           = self.SidebarNav,
    })
    AddCorner(navBtn, Theme.CornerRadiusSmall)
    AddPadding(navBtn, 0, 0, 8, 8)

    local navRow = Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = navBtn,
    })
    local iconLabel = Create("TextLabel", {
        Size             = UDim2.new(0, 20, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text             = tabIcon,
        TextColor3       = Theme.TextMuted,
        TextSize         = 14,
        Font             = Enum.Font.Gotham,
        ZIndex           = 7,
        Parent           = navRow,
    })
    local nameLabel = Create("TextLabel", {
        Size             = UDim2.new(1, -28, 1, 0),
        Position         = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1,
        Text             = tabName,
        TextColor3       = Theme.TextMuted,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
        Parent           = navRow,
    })
    -- Active indicator bar
    local activeBar = Create("Frame", {
        Size             = UDim2.new(0, 3, 0.6, 0),
        Position         = UDim2.new(1, -3, 0.2, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 7,
        Parent           = navBtn,
    })
    AddCorner(activeBar, UDim.new(1, 0))

    -- Content pane (two column layout like screenshot)
    local pane = Create("ScrollingFrame", {
        Name             = "Pane_" .. tabName,
        Size             = UDim2.new(1, 0, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible          = false,
        ZIndex           = 4,
        Parent           = self.PaneContainer,
    })
    AddPadding(pane, 16, 16, 16, 16)

    -- Two column grid
    local grid = Create("Frame", {
        Name             = "Grid",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = pane,
    })
    Create("UIGridLayout", {
        CellSize         = UDim2.new(0.5, -8, 0, 0),
        CellPaddingHorizontal = UDim.new(0, 8),
        CellPaddingVertical   = UDim.new(0, 8),
        FillDirection    = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder        = Enum.SortOrder.LayoutOrder,
        StartCorner      = Enum.StartCorner.TopLeft,
        Parent           = grid,
    })

    -- Actually use two explicit column frames for more control
    -- Override: use a simple list in pane instead of grid for easier sections
    grid:Destroy()

    local colContainer = Create("Frame", {
        Name             = "ColContainer",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = pane,
    })
    Create("UIListLayout", {
        FillDirection      = Enum.FillDirection.Horizontal,
        HorizontalAlignment= Enum.HorizontalAlignment.Left,
        VerticalAlignment  = Enum.VerticalAlignment.Top,
        Padding            = UDim.new(0, 12),
        SortOrder          = Enum.SortOrder.LayoutOrder,
        Parent             = colContainer,
    })

    local colLeft = Create("Frame", {
        Name             = "ColLeft",
        Size             = UDim2.new(0.5, -6, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        LayoutOrder      = 1,
        Parent           = colContainer,
    })
    AddListLayout(colLeft, nil, nil, 8)

    local colRight = Create("Frame", {
        Name             = "ColRight",
        Size             = UDim2.new(0.5, -6, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        LayoutOrder      = 2,
        Parent           = colContainer,
    })
    AddListLayout(colRight, nil, nil, 8)

    local tab = {
        Name        = tabName,
        NavBtn      = navBtn,
        ActiveBar   = activeBar,
        IconLabel   = iconLabel,
        NameLabel   = nameLabel,
        Pane        = pane,
        ColLeft     = colLeft,
        ColRight    = colRight,
        Sections    = {},
    }

    table.insert(self.Tabs, tab)

    -- Nav click
    navBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    -- Hover effects
    navBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(navBtn, Theme.TweenFast, {BackgroundTransparency = 0.92})
        end
    end)
    navBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(navBtn, Theme.TweenFast, {BackgroundTransparency = 1})
        end
    end)

    -- Select first tab automatically
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

-----------------------------------------------------------------------
-- SELECT TAB
-----------------------------------------------------------------------
function LiquidGlass:SelectTab(tab)
    -- Deactivate all
    for _, t in ipairs(self.Tabs) do
        t.Pane.Visible = false
        Tween(t.NavBtn,    Theme.TweenFast, {BackgroundTransparency = 1})
        Tween(t.ActiveBar, Theme.TweenFast, {BackgroundTransparency = 1})
        Tween(t.IconLabel, Theme.TweenFast, {TextColor3 = Theme.TextMuted})
        Tween(t.NameLabel, Theme.TweenFast, {TextColor3 = Theme.TextMuted, TextSize = 13})
        t.NameLabel.Font = Enum.Font.Gotham
    end
    -- Activate selected
    tab.Pane.Visible = true
    Tween(tab.NavBtn,    Theme.TweenFast, {BackgroundTransparency = 0.88})
    Tween(tab.ActiveBar, Theme.TweenFast, {BackgroundTransparency = 0})
    Tween(tab.IconLabel, Theme.TweenFast, {TextColor3 = Theme.Accent})
    Tween(tab.NameLabel, Theme.TweenFast, {TextColor3 = Theme.TextPrimary})
    tab.NameLabel.Font = Enum.Font.GothamBold
    self.ActiveTab = tab
end

-----------------------------------------------------------------------
-- ADD SECTION (glass card inside a column)
-----------------------------------------------------------------------
function LiquidGlass:AddSection(tab, config)
    config = config or {}
    local title  = config.Title  or "Section"
    local column = config.Column or "Left"   -- "Left" or "Right"

    local parent = column == "Right" and tab.ColRight or tab.ColLeft

    local card = Create("Frame", {
        Name             = "Section_" .. title,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.91,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = parent,
    })
    AddCorner(card, Theme.CornerRadiusSmall)
    AddStroke(card, Theme.GlassBorder, 0.12, 1)
    AddGlassShimmer(card)

    local inner = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = card,
    })
    AddPadding(inner, 10, 10, 12, 12)
    AddListLayout(inner, nil, nil, 0)

    -- Section title
    local sectionHeader = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 7,
        LayoutOrder      = 0,
        Parent           = inner,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = title:upper(),
        TextColor3       = Theme.SectionText,
        TextSize         = 9,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        LetterSpacing    = 2,
        ZIndex           = 8,
        Parent           = sectionHeader,
    })

    local section = {
        Title      = title,
        Card       = card,
        Inner      = inner,
        ItemCount  = 0,
    }

    table.insert(tab.Sections, section)
    return section
end

-----------------------------------------------------------------------
-- ELEMENT BASE (row inside a section)
-----------------------------------------------------------------------
local function MakeRow(section, height)
    height = height or 36
    section.ItemCount = section.ItemCount + 1
    local row = Create("Frame", {
        Name             = "Row_" .. section.ItemCount,
        Size             = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 7,
        LayoutOrder      = section.ItemCount,
        Parent           = section.Inner,
    })
    -- subtle separator
    if section.ItemCount > 1 then
        Create("Frame", {
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Theme.Separator,
            BackgroundTransparency = 1 - Theme.SeparatorAlpha,
            BorderSizePixel  = 0,
            ZIndex           = 7,
            Parent           = row,
        })
    end
    return row
end

local function MakeLabel(row, text, xAlign)
    return Create("TextLabel", {
        Size             = UDim2.new(0.55, 0, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text             = text,
        TextColor3       = Theme.TextSecondary,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = xAlign or Enum.TextXAlignment.Left,
        ZIndex           = 8,
        Parent           = row,
    })
end

-----------------------------------------------------------------------
-- TOGGLE / CHECKBOX
-----------------------------------------------------------------------
function LiquidGlass:AddToggle(section, config)
    config = config or {}
    local label    = config.Label    or "Toggle"
    local default  = config.Default  ~= false
    local callback = config.Callback or function() end

    local state = default
    local row   = MakeRow(section, 36)
    MakeLabel(row, label)

    -- Toggle pill
    local pillW, pillH = 44, 24
    local pill = Create("Frame", {
        Size             = UDim2.new(0, pillW, 0, pillH),
        Position         = UDim2.new(1, -(pillW + 4), 0.5, -pillH/2),
        BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
        BorderSizePixel  = 0,
        ZIndex           = 9,
        Parent           = row,
    })
    AddCorner(pill, UDim.new(1, 0))
    AddStroke(pill, Color3.fromRGB(255,255,255), 0.08, 1)

    local knob = Create("Frame", {
        Size             = UDim2.new(0, 18, 0, 18),
        Position         = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel  = 0,
        ZIndex           = 10,
        Parent           = pill,
    })
    AddCorner(knob, UDim.new(1, 0))

    -- Knob shadow
    Create("UIStroke", {
        Color       = Color3.fromRGB(0, 0, 0),
        Transparency = 0.7,
        Thickness   = 1,
        Parent      = knob,
    })

    -- Click button overlay
    local btn = Create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 11,
        Parent           = pill,
    })

    local function setToggle(val, fireCallback)
        state = val
        Tween(pill, Theme.TweenFast, {
            BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
        })
        Tween(knob, Theme.TweenFast, {
            Position = state
                and UDim2.new(1, -21, 0.5, -9)
                or  UDim2.new(0, 3,  0.5, -9)
        })
        if fireCallback then callback(state) end
    end

    btn.MouseButton1Click:Connect(function()
        setToggle(not state, true)
    end)

    local element = {
        Type     = "Toggle",
        Label    = label,
        Get      = function() return state end,
        Set      = function(_, v) setToggle(v, false) end,
        Callback = callback,
    }
    return element
end

-----------------------------------------------------------------------
-- SLIDER
-----------------------------------------------------------------------
function LiquidGlass:AddSlider(section, config)
    config = config or {}
    local label    = config.Label    or "Slider"
    local min      = config.Min      or 0
    local max      = config.Max      or 100
    local default  = config.Default  or min
    local step     = config.Step     or 1
    local suffix   = config.Suffix   or ""
    local callback = config.Callback or function() end

    local value = math.clamp(default, min, max)
    local row   = MakeRow(section, 48)

    -- Label + value display
    local topRow = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 18),
        Position         = UDim2.new(0, 0, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 8,
        Parent           = row,
    })
    MakeLabel(topRow, label)
    local valueLabel = Create("TextLabel", {
        Size             = UDim2.new(0.45, 0, 1, 0),
        Position         = UDim2.new(0.55, 0, 0, 0),
        BackgroundTransparency = 1,
        Text             = tostring(value) .. suffix,
        TextColor3       = Theme.Accent,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Right,
        ZIndex           = 8,
        Parent           = topRow,
    })

    -- Track
    local trackH = 6
    local track = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, trackH),
        Position         = UDim2.new(0, 0, 1, -trackH - 6),
        BackgroundColor3 = Theme.SliderTrack,
        BackgroundTransparency = 1 - Theme.SliderTrackAlpha,
        BorderSizePixel  = 0,
        ZIndex           = 8,
        Parent           = row,
    })
    AddCorner(track, UDim.new(1, 0))

    local function getPercent()
        return (value - min) / (max - min)
    end

    local fill = Create("Frame", {
        Size             = UDim2.new(getPercent(), 0, 1, 0),
        BackgroundColor3 = Theme.SliderFill,
        BorderSizePixel  = 0,
        ZIndex           = 9,
        Parent           = track,
    })
    AddCorner(fill, UDim.new(1, 0))

    -- Gradient on fill
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 140, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 200, 255)),
        }),
        Parent = fill,
    })

    -- Knob
    local knobSize = 14
    local knob = Create("Frame", {
        Size             = UDim2.new(0, knobSize, 0, knobSize),
        Position         = UDim2.new(getPercent(), -knobSize/2, 0.5, -knobSize/2),
        BackgroundColor3 = Theme.SliderKnob,
        BorderSizePixel  = 0,
        ZIndex           = 10,
        Parent           = track,
    })
    AddCorner(knob, UDim.new(1, 0))
    Create("UIStroke", {
        Color       = Theme.Accent,
        Transparency = 0.3,
        Thickness   = 2,
        Parent      = knob,
    })

    -- Input handling
    local sliding = false
    local inputArea = Create("TextButton", {
        Size             = UDim2.new(1, 20, 1, 20),
        Position         = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 11,
        Parent           = track,
    })

    local function updateFromInput(input)
        local trackPos   = track.AbsolutePosition
        local trackWidth = track.AbsoluteSize.X
        local relX = math.clamp((input.Position.X - trackPos.X) / trackWidth, 0, 1)
        local rawVal = min + relX * (max - min)
        value = math.floor(rawVal / step + 0.5) * step
        value = math.clamp(value, min, max)
        local pct = getPercent()
        fill.Size     = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -knobSize/2, 0.5, -knobSize/2)
        valueLabel.Text = tostring(value) .. suffix
        callback(value)
    end

    inputArea.MouseButton1Down:Connect(function()
        sliding = true
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    inputArea.MouseButton1Up:Connect(function(x, y)
        sliding = false
    end)

    local element = {
        Type     = "Slider",
        Label    = label,
        Get      = function() return value end,
        Set      = function(_, v)
            value = math.clamp(v, min, max)
            local pct = getPercent()
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -knobSize/2, 0.5, -knobSize/2)
            valueLabel.Text = tostring(value) .. suffix
        end,
        Callback = callback,
    }
    return element
end

-----------------------------------------------------------------------
-- COMBOBOX (Dropdown)
-----------------------------------------------------------------------
function LiquidGlass:AddComboBox(section, config)
    config = config or {}
    local label    = config.Label    or "ComboBox"
    local options  = config.Options  or {}
    local default  = config.Default  or options[1]
    local callback = config.Callback or function() end

    local selected = default
    local isOpen   = false

    local row = MakeRow(section, 36)
    MakeLabel(row, label)

    -- Button
    local btnW = 120
    local dropBtn = Create("TextButton", {
        Size             = UDim2.new(0, btnW, 0, 26),
        Position         = UDim2.new(1, -(btnW + 4), 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.88,
        BorderSizePixel  = 0,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 9,
        Parent           = row,
    })
    AddCorner(dropBtn, Theme.CornerRadiusSmall)
    AddStroke(dropBtn, Theme.GlassBorder, 0.15, 1)

    Create("TextLabel", {
        Name             = "SelectedLabel",
        Size             = UDim2.new(1, -24, 1, 0),
        Position         = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text             = tostring(selected),
        TextColor3       = Theme.TextPrimary,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 10,
        Parent           = dropBtn,
    })
    -- Chevron
    Create("TextLabel", {
        Size             = UDim2.new(0, 16, 1, 0),
        Position         = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text             = "⌄",
        TextColor3       = Theme.TextMuted,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 10,
        Parent           = dropBtn,
    })

    -- Dropdown list (placed above section in ZIndex)
    local listFrame = Create("Frame", {
        Size             = UDim2.new(0, btnW, 0, #options * 28 + 8),
        Position         = UDim2.new(1, -(btnW + 4), 1, 2),
        BackgroundColor3 = Theme.DropdownBG,
        BackgroundTransparency = 1 - Theme.DropdownBGAlpha,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 20,
        Parent           = row,
    })
    AddCorner(listFrame, Theme.CornerRadiusSmall)
    AddStroke(listFrame, Theme.GlassBorder, 0.2, 1)
    AddPadding(listFrame, 4, 4, 4, 4)
    AddListLayout(listFrame, nil, nil, 2)

    for _, opt in ipairs(options) do
        local optBtn = Create("TextButton", {
            Size             = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = Theme.DropdownHover,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            Text             = tostring(opt),
            TextColor3       = Theme.TextSecondary,
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            AutoButtonColor  = false,
            ZIndex           = 21,
            Parent           = listFrame,
        })
        AddPadding(optBtn, 0, 0, 8, 0)
        AddCorner(optBtn, UDim.new(0, 6))

        optBtn.MouseEnter:Connect(function()
            Tween(optBtn, Theme.TweenFast, {BackgroundTransparency = 1 - Theme.DropdownHoverAlpha})
            optBtn.TextColor3 = Theme.TextPrimary
        end)
        optBtn.MouseLeave:Connect(function()
            Tween(optBtn, Theme.TweenFast, {BackgroundTransparency = 1})
            optBtn.TextColor3 = Theme.TextSecondary
        end)
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            dropBtn:FindFirstChild("SelectedLabel").Text = tostring(opt)
            isOpen = false
            listFrame.Visible = false
            callback(selected)
        end)
    end

    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listFrame.Visible = isOpen
    end)

    local element = {
        Type     = "ComboBox",
        Label    = label,
        Get      = function() return selected end,
        Set      = function(_, v)
            selected = v
            dropBtn:FindFirstChild("SelectedLabel").Text = tostring(v)
        end,
        Callback = callback,
    }
    return element
end

-----------------------------------------------------------------------
-- MULTI COMBOBOX
-----------------------------------------------------------------------
function LiquidGlass:AddMultiComboBox(section, config)
    config = config or {}
    local label    = config.Label    or "MultiSelect"
    local options  = config.Options  or {}
    local defaults = config.Defaults or {}
    local callback = config.Callback or function() end

    local selected = {}
    for _, v in ipairs(defaults) do selected[v] = true end

    local isOpen = false

    local function getSelectedText()
        local parts = {}
        for _, opt in ipairs(options) do
            if selected[opt] then table.insert(parts, opt) end
        end
        if #parts == 0 then return "None"
        elseif #parts == #options then return "All"
        else return table.concat(parts, ", ") end
    end

    local row = MakeRow(section, 36)
    MakeLabel(row, label)

    local btnW = 140
    local dropBtn = Create("TextButton", {
        Size             = UDim2.new(0, btnW, 0, 26),
        Position         = UDim2.new(1, -(btnW + 4), 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.88,
        BorderSizePixel  = 0,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 9,
        Parent           = row,
    })
    AddCorner(dropBtn, Theme.CornerRadiusSmall)
    AddStroke(dropBtn, Theme.GlassBorder, 0.15, 1)

    local selLabel = Create("TextLabel", {
        Name             = "SelLabel",
        Size             = UDim2.new(1, -24, 1, 0),
        Position         = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text             = getSelectedText(),
        TextColor3       = Theme.TextPrimary,
        TextSize         = 10,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextTruncate     = Enum.TextTruncate.AtEnd,
        ZIndex           = 10,
        Parent           = dropBtn,
    })
    Create("TextLabel", {
        Size             = UDim2.new(0, 16, 1, 0),
        Position         = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text             = "⌄",
        TextColor3       = Theme.TextMuted,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 10,
        Parent           = dropBtn,
    })

    local listFrame = Create("Frame", {
        Size             = UDim2.new(0, btnW, 0, #options * 30 + 8),
        Position         = UDim2.new(1, -(btnW + 4), 1, 2),
        BackgroundColor3 = Theme.DropdownBG,
        BackgroundTransparency = 1 - Theme.DropdownBGAlpha,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 20,
        Parent           = row,
    })
    AddCorner(listFrame, Theme.CornerRadiusSmall)
    AddStroke(listFrame, Theme.GlassBorder, 0.2, 1)
    AddPadding(listFrame, 4, 4, 4, 4)
    AddListLayout(listFrame, nil, nil, 2)

    local checkFrames = {}

    for _, opt in ipairs(options) do
        local optRow = Create("TextButton", {
            Size             = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme.DropdownHover,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 21,
            Parent           = listFrame,
        })
        AddCorner(optRow, UDim.new(0, 6))

        -- Mini checkbox
        local cb = Create("Frame", {
            Size             = UDim2.new(0, 14, 0, 14),
            Position         = UDim2.new(0, 6, 0.5, -7),
            BackgroundColor3 = selected[opt] and Theme.Accent or Theme.ToggleOff,
            BorderSizePixel  = 0,
            ZIndex           = 22,
            Parent           = optRow,
        })
        AddCorner(cb, UDim.new(0, 4))
        local cbCheck = Create("TextLabel", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text             = selected[opt] and "✓" or "",
            TextColor3       = Color3.fromRGB(255, 255, 255),
            TextSize         = 10,
            Font             = Enum.Font.GothamBold,
            ZIndex           = 23,
            Parent           = cb,
        })
        Create("TextLabel", {
            Size             = UDim2.new(1, -26, 1, 0),
            Position         = UDim2.new(0, 24, 0, 0),
            BackgroundTransparency = 1,
            Text             = tostring(opt),
            TextColor3       = Theme.TextSecondary,
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 22,
            Parent           = optRow,
        })
        checkFrames[opt] = {cb = cb, check = cbCheck}

        optRow.MouseEnter:Connect(function()
            Tween(optRow, Theme.TweenFast, {BackgroundTransparency = 1 - Theme.DropdownHoverAlpha})
        end)
        optRow.MouseLeave:Connect(function()
            Tween(optRow, Theme.TweenFast, {BackgroundTransparency = 1})
        end)
        optRow.MouseButton1Click:Connect(function()
            selected[opt] = not selected[opt]
            cb.BackgroundColor3 = selected[opt] and Theme.Accent or Theme.ToggleOff
            cbCheck.Text        = selected[opt] and "✓" or ""
            selLabel.Text       = getSelectedText()
            callback(selected)
        end)
    end

    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listFrame.Visible = isOpen
    end)

    local element = {
        Type     = "MultiComboBox",
        Label    = label,
        Get      = function() return selected end,
        Callback = callback,
    }
    return element
end

-----------------------------------------------------------------------
-- COLOR PICKER
-----------------------------------------------------------------------
function LiquidGlass:AddColorPicker(section, config)
    config = config or {}
    local label    = config.Label    or "Color"
    local default  = config.Default  or Color3.fromRGB(100, 160, 255)
    local callback = config.Callback or function() end

    local hue, sat, val = Color3.toHSV(default)
    local currentColor = default
    local isOpen = false

    local row = MakeRow(section, 36)
    MakeLabel(row, label)

    -- Color preview swatch
    local swatchBtn = Create("TextButton", {
        Size             = UDim2.new(0, 60, 0, 24),
        Position         = UDim2.new(1, -68, 0.5, -12),
        BackgroundColor3 = currentColor,
        BorderSizePixel  = 0,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 9,
        Parent           = row,
    })
    AddCorner(swatchBtn, Theme.CornerRadiusSmall)
    AddStroke(swatchBtn, Color3.fromRGB(255, 255, 255), 0.2, 1)

    -- Hex label on swatch
    local function toHex(c)
        return string.format("#%02X%02X%02X",
            math.floor(c.R * 255),
            math.floor(c.G * 255),
            math.floor(c.B * 255))
    end
    local hexLabel = Create("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = toHex(currentColor),
        TextColor3       = Color3.fromRGB(255, 255, 255),
        TextSize          = 9,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 10,
        Parent           = swatchBtn,
    })

    -- Picker popup
    local pickerW, pickerH = 200, 220
    local picker = Create("Frame", {
        Size             = UDim2.new(0, pickerW, 0, pickerH),
        Position         = UDim2.new(1, -(pickerW + 4), 1, 4),
        BackgroundColor3 = Theme.DropdownBG,
        BackgroundTransparency = 1 - Theme.DropdownBGAlpha,
        Visible          = false,
        ZIndex           = 25,
        Parent           = row,
    })
    AddCorner(picker, Theme.CornerRadiusSmall)
    AddStroke(picker, Theme.GlassBorder, 0.2, 1)
    AddPadding(picker, 10, 10, 10, 10)

    -- SV Square
    local svSize = pickerW - 20
    local svSquare = Create("Frame", {
        Size             = UDim2.new(0, svSize, 0, svSize * 0.6),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
        BorderSizePixel  = 0,
        ZIndex           = 26,
        Parent           = picker,
        ClipsDescendants = true,
    })
    AddCorner(svSquare, UDim.new(0, 8))

    -- White gradient (saturation)
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
        }),
        Rotation = 0,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = svSquare,
    })
    -- Dark gradient (value)
    local darkOverlay = Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 27,
        Parent           = svSquare,
    })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.new(0,0,0)),
        }),
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Parent = darkOverlay,
    })

    -- SV Cursor
    local svCursor = Create("Frame", {
        Size             = UDim2.new(0, 10, 0, 10),
        Position         = UDim2.new(sat, -5, 1 - val, -5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel  = 0,
        ZIndex           = 28,
        Parent           = svSquare,
    })
    AddCorner(svCursor, UDim.new(1, 0))
    Create("UIStroke", {Color=Color3.new(0,0,0), Transparency=0.5, Thickness=1, Parent=svCursor})

    -- Hue bar
    local hueBarH = 12
    local hueBar = Create("Frame", {
        Size             = UDim2.new(0, svSize, 0, hueBarH),
        Position         = UDim2.new(0, 0, 0, svSize * 0.6 + 8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel  = 0,
        ZIndex           = 26,
        Parent           = picker,
    })
    AddCorner(hueBar, UDim.new(1, 0))

    local hueColors = {}
    for i = 0, 6 do
        table.insert(hueColors, ColorSequenceKeypoint.new(i/6, Color3.fromHSV(i/6, 1, 1)))
    end
    Create("UIGradient", {
        Color  = ColorSequence.new(hueColors),
        Parent = hueBar,
    })

    -- Hue cursor
    local hueCursor = Create("Frame", {
        Size             = UDim2.new(0, 4, 1, 4),
        Position         = UDim2.new(hue, -2, 0, -2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel  = 0,
        ZIndex           = 27,
        Parent           = hueBar,
    })
    AddCorner(hueCursor, UDim.new(0, 3))
    Create("UIStroke", {Color=Color3.new(0,0,0), Transparency=0.4, Thickness=1, Parent=hueCursor})

    -- Alpha bar
    local alphaBar = Create("Frame", {
        Size             = UDim2.new(0, svSize, 0, hueBarH),
        Position         = UDim2.new(0, 0, 0, svSize * 0.6 + 8 + hueBarH + 6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel  = 0,
        ZIndex           = 26,
        Parent           = picker,
    })
    AddCorner(alphaBar, UDim.new(1, 0))
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(1, currentColor),
        }),
        Parent = alphaBar,
    })

    local alpha = 1
    local alphaCursor = Create("Frame", {
        Size             = UDim2.new(0, 4, 1, 4),
        Position         = UDim2.new(alpha, -2, 0, -2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel  = 0,
        ZIndex           = 27,
        Parent           = alphaBar,
    })
    AddCorner(alphaCursor, UDim.new(0, 3))
    Create("UIStroke", {Color=Color3.new(0,0,0), Transparency=0.4, Thickness=1, Parent=alphaCursor})

    -- Output preview
    local outputSwatch = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 24),
        Position         = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = currentColor,
        BorderSizePixel  = 0,
        ZIndex           = 26,
        Parent           = picker,
    })
    AddCorner(outputSwatch, UDim.new(0, 6))
    local outputHex = Create("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = toHex(currentColor),
        TextColor3       = Color3.fromRGB(255, 255, 255),
        TextSize         = 10,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 27,
        Parent           = outputSwatch,
    })

    local function updateColor()
        currentColor = Color3.fromHSV(hue, sat, val)
        svSquare.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        svCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
        hueCursor.Position = UDim2.new(hue, -2, 0, -2)
        outputSwatch.BackgroundColor3 = currentColor
        outputHex.Text = toHex(currentColor)
        swatchBtn.BackgroundColor3 = currentColor
        hexLabel.Text = toHex(currentColor)
        alphaBar.BackgroundColor3 = currentColor
        callback(currentColor, alpha)
    end

    -- SV drag
    local draggingSV = false
    local svInput = Create("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=29, Parent=svSquare
    })
    svInput.MouseButton1Down:Connect(function() draggingSV = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingSV and i.UserInputType == Enum.UserInputType.MouseMovement then
            local ap = svSquare.AbsolutePosition
            local as = svSquare.AbsoluteSize
            sat = math.clamp((i.Position.X - ap.X) / as.X, 0, 1)
            val = 1 - math.clamp((i.Position.Y - ap.Y) / as.Y, 0, 1)
            updateColor()
        end
    end)

    -- Hue drag
    local draggingHue = false
    local hueInput = Create("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=28, Parent=hueBar
    })
    hueInput.MouseButton1Down:Connect(function() draggingHue = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingHue and i.UserInputType == Enum.UserInputType.MouseMovement then
            local ap = hueBar.AbsolutePosition
            local as = hueBar.AbsoluteSize
            hue = math.clamp((i.Position.X - ap.X) / as.X, 0, 1)
            updateColor()
        end
    end)

    -- Alpha drag
    local draggingAlpha = false
    local alphaInput = Create("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=28, Parent=alphaBar
    })
    alphaInput.MouseButton1Down:Connect(function() draggingAlpha = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingAlpha = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingAlpha and i.UserInputType == Enum.UserInputType.MouseMovement then
            local ap = alphaBar.AbsolutePosition
            local as = alphaBar.AbsoluteSize
            alpha = math.clamp((i.Position.X - ap.X) / as.X, 0, 1)
            alphaCursor.Position = UDim2.new(alpha, -2, 0, -2)
            callback(currentColor, alpha)
        end
    end)

    swatchBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        picker.Visible = isOpen
    end)

    local element = {
        Type     = "ColorPicker",
        Label    = label,
        Get      = function() return currentColor, alpha end,
        Set      = function(_, c)
            hue, sat, val = Color3.toHSV(c)
            currentColor = c
            updateColor()
        end,
        Callback = callback,
    }
    return element
end

-----------------------------------------------------------------------
-- KEYBINDER
-----------------------------------------------------------------------
function LiquidGlass:AddKeybind(section, config)
    config = config or {}
    local label    = config.Label    or "Keybind"
    local default  = config.Default  or Enum.KeyCode.F
    local callback = config.Callback or function() end

    local boundKey  = default
    local listening = false

    local row = MakeRow(section, 36)
    MakeLabel(row, label)

    local keyBtn = Create("TextButton", {
        Size             = UDim2.new(0, 80, 0, 24),
        Position         = UDim2.new(1, -88, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.88,
        BorderSizePixel  = 0,
        Text             = boundKey.Name,
        TextColor3       = Theme.Accent,
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        AutoButtonColor  = false,
        ZIndex           = 9,
        Parent           = row,
    })
    AddCorner(keyBtn, Theme.CornerRadiusSmall)
    AddStroke(keyBtn, Theme.GlassBorder, 0.15, 1)

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = Theme.AccentOrange
        Tween(keyBtn, Theme.TweenFast, {BackgroundTransparency = 0.75})
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not listening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            boundKey = input.KeyCode
            keyBtn.Text = boundKey.Name
            keyBtn.TextColor3 = Theme.Accent
            Tween(keyBtn, Theme.TweenFast, {BackgroundTransparency = 0.88})
            listening = false
        end
    end)

    -- Fire callback when bound key is pressed
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listening and input.KeyCode == boundKey then
            callback(boundKey)
        end
    end)

    local element = {
        Type     = "Keybind",
        Label    = label,
        Get      = function() return boundKey end,
        Set      = function(_, k)
            boundKey = k
            keyBtn.Text = k.Name
        end,
        Callback = callback,
    }
    return element
end

-----------------------------------------------------------------------
-- BUTTON
-----------------------------------------------------------------------
function LiquidGlass:AddButton(section, config)
    config = config or {}
    local label    = config.Label    or "Button"
    local text     = config.Text     or "Click"
    local callback = config.Callback or function() end

    local row = MakeRow(section, 36)
    MakeLabel(row, label)

    local btn = Create("TextButton", {
        Size             = UDim2.new(0, 90, 0, 26),
        Position         = UDim2.new(1, -98, 0.5, -13),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.2,
        BorderSizePixel  = 0,
        Text             = text,
        TextColor3       = Color3.fromRGB(255, 255, 255),
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        AutoButtonColor  = false,
        ZIndex           = 9,
        Parent           = row,
    })
    AddCorner(btn, Theme.CornerRadiusSmall)

    btn.MouseEnter:Connect(function()
        Tween(btn, Theme.TweenFast, {BackgroundTransparency = 0.05})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, Theme.TweenFast, {BackgroundTransparency = 0.2})
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(btn, Theme.TweenFast, {
            Size = UDim2.new(0, 86, 0, 24),
            Position = UDim2.new(1, -96, 0.5, -12)
        })
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, Theme.TweenBounce, {
            Size = UDim2.new(0, 90, 0, 26),
            Position = UDim2.new(1, -98, 0.5, -13)
        })
        callback()
    end)

    return {Type = "Button", Label = label}
end

-----------------------------------------------------------------------
-- TEXT INPUT
-----------------------------------------------------------------------
function LiquidGlass:AddTextInput(section, config)
    config = config or {}
    local label    = config.Label       or "Input"
    local placeholder = config.Placeholder or "Type here..."
    local default  = config.Default     or ""
    local callback = config.Callback    or function() end

    local row = MakeRow(section, 36)
    MakeLabel(row, label)

    local inputFrame = Create("Frame", {
        Size             = UDim2.new(0, 140, 0, 26),
        Position         = UDim2.new(1, -148, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.88,
        BorderSizePixel  = 0,
        ZIndex           = 9,
        Parent           = row,
    })
    AddCorner(inputFrame, Theme.CornerRadiusSmall)
    AddStroke(inputFrame, Theme.GlassBorder, 0.15, 1)

    local textBox = Create("TextBox", {
        Size             = UDim2.new(1, -16, 1, 0),
        Position         = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text             = default,
        PlaceholderText  = placeholder,
        PlaceholderColor3= Theme.TextMuted,
        TextColor3       = Theme.TextPrimary,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex           = 10,
        Parent           = inputFrame,
    })

    textBox.Focused:Connect(function()
        Tween(inputFrame, Theme.TweenFast, {BackgroundTransparency = 0.80})
        AddStroke(inputFrame, Theme.Accent, 0.5, 1)
    end)
    textBox.FocusLost:Connect(function(entered)
        Tween(inputFrame, Theme.TweenFast, {BackgroundTransparency = 0.88})
        if entered then callback(textBox.Text) end
    end)

    return {
        Type  = "TextInput",
        Label = label,
        Get   = function() return textBox.Text end,
        Set   = function(_, v) textBox.Text = v end,
    }
end

-----------------------------------------------------------------------
-- LABEL (static text)
-----------------------------------------------------------------------
function LiquidGlass:AddLabel(section, config)
    config = config or {}
    local text  = config.Text  or ""
    local color = config.Color or Theme.TextMuted

    local row = MakeRow(section, 28)
    Create("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = text,
        TextColor3       = color,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 8,
        Parent           = row,
    })
    return {Type = "Label", Text = text}
end

-----------------------------------------------------------------------
-- SEPARATOR
-----------------------------------------------------------------------
function LiquidGlass:AddSeparator(section)
    local row = MakeRow(section, 12)
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Separator,
        BackgroundTransparency = 1 - Theme.SeparatorAlpha * 2,
        BorderSizePixel  = 0,
        ZIndex           = 8,
        Parent           = row,
    })
end

-----------------------------------------------------------------------
-- NOTIFY (toast notification)
-----------------------------------------------------------------------
function LiquidGlass:Notify(config)
    config = config or {}
    local title   = config.Title   or "Notice"
    local message = config.Message or ""
    local duration = config.Duration or 4
    local accent  = config.Accent  or Theme.Accent

    local notifContainer = self.Gui:FindFirstChild("NotifContainer")
    if not notifContainer then
        notifContainer = Create("Frame", {
            Name             = "NotifContainer",
            Size             = UDim2.new(0, 300, 1, 0),
            Position         = UDim2.new(1, -316, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 50,
            Parent           = self.Gui,
        })
        AddPadding(notifContainer, 12, 12, 0, 0)
        AddListLayout(notifContainer, nil, Enum.HorizontalAlignment.Right, 8)
    end

    local notif = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Color3.fromRGB(20, 22, 40),
        BackgroundTransparency = 0.1,
        BorderSizePixel  = 0,
        ZIndex           = 51,
        Parent           = notifContainer,
    })
    AddCorner(notif, Theme.CornerRadiusSmall)
    AddStroke(notif, accent, 0.3, 1)

    -- Accent bar
    local accentBar = Create("Frame", {
        Size             = UDim2.new(0, 3, 1, -16),
        Position         = UDim2.new(0, 0, 0, 8),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        ZIndex           = 52,
        Parent           = notif,
    })
    AddCorner(accentBar, UDim.new(1, 0))

    Create("TextLabel", {
        Size             = UDim2.new(1, -20, 0, 20),
        Position         = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = Color3.fromRGB(255, 255, 255),
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 52,
        Parent           = notif,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, -20, 0, 30),
        Position         = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Text             = message,
        TextColor3       = Theme.TextSecondary,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 52,
        Parent           = notif,
    })

    -- Progress bar
    local progress = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.4,
        BorderSizePixel  = 0,
        ZIndex           = 52,
        Parent           = notif,
    })
    AddCorner(progress, UDim.new(1, 0))

    -- Animate in
    notif.Position = UDim2.new(1, 20, 0, 0)
    Tween(notif, Theme.TweenOpen, {Position = UDim2.new(0, 0, 0, 0)})

    -- Progress tween
    TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    }):Play()

    -- Dismiss
    task.delay(duration, function()
        Tween(notif, Theme.TweenOpen, {
            Position = UDim2.new(1, 20, 0, 0),
            BackgroundTransparency = 1,
        })
        task.delay(0.4, function()
            notif:Destroy()
        end)
    end)

    return notif
end

-----------------------------------------------------------------------
-- DESTROY
-----------------------------------------------------------------------
function LiquidGlass:Destroy()
    if self.Gui then self.Gui:Destroy() end
end

return LiquidGlass
