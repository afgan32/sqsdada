
local LiquidGlassUI = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Theme Configuration
local Theme = {
    -- Glass properties
    GlassOpacity = 0.12, -- 12% opacity for true glass effect
    GlassColor = Color3.fromRGB(255, 255, 255),
    GlassBlur = 0.85,
    
    -- Corner radius (extra large for squircle feel)
    CornerRadius = UDim.new(0, 24),
    SmallCornerRadius = UDim.new(0, 12),
    
    -- Borders
    InnerGlowColor = Color3.fromRGB(255, 255, 255),
    InnerGlowTransparency = 0.6,
    BorderThickness = 1.5,
    
    -- Shadows
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.5,
    ShadowSize = 40,
    
    -- Vibrant accents (neon-like)
    AccentGradient = {
        Color3.fromRGB(255, 100, 150),  -- Pink
        Color3.fromRGB(150, 100, 255),   -- Purple
        Color3.fromRGB(100, 200, 255),   -- Blue
    },
    AccentColor = Color3.fromRGB(100, 180, 255),
    
    -- Text
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 210),
    TextDark = Color3.fromRGB(40, 40, 50),
    
    -- Animation
    AnimationSpeed = 0.25,
}

-- Utility Functions
local function Create(instance, props)
    local obj = Instance.new(instance)
    for prop, val in pairs(props) do
        obj[prop] = val
    end
    return obj
end

local function AddCorner(parent, radius)
    local corner = Create("UICorner", {CornerRadius = radius or Theme.CornerRadius})
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness, transparency)
    local stroke = Create("UIStroke", {
        Color = color or Theme.InnerGlowColor,
        Thickness = thickness or Theme.BorderThickness,
        Transparency = transparency or Theme.InnerGlowTransparency
    })
    stroke.Parent = parent
    return stroke
end

local function AddGradient(parent, color1, color2, rotation)
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1 or Theme.AccentGradient[1]),
            ColorSequenceKeypoint.new(1, color2 or Theme.AccentGradient[2])
        }),
        Rotation = rotation or 45
    })
    gradient.Parent = parent
    return gradient
end

local function AddPadding(parent, pad)
    local padding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, pad or 12),
        PaddingRight = UDim.new(0, pad or 12),
        PaddingTop = UDim.new(0, pad or 12),
        PaddingBottom = UDim.new(0, pad or 12)
    })
    padding.Parent = parent
    return padding
end

local function AddListLayout(parent, padding)
    local layout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, padding or 6)
    })
    layout.Parent = parent
    return layout
end

local function TweenObject(obj, props, duration, style, direction)
    local tween = TweenService:Create(obj, TweenInfo.new(
        duration or Theme.AnimationSpeed,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    ), props)
    tween:Play()
    return tween
end

-- Create Glass Panel with proper glassmorphism
local function CreateGlassPanel(parent, size, position, zIndex)
    local panel = Create("Frame", {
        Name = "GlassPanel",
        Size = size or UDim2.new(1, 0, 1, 0),
        Position = position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = Theme.GlassOpacity,
        BorderSizePixel = 0,
        ZIndex = zIndex or 1,
        Parent = parent
    })
    
    -- Large corner radius
    AddCorner(panel, Theme.CornerRadius)
    
    -- Inner glow border (simulates glass thickness)
    AddStroke(panel, Theme.InnerGlowColor, Theme.BorderThickness, Theme.InnerGlowTransparency)
    
    -- Top highlight (specular reflection)
    local topHighlight = Create("Frame", {
        Name = "TopHighlight",
        Size = UDim2.new(1, -4, 0, 2),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = zIndex and zIndex + 1 or 2,
        Parent = panel
    })
    AddCorner(topHighlight, UDim.new(0, 20))
    
    return panel
end

-- Create Drop Shadow
local function CreateDropShadow(parent, size, offset)
    local shadow = Create("ImageLabel", {
        Name = "DropShadow",
        Size = size or UDim2.new(1, Theme.ShadowSize * 2, 1, Theme.ShadowSize * 2),
        Position = UDim2.new(0, -(Theme.ShadowSize) + (offset or 0), 0, -(Theme.ShadowSize) + (offset or 0)),
        BackgroundTransparency = 1,
        Image = "rbxassetid://601425199",
        ImageColor3 = Theme.ShadowColor,
        ImageTransparency = Theme.ShadowTransparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = parent
    })
    return shadow
end

-- Create Vibrant Button
local function CreateVibrantButton(parent, size, position, text, isAccent)
    local btn = Create("TextButton", {
        Name = "Button",
        Size = size or UDim2.new(0, 100, 0, 36),
        Position = position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = isAccent and Theme.AccentColor or Theme.GlassColor,
        BackgroundTransparency = isAccent and 0.15 or Theme.GlassOpacity,
        BorderSizePixel = 0,
        Text = text or "",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false,
        Parent = parent
    })
    AddCorner(btn, Theme.SmallCornerRadius)
    AddStroke(btn, Theme.InnerGlowColor, 1, isAccent and 0.3 or 0.5)
    
    if isAccent then
        AddGradient(btn, Theme.AccentGradient[1], Theme.AccentGradient[3], 90)
    end
    
    btn.MouseEnter:Connect(function()
        TweenObject(btn, {BackgroundTransparency = isAccent and 0.05 or Theme.GlassOpacity - 0.05}, 0.15)
    end)
    
    btn.MouseLeave:Connect(function()
        TweenObject(btn, {BackgroundTransparency = isAccent and 0.15 or Theme.GlassOpacity}, 0.15)
    end)
    
    return btn
end

-- HSV to RGB conversion
local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    
    return Color3.fromRGB(math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

local function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, max
    
    if max > 0 then s = (max - min) / max end
    if max == min then h = 0
    elseif max == r then h = (g - b) / (max - min) + (g < b and 6 or 0)
    elseif max == g then h = (b - r) / (max - min) + 2
    elseif max == b then h = (r - g) / (max - min) + 4
    end
    
    return h / 6, s, v
end

-- Window Class
LiquidGlassUI.Window = {}
LiquidGlassUI.Window.__index = LiquidGlassUI.Window

function LiquidGlassUI:CreateWindow(config)
    local self = setmetatable({}, LiquidGlassUI.Window)
    
    config = config or {}
    self.Name = config.Name or "LiquidGlass UI"
    self.Size = config.Size or UDim2.new(0, 650, 0, 500)
    self.Position = config.Position or UDim2.new(0.5, -325, 0.5, -250)
    self.Tabs = {}
    self.CurrentTab = nil
    self.Visible = true
    self.OpenDropdowns = {}
    
    -- Create ScreenGui with proper ZIndex behavior
    self.ScreenGui = Create("ScreenGui", {
        Name = "LiquidGlassUI_" .. tostring(math.random(10000, 99999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true,
        DisplayOrder = 100
    })
    
    -- Parent to CoreGui or PlayerGui
    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChild("PlayerGui")
    self.ScreenGui.Parent = playerGui or CoreGui
    
    -- Main Container
    self.Container = Create("Frame", {
        Name = "Container",
        Size = self.Size,
        Position = self.Position,
        BackgroundTransparency = 1,
        Parent = self.ScreenGui
    })
    
    -- Large drop shadow
    CreateDropShadow(self.Container)
    
    -- Main glass panel
    self.MainGlass = CreateGlassPanel(self.Container)
    
    -- Build window structure
    self:BuildStructure()
    
    -- Setup interactions
    self:SetupKeybind()
    self:MakeDraggable()
    
    return self
end

function LiquidGlassUI.Window:BuildStructure()
    -- Header
    self.Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = self.Container
    })
    
    -- Title with subtle text
    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Name,
        TextColor3 = Theme.TextDark,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = self.Header
    })
    
    -- Close button
    self.CloseBtn = Create("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -46, 0.5, -18),
        BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Theme.TextPrimary,
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = self.Header
    })
    AddCorner(self.CloseBtn, UDim.new(0, 18))
    
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    self.CloseBtn.MouseEnter:Connect(function()
        TweenObject(self.CloseBtn, {BackgroundTransparency = 0}, 0.15)
    end)
    
    self.CloseBtn.MouseLeave:Connect(function()
        TweenObject(self.CloseBtn, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    -- Sidebar for tabs
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, -60),
        Position = UDim2.new(0, 12, 0, 55),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = self.Container
    })
    
    self.TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 4,
        Parent = self.Sidebar
    })
    
    self.TabListLayout = AddListLayout(self.TabList, 4)
    self.TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabList.CanvasSize = UDim2.new(0, 0, 0, self.TabListLayout.AbsoluteContentSize.Y)
    end)
    
    -- Content area
    self.ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -175, 1, -70),
        Position = UDim2.new(0, 165, 0, 55),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = self.Container
    })
    
    -- Content glass panel
    self.ContentGlass = CreateGlassPanel(self.ContentArea, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 4)
end

function LiquidGlassUI.Window:MakeDraggable()
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    
    self.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Container.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.Container.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function LiquidGlassUI.Window:SetupKeybind()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            self:Toggle()
        end
    end)
end

function LiquidGlassUI.Window:Toggle()
    self.Visible = not self.Visible
    
    if self.Visible then
        self.ScreenGui.Enabled = true
        self.Container.Position = UDim2.new(self.Position.X.Scale, self.Position.X.Offset, -1, 0)
        TweenObject(self.Container, {Position = self.Position}, 0.35)
    else
        TweenObject(self.Container, {Position = UDim2.new(self.Position.X.Scale, self.Position.X.Offset, -1.2, 0)}, 0.35)
        task.delay(0.35, function()
            self.ScreenGui.Enabled = false
        end)
    end
end

function LiquidGlassUI.Window:CreateTab(config)
    config = config or {}
    local tab = {
        Name = config.Name or "Tab",
        Icon = config.Icon or "H",
        Window = self
    }
    
    -- Tab button
    tab.Button = Create("TextButton", {
        Name = tab.Name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = self.TabList
    })
    AddCorner(tab.Button, Theme.SmallCornerRadius)
    AddStroke(tab.Button, Theme.InnerGlowColor, 1, 0.7)
    
    -- Tab icon
    Create("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 28, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = tab.Icon,
        TextColor3 = Theme.TextDark,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        ZIndex = 6,
        Parent = tab.Button
    })
    
    -- Tab name
    Create("TextLabel", {
        Name = "TabName",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = tab.Name,
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = tab.Button
    })
    
    -- Tab content
    tab.Content = Create("ScrollingFrame", {
        Name = tab.Name .. "Content",
        Size = UDim2.new(1, -24, 1, -24),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Theme.AccentColor,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 5,
        Parent = self.ContentArea
    })
    
    tab.Layout = AddListLayout(tab.Content, 10)
    tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab click handler
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    -- Hover effect
    tab.Button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            TweenObject(tab.Button, {BackgroundTransparency = 0.75}, 0.15)
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            TweenObject(tab.Button, {BackgroundTransparency = 0.85}, 0.15)
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    -- Add component methods to tab
    setmetatable(tab, {
        __index = function(t, method)
            local components = {
                "CreateSection", "CreateLabel", "CreateCheckbox", "CreateCombobox",
                "CreateMultiCombobox", "CreateSlider", "CreateColorPicker",
                "CreateKeybinder", "CreateButton", "CreateTextBox"
            }
            for _, comp in ipairs(components) do
                if method == comp then
                    return function(_, cfg)
                        return self[comp](self, tab, cfg)
                    end
                end
            end
            return nil
        end
    })
    
    return tab
end

function LiquidGlassUI.Window:SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        t.Content.Visible = false
        t.Button.BackgroundTransparency = 0.85
        t.Button.BackgroundColor3 = Theme.GlassColor
    end
    
    tab.Content.Visible = true
    tab.Button.BackgroundTransparency = 0.6
    tab.Button.BackgroundColor3 = Theme.AccentColor
    
    self.CurrentTab = tab
end

-- Close all dropdowns when clicking elsewhere
function LiquidGlassUI.Window:CloseAllDropdowns(except)
    for name, dropdown in pairs(self.OpenDropdowns) do
        if name ~= except and dropdown.Open then
            dropdown:Close()
        end
    end
end

-- Section Component
function LiquidGlassUI.Window:CreateSection(tab, config)
    config = config or {}
    local section = {Name = config.Name or "Section"}
    
    section.Frame = Create("Frame", {
        Name = "Section",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = tab.Content
    })
    
    Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = section.Name:upper(),
        TextColor3 = Theme.AccentColor,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = section.Frame
    })
    
    local separator = Create("Frame", {
        Name = "Separator",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = Theme.AccentColor,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = section.Frame
    })
    AddCorner(separator, UDim.new(0, 1))
    
    return section
end

-- Label Component
function LiquidGlassUI.Window:CreateLabel(tab, config)
    config = config or {}
    local label = {Text = config.Text or "Label"}
    
    label.Frame = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = label.Text,
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
        Parent = tab.Content
    })
    
    function label:SetText(text)
        label.Text = text
        label.Frame.Text = text
    end
    
    return label
end

-- Checkbox Component
function LiquidGlassUI.Window:CreateCheckbox(tab, config)
    config = config or {}
    local checkbox = {
        Name = config.Name or "Checkbox",
        Value = config.Default or false,
        Callback = config.Callback or function() end
    }
    
    checkbox.Frame = Create("Frame", {
        Name = "Checkbox",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = tab.Content
    })
    
    -- Checkbox box
    checkbox.Box = Create("TextButton", {
        Name = "Box",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 0, 0.5, -12),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = checkbox.Frame
    })
    AddCorner(checkbox.Box, Theme.SmallCornerRadius)
    AddStroke(checkbox.Box, Theme.InnerGlowColor, 1.5, 0.4)
    
    -- Checkmark
    checkbox.CheckIcon = Create("TextLabel", {
        Name = "Check",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.AccentColor,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Visible = checkbox.Value,
        ZIndex = 7,
        Parent = checkbox.Box
    })
    
    -- Label
    Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -35, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text = checkbox.Name,
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = checkbox.Frame
    })
    
    checkbox.Box.MouseButton1Click:Connect(function()
        checkbox:SetValue(not checkbox.Value)
    end)
    
    function checkbox:SetValue(value)
        checkbox.Value = value
        checkbox.CheckIcon.Visible = value
        
        if value then
            TweenObject(checkbox.Box, {
                BackgroundColor3 = Theme.AccentColor,
                BackgroundTransparency = 0.5
            }, 0.15)
        else
            TweenObject(checkbox.Box, {
                BackgroundColor3 = Theme.GlassColor,
                BackgroundTransparency = 0.7
            }, 0.15)
        end
        
        checkbox.Callback(value)
    end
    
    checkbox:SetValue(checkbox.Value)
    return checkbox
end

-- Combobox Component
function LiquidGlassUI.Window:CreateCombobox(tab, config)
    config = config or {}
    local combobox = {
        Name = config.Name or "Combobox",
        Options = config.Options or {"Option 1", "Option 2"},
        Value = config.Default or config.Options[1],
        Callback = config.Callback or function() end,
        Open = false,
        DropdownId = "combobox_" .. tostring(math.random(10000, 99999))
    }
    
    combobox.Frame = Create("Frame", {
        Name = "Combobox",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = tab.Content
    })
    
    -- Label
    Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = combobox.Name,
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = combobox.Frame
    })
    
    -- Dropdown button
    combobox.Button = Create("TextButton", {
        Name = "DropdownBtn",
        Size = UDim2.new(0, 180, 0, 32),
        Position = UDim2.new(1, -185, 0.5, -16),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = Theme.GlassOpacity,
        BorderSizePixel = 0,
        Text = combobox.Value,
        TextColor3 = Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = combobox.Frame
    })
    AddCorner(combobox.Button, Theme.SmallCornerRadius)
    AddStroke(combobox.Button, Theme.InnerGlowColor, 1, 0.5)
    
    -- Arrow
    combobox.Arrow = Create("TextLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 7,
        Parent = combobox.Button
    })
    
    -- Dropdown container (placed at ScreenGui level for proper z-index)
    combobox.DropdownContainer = Create("Frame", {
        Name = combobox.DropdownId,
        Size = UDim2.new(0, 180, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = Theme.GlassOpacity,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 100,
        Parent = self.ScreenGui
    })
    AddCorner(combobox.DropdownContainer, Theme.SmallCornerRadius)
    AddStroke(combobox.DropdownContainer, Theme.InnerGlowColor, 1.5, 0.4)
    CreateDropShadow(combobox.DropdownContainer, UDim2.new(1, 30, 1, 30), -15)
    
    combobox.DropdownList = Create("ScrollingFrame", {
        Name = "List",
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 101,
        Parent = combobox.DropdownContainer
    })
    
    combobox.ListLayout = AddListLayout(combobox.DropdownList, 2)
    
    -- Create options
    for _, option in ipairs(combobox.Options) do
        local optBtn = Create("TextButton", {
            Name = option,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = Theme.TextDark,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            ZIndex = 102,
            Parent = combobox.DropdownList
        })
        AddPadding(optBtn, 8)
        
        optBtn.MouseButton1Click:Connect(function()
            combobox:SetValue(option)
            combobox:Close()
        end)
        
        optBtn.MouseEnter:Connect(function()
            TweenObject(optBtn, {BackgroundColor3 = Theme.AccentColor, BackgroundTransparency = 0.7}, 0.1)
        end)
        
        optBtn.MouseLeave:Connect(function()
            TweenObject(optBtn, {BackgroundTransparency = 1}, 0.1)
        end)
    end
    
    combobox.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        combobox.DropdownList.CanvasSize = UDim2.new(0, 0, 0, combobox.ListLayout.AbsoluteContentSize.Y)
    end)
    
    function combobox:Open()
        combobox.Open = true
        self.Window:CloseAllDropdowns(combobox.DropdownId)
        
        -- Calculate position
        local buttonPos = combobox.Button.AbsolutePosition
        local buttonSize = combobox.Button.AbsoluteSize
        
        combobox.DropdownContainer.Position = UDim2.new(0, buttonPos.X, 0, buttonPos.Y + buttonSize.Y + 4)
        combobox.DropdownContainer.Visible = true
        
        local targetHeight = math.min(#combobox.Options * 32 + 12, 200)
        TweenObject(combobox.DropdownContainer, {Size = UDim2.new(0, 180, 0, targetHeight)}, 0.2)
        combobox.Arrow.Text = "^"
        
        self.Window.OpenDropdowns[combobox.DropdownId] = combobox
    end
    
    function combobox:Close()
        combobox.Open = false
        TweenObject(combobox.DropdownContainer, {Size = UDim2.new(0, 180, 0, 0)}, 0.15)
        task.delay(0.15, function()
            combobox.DropdownContainer.Visible = false
        end)
        combobox.Arrow.Text = "v"
        self.Window.OpenDropdowns[combobox.DropdownId] = nil
    end
    
    function combobox:Toggle()
        if combobox.Open then
            combobox:Close()
        else
            combobox:Open()
        end
    end
    
    function combobox:SetValue(value)
        combobox.Value = value
        combobox.Button.Text = value
        combobox.Callback(value)
    end
    
    combobox.Button.MouseButton1Click:Connect(function()
        combobox:Toggle()
    end)
    
    -- Close on click outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and combobox.Open then
            local mousePos = UserInputService:GetMouseLocation()
            local btnPos = combobox.Button.AbsolutePosition
            local btnSize = combobox.Button.AbsoluteSize
            local dropPos = combobox.DropdownContainer.AbsolutePosition
            local dropSize = combobox.DropdownContainer.AbsoluteSize
            
            local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X
                and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
            local inDropdown = mousePos.X >= dropPos.X and mousePos.X <= dropPos.X + dropSize.X
                and mousePos.Y >= dropPos.Y and mousePos.Y <= dropPos.Y + dropSize.Y
            
            if not inButton and not inDropdown then
                combobox:Close()
            end
        end
    end)
    
    return combobox
end

-- Multi-Combobox Component
function LiquidGlassUI.Window:CreateMultiCombobox(tab, config)
    config = config or {}
    local multicombo = {
        Name = config.Name or "MultiCombobox",
        Options = config.Options or {"Option 1", "Option 2"},
        Values = config.Default or {},
        Callback = config.Callback or function() end,
        Open = false,
        DropdownId = "multicombo_" .. tostring(math.random(10000, 99999))
    }
    
    multicombo.Frame = Create("Frame", {
        Name = "MultiCombobox",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = tab.Content
    })
    
    Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = multicombo.Name,
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = multicombo.Frame
    })
    
    multicombo.Button = Create("TextButton", {
        Name = "Btn",
        Size = UDim2.new(0, 180, 0, 32),
        Position = UDim2.new(1, -185, 0.5, -16),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = Theme.GlassOpacity,
        BorderSizePixel = 0,
        Text = #multicombo.Values > 0 and table.concat(multicombo.Values, ", ") or "Select...",
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = multicombo.Frame
    })
    AddCorner(multicombo.Button, Theme.SmallCornerRadius)
    AddStroke(multicombo.Button, Theme.InnerGlowColor, 1, 0.5)
    
    multicombo.Arrow = Create("TextLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 7,
        Parent = multicombo.Button
    })
    
    -- Dropdown at ScreenGui level
    multicombo.DropdownContainer = Create("Frame", {
        Name = multicombo.DropdownId,
        Size = UDim2.new(0, 180, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = Theme.GlassOpacity,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 100,
        Parent = self.ScreenGui
    })
    AddCorner(multicombo.DropdownContainer, Theme.SmallCornerRadius)
    AddStroke(multicombo.DropdownContainer, Theme.InnerGlowColor, 1.5, 0.4)
    CreateDropShadow(multicombo.DropdownContainer, UDim2.new(1, 30, 1, 30), -15)
    
    multicombo.DropdownList = Create("ScrollingFrame", {
        Name = "List",
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 101,
        Parent = multicombo.DropdownContainer
    })
    
    multicombo.ListLayout = AddListLayout(multicombo.DropdownList, 2)
    multicombo.OptionBoxes = {}
    
    for _, option in ipairs(multicombo.Options) do
        local optFrame = Create("TextButton", {
            Name = option,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 102,
            Parent = multicombo.DropdownList
        })
        
        local box = Create("Frame", {
            Name = "Box",
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 8, 0.5, -9),
            BackgroundColor3 = Theme.GlassColor,
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            ZIndex = 103,
            Parent = optFrame
        })
        AddCorner(box, UDim.new(0, 4))
        AddStroke(box, Theme.InnerGlowColor, 1, 0.5)
        
        Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -38, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = Theme.TextDark,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 103,
            Parent = optFrame
        })
        
        multicombo.OptionBoxes[option] = box
        
        optFrame.MouseButton1Click:Connect(function()
            multicombo:ToggleOption(option)
        end)
    end
    
    multicombo.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        multicombo.DropdownList.CanvasSize = UDim2.new(0, 0, 0, multicombo.ListLayout.AbsoluteContentSize.Y)
    end)
    
    function multicombo:Open()
        multicombo.Open = true
        self.Window:CloseAllDropdowns(multicombo.DropdownId)
        
        local buttonPos = multicombo.Button.AbsolutePosition
        local buttonSize = multicombo.Button.AbsoluteSize
        
        multicombo.DropdownContainer.Position = UDim2.new(0, buttonPos.X, 0, buttonPos.Y + buttonSize.Y + 4)
        multicombo.DropdownContainer.Visible = true
        
        local targetHeight = math.min(#multicombo.Options * 32 + 12, 200)
        TweenObject(multicombo.DropdownContainer, {Size = UDim2.new(0, 180, 0, targetHeight)}, 0.2)
        multicombo.Arrow.Text = "^"
        
        self.Window.OpenDropdowns[multicombo.DropdownId] = multicombo
    end
    
    function multicombo:Close()
        multicombo.Open = false
        TweenObject(multicombo.DropdownContainer, {Size = UDim2.new(0, 180, 0, 0)}, 0.15)
        task.delay(0.15, function()
            multicombo.DropdownContainer.Visible = false
        end)
        multicombo.Arrow.Text = "v"
        self.Window.OpenDropdowns[multicombo.DropdownId] = nil
    end
    
    function multicombo:Toggle()
        if multicombo.Open then
            multicombo:Close()
        else
            multicombo:Open()
        end
    end
    
    function multicombo:ToggleOption(option)
        local idx = table.find(multicombo.Values, option)
        local box = multicombo.OptionBoxes[option]
        
        if idx then
            table.remove(multicombo.Values, idx)
            TweenObject(box, {BackgroundColor3 = Theme.GlassColor, BackgroundTransparency = 0.7}, 0.15)
        else
            table.insert(multicombo.Values, option)
            TweenObject(box, {BackgroundColor3 = Theme.AccentColor, BackgroundTransparency = 0.5}, 0.15)
        end
        
        multicombo.Button.Text = #multicombo.Values > 0 and table.concat(multicombo.Values, ", ") or "Select..."
        multicombo.Callback(multicombo.Values)
    end
    
    multicombo.Button.MouseButton1Click:Connect(function()
        multicombo:Toggle()
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and multicombo.Open then
            local mousePos = UserInputService:GetMouseLocation()
            local btnPos = multicombo.Button.AbsolutePosition
            local btnSize = multicombo.Button.AbsoluteSize
            local dropPos = multicombo.DropdownContainer.AbsolutePosition
            local dropSize = multicombo.DropdownContainer.AbsoluteSize
            
            local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X
                and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
            local inDropdown = mousePos.X >= dropPos.X and mousePos.X <= dropPos.X + dropSize.X
                and mousePos.Y >= dropPos.Y and mousePos.Y <= dropPos.Y + dropSize.Y
            
            if not inButton and not inDropdown then
                multicombo:Close()
            end
        end
    end)
    
    -- Initialize selected options
    for _, option in ipairs(multicombo.Values) do
        if multicombo.OptionBoxes[option] then
            multicombo.OptionBoxes[option].BackgroundColor3 = Theme.AccentColor
            multicombo.OptionBoxes[option].BackgroundTransparency = 0.5
        end
    end
    
    return multicombo
end

-- Slider Component
function LiquidGlassUI.Window:CreateSlider(tab, config)
    config = config or {}
    local slider = {
        Name = config.Name or "Slider",
        Min = config.Min or 0,
        Max = config.Max or 100,
        Value = config.Default or 50,
        Suffix = config.Suffix or "",
        Decimals = config.Decimals or 0,
        Callback = config.Callback or function() end
    }
    
    slider.Frame = Create("Frame", {
        Name = "Slider",
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = tab.Content
    })
    
    -- Label
    Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.5, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = slider.Name,
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = slider.Frame
    })
    
    -- Value display
    slider.ValueLabel = Create("TextLabel", {
        Name = "Value",
        Size = UDim2.new(0.5, 0, 0, 22),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = slider.Value .. slider.Suffix,
        TextColor3 = Theme.AccentColor,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 6,
        Parent = slider.Frame
    })
    
    -- Track background
    slider.Track = Create("Frame", {
        Name = "Track",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = slider.Frame
    })
    AddCorner(slider.Track, UDim.new(0, 5))
    AddStroke(slider.Track, Theme.InnerGlowColor, 1, 0.6)
    
    -- Fill with gradient
    slider.Fill = Create("Frame", {
        Name = "Fill",
        Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
        BackgroundColor3 = Theme.AccentColor,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 7,
        Parent = slider.Track
    })
    AddCorner(slider.Fill, UDim.new(0, 5))
    AddGradient(slider.Fill, Theme.AccentGradient[1], Theme.AccentGradient[3], 90)
    
    -- Handle
    slider.Handle = Create("TextButton", {
        Name = "Handle",
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -11, 0.5, -11),
        BackgroundColor3 = Theme.TextPrimary,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 8,
        Parent = slider.Track
    })
    AddCorner(slider.Handle, UDim.new(0, 11))
    AddStroke(slider.Handle, Theme.AccentColor, 2, 0)
    
    local dragging = false
    
    local function updateSlider(input)
        local percent = math.clamp((input.Position.X - slider.Track.AbsolutePosition.X) / slider.Track.AbsoluteSize.X, 0, 1)
        local value = slider.Min + (slider.Max - slider.Min) * percent
        
        if slider.Decimals > 0 then
            value = math.floor(value * (10 ^ slider.Decimals)) / (10 ^ slider.Decimals)
        else
            value = math.floor(value)
        end
        
        slider:SetValue(value)
    end
    
    slider.Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    slider.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    function slider:SetValue(value)
        slider.Value = math.clamp(value, slider.Min, slider.Max)
        local percent = (slider.Value - slider.Min) / (slider.Max - slider.Min)
        
        slider.Fill.Size = UDim2.new(percent, 0, 1, 0)
        slider.Handle.Position = UDim2.new(percent, -11, 0.5, -11)
        slider.ValueLabel.Text = slider.Value .. slider.Suffix
        
        slider.Callback(slider.Value)
    end
    
    return slider
end

-- Color Picker Component
function LiquidGlassUI.Window:CreateColorPicker(tab, config)
    config = config or {}
    local picker = {
        Name = config.Name or "ColorPicker",
        Value = config.Default or Color3.fromRGB(255, 255, 255),
        Callback = config.Callback or function() end,
        Open = false,
        PickerId = "colorpicker_" .. tostring(math.random(10000, 99999))
    }
    
    picker.Frame = Create("Frame", {
        Name = "ColorPicker",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = tab.Content
    })
    
    Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = picker.Name,
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = picker.Frame
    })
    
    -- Color preview button
    picker.Button = Create("TextButton", {
        Name = "Preview",
        Size = UDim2.new(0, 70, 0, 28),
        Position = UDim2.new(1, -75, 0.5, -14),
        BackgroundColor3 = picker.Value,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = picker.Frame
    })
    AddCorner(picker.Button, Theme.SmallCornerRadius)
    AddStroke(picker.Button, Theme.InnerGlowColor, 1, 0.4)
    
    -- Picker container at ScreenGui level
    picker.Container = Create("Frame", {
        Name = picker.PickerId,
        Size = UDim2.new(0, 220, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = Theme.GlassOpacity,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 100,
        Parent = self.ScreenGui
    })
    AddCorner(picker.Container, Theme.CornerRadius)
    AddStroke(picker.Container, Theme.InnerGlowColor, 1.5, 0.4)
    CreateDropShadow(picker.Container, UDim2.new(1, 40, 1, 40), -20)
    
    -- Saturation/Value area
    picker.SatVal = Create("TextButton", {
        Name = "SatVal",
        Size = UDim2.new(0, 200, 0, 160),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BackgroundTransparency = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 101,
        Parent = picker.Container
    })
    AddCorner(picker.SatVal, Theme.SmallCornerRadius)
    
    -- White gradient (horizontal)
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Rotation = 0,
        Parent = picker.SatVal
    })
    
    -- Black gradient (vertical)
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation = 90,
        Parent = picker.SatVal
    })
    
    -- SatVal indicator
    picker.SVIndicator = Create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -7, 0, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = picker.SatVal
    })
    AddCorner(picker.SVIndicator, UDim.new(0, 7))
    AddStroke(picker.SVIndicator, Color3.fromRGB(0, 0, 0), 2, 0.3)
    
    -- Hue slider
    picker.Hue = Create("TextButton", {
        Name = "Hue",
        Size = UDim2.new(0, 200, 0, 22),
        Position = UDim2.new(0, 10, 0, 180),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 101,
        Parent = picker.Container
    })
    AddCorner(picker.Hue, UDim.new(0, 11))
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }),
        Parent = picker.Hue
    })
    
    -- Hue indicator
    picker.HueIndicator = Create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 12, 0, 26),
        Position = UDim2.new(0, -6, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = picker.Hue
    })
    AddCorner(picker.HueIndicator, UDim.new(0, 6))
    AddStroke(picker.HueIndicator, Color3.fromRGB(80, 80, 80), 1, 0.3)
    
    -- RGB inputs
    picker.RGBFrame = Create("Frame", {
        Name = "RGB",
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 10, 0, 210),
        BackgroundTransparency = 1,
        ZIndex = 101,
        Parent = picker.Container
    })
    
    picker.RGBInputs = {}
    local rgbLabels = {"R", "G", "B"}
    
    for i, label in ipairs(rgbLabels) do
        local input = Create("TextBox", {
            Name = label,
            Size = UDim2.new(0, 62, 0, 28),
            Position = UDim2.new(0, (i - 1) * 68, 0, 0),
            BackgroundColor3 = Theme.GlassColor,
            BackgroundTransparency = 0.5,
            Text = "255",
            TextColor3 = Theme.TextDark,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            PlaceholderText = label,
            ZIndex = 102,
            Parent = picker.RGBFrame
        })
        AddCorner(input, Theme.SmallCornerRadius)
        AddStroke(input, Theme.InnerGlowColor, 1, 0.5)
        
        input.FocusLost:Connect(function()
            local val = math.clamp(tonumber(input.Text) or 0, 0, 255)
            input.Text = math.floor(val)
            picker:UpdateFromRGB()
        end)
        
        picker.RGBInputs[label] = input
    end
    
    -- State
    local h, s, v = RGBtoHSV(picker.Value)
    
    local function updateDisplay()
        local color = HSVtoRGB(h, s, v)
        picker.Button.BackgroundColor3 = color
        picker.SatVal.BackgroundColor3 = HSVtoRGB(h, 1, 1)
        
        picker.RGBInputs.R.Text = math.floor(color.R * 255)
        picker.RGBInputs.G.Text = math.floor(color.G * 255)
        picker.RGBInputs.B.Text = math.floor(color.B * 255)
        
        picker.Value = color
        picker.Callback(color)
    end
    
    function picker:UpdateFromRGB()
        local r = tonumber(picker.RGBInputs.R.Text) or 0
        local g = tonumber(picker.RGBInputs.G.Text) or 0
        local b = tonumber(picker.RGBInputs.B.Text) or 0
        picker:SetValue(Color3.fromRGB(r, g, b))
    end
    
    -- SatVal dragging
    local svDragging = false
    
    picker.SatVal.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = true
            local pos = (input.Position - picker.SatVal.AbsolutePosition) / picker.SatVal.AbsoluteSize
            s = math.clamp(pos.X, 0, 1)
            v = 1 - math.clamp(pos.Y, 0, 1)
            picker.SVIndicator.Position = UDim2.new(s, -7, 1 - v, -7)
            updateDisplay()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = (input.Position - picker.SatVal.AbsolutePosition) / picker.SatVal.AbsoluteSize
            s = math.clamp(pos.X, 0, 1)
            v = 1 - math.clamp(pos.Y, 0, 1)
            picker.SVIndicator.Position = UDim2.new(s, -7, 1 - v, -7)
            updateDisplay()
        end
    end)
    
    -- Hue dragging
    local hueDragging = false
    
    picker.Hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            local pos = (input.Position - picker.Hue.AbsolutePosition) / picker.Hue.AbsoluteSize
            h = math.clamp(pos.X, 0, 1)
            picker.HueIndicator.Position = UDim2.new(h, -6, 0.5, -13)
            updateDisplay()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = (input.Position - picker.Hue.AbsolutePosition) / picker.Hue.AbsoluteSize
            h = math.clamp(pos.X, 0, 1)
            picker.HueIndicator.Position = UDim2.new(h, -6, 0.5, -13)
            updateDisplay()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = false
            hueDragging = false
        end
    end)
    
    function picker:Open()
        picker.Open = true
        self.Window:CloseAllDropdowns(picker.PickerId)
        
        local btnPos = picker.Button.AbsolutePosition
        local btnSize = picker.Button.AbsoluteSize
        
        picker.Container.Position = UDim2.new(0, btnPos.X - 75, 0, btnPos.Y + btnSize.Y + 4)
        picker.Container.Visible = true
        TweenObject(picker.Container, {Size = UDim2.new(0, 220, 0, 250)}, 0.25)
        
        self.Window.OpenDropdowns[picker.PickerId] = picker
    end
    
    function picker:Close()
        picker.Open = false
        TweenObject(picker.Container, {Size = UDim2.new(0, 220, 0, 0)}, 0.2)
        task.delay(0.2, function()
            picker.Container.Visible = false
        end)
        self.Window.OpenDropdowns[picker.PickerId] = nil
    end
    
    function picker:Toggle()
        if picker.Open then
            picker:Close()
        else
            picker:Open()
        end
    end
    
    function picker:SetValue(color)
        picker.Value = color
        picker.Button.BackgroundColor3 = color
        h, s, v = RGBtoHSV(color)
        
        picker.SVIndicator.Position = UDim2.new(s, -7, 1 - v, -7)
        picker.HueIndicator.Position = UDim2.new(h, -6, 0.5, -13)
        picker.SatVal.BackgroundColor3 = HSVtoRGB(h, 1, 1)
        
        picker.RGBInputs.R.Text = math.floor(color.R * 255)
        picker.RGBInputs.G.Text = math.floor(color.G * 255)
        picker.RGBInputs.B.Text = math.floor(color.B * 255)
        
        picker.Callback(color)
    end
    
    picker.Button.MouseButton1Click:Connect(function()
        picker:Toggle()
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and picker.Open then
            local mousePos = UserInputService:GetMouseLocation()
            local btnPos = picker.Button.AbsolutePosition
            local btnSize = picker.Button.AbsoluteSize
            local contPos = picker.Container.AbsolutePosition
            local contSize = picker.Container.AbsoluteSize
            
            local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X
                and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
            local inContainer = mousePos.X >= contPos.X and mousePos.X <= contPos.X + contSize.X
                and mousePos.Y >= contPos.Y and mousePos.Y <= contPos.Y + contSize.Y
            
            if not inButton and not inContainer then
                picker:Close()
            end
        end
    end)
    
    -- Initialize
    picker:SetValue(picker.Value)
    
    return picker
end

-- Keybinder Component
function LiquidGlassUI.Window:CreateKeybinder(tab, config)
    config = config or {}
    local keybinder = {
        Name = config.Name or "Keybinder",
        Value = config.Default or Enum.KeyCode.Unknown,
        Callback = config.Callback or function() end,
        Listening = false
    }
    
    keybinder.Frame = Create("Frame", {
        Name = "Keybinder",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = tab.Content
    })
    
    Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = keybinder.Name,
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = keybinder.Frame
    })
    
    keybinder.Button = Create("TextButton", {
        Name = "KeyBtn",
        Size = UDim2.new(0, 110, 0, 32),
        Position = UDim2.new(1, -115, 0.5, -16),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = Theme.GlassOpacity,
        BorderSizePixel = 0,
        Text = keybinder.Value.Name or "None",
        TextColor3 = Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = keybinder.Frame
    })
    AddCorner(keybinder.Button, Theme.SmallCornerRadius)
    AddStroke(keybinder.Button, Theme.InnerGlowColor, 1, 0.5)
    
    keybinder.Button.MouseButton1Click:Connect(function()
        keybinder:StartListening()
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if keybinder.Listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                keybinder:SetValue(input.KeyCode)
                keybinder:StopListening()
            end
        elseif not gameProcessed and input.KeyCode == keybinder.Value then
            keybinder.Callback()
        end
    end)
    
    function keybinder:StartListening()
        keybinder.Listening = true
        keybinder.Button.Text = "..."
        TweenObject(keybinder.Button, {BackgroundColor3 = Theme.AccentColor, BackgroundTransparency = 0.5}, 0.15)
    end
    
    function keybinder:StopListening()
        keybinder.Listening = false
        TweenObject(keybinder.Button, {BackgroundColor3 = Theme.GlassColor, BackgroundTransparency = Theme.GlassOpacity}, 0.15)
    end
    
    function keybinder:SetValue(keycode)
        keybinder.Value = keycode
        keybinder.Button.Text = keycode.Name or "None"
    end
    
    return keybinder
end

-- Button Component
function LiquidGlassUI.Window:CreateButton(tab, config)
    config = config or {}
    local button = {
        Name = config.Name or "Button",
        Callback = config.Callback or function() end
    }
    
    button.Frame = Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.AccentColor,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = button.Name,
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = tab.Content
    })
    AddCorner(button.Frame, Theme.SmallCornerRadius)
    AddGradient(button.Frame, Theme.AccentGradient[1], Theme.AccentGradient[3], 90)
    AddStroke(button.Frame, Theme.InnerGlowColor, 1, 0.4)
    
    button.Frame.MouseButton1Click:Connect(function()
        button.Callback()
    end)
    
    button.Frame.MouseEnter:Connect(function()
        TweenObject(button.Frame, {BackgroundTransparency = 0.1}, 0.15)
    end)
    
    button.Frame.MouseLeave:Connect(function()
        TweenObject(button.Frame, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    return button
end

-- TextBox Component
function LiquidGlassUI.Window:CreateTextBox(tab, config)
    config = config or {}
    local textbox = {
        Name = config.Name or "TextBox",
        Value = config.Default or "",
        Placeholder = config.Placeholder or "Enter text...",
        Callback = config.Callback or function() end
    }
    
    textbox.Frame = Create("Frame", {
        Name = "TextBox",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = tab.Content
    })
    
    Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 1,
        Text = textbox.Name,
        TextColor3 = Theme.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = textbox.Frame
    })
    
    textbox.Input = Create("TextBox", {
        Name = "Input",
        Size = UDim2.new(0, 220, 0, 32),
        Position = UDim2.new(1, -225, 0.5, -16),
        BackgroundColor3 = Theme.GlassColor,
        BackgroundTransparency = Theme.GlassOpacity,
        BorderSizePixel = 0,
        Text = textbox.Value,
        TextColor3 = Theme.TextDark,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        PlaceholderText = textbox.Placeholder,
        PlaceholderColor3 = Color3.fromRGB(150, 150, 160),
        ZIndex = 6,
        Parent = textbox.Frame
    })
    AddCorner(textbox.Input, Theme.SmallCornerRadius)
    AddStroke(textbox.Input, Theme.InnerGlowColor, 1, 0.5)
    
    textbox.Input.FocusLost:Connect(function()
        textbox.Value = textbox.Input.Text
        textbox.Callback(textbox.Value)
    end)
    
    function textbox:SetValue(value)
        textbox.Value = value
        textbox.Input.Text = value
        textbox.Callback(value)
    end
    
    return textbox
end

-- Destroy
function LiquidGlassUI.Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return LiquidGlassUI
