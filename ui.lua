--[[
    LiquidGlassUI - A modern UI library for Roblox executors
    Style: iOS 26 Liquid Glass inspired
    Features: Blur, transparency, glassmorphism effects
    
    Usage:
        local LiquidGlassUI = loadstring(game:HttpGet("path"))()
        local Window = LiquidGlassUI:CreateWindow({
            Name = "My Menu",
            Size = UDim2.new(0, 500, 0, 400)
        })
]]

local LiquidGlassUI = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Constants
local CORNER_RADIUS = UDim.new(0, 16)
local GLASS_BACKGROUND = Color3.fromRGB(255, 255, 255)
local GLASS_TRANSPARENCY = 0.15
local BLUR_SIZE = 24
local ANIMATION_DURATION = 0.3

-- Utility Functions
local function Create(instance, properties)
    local obj = Instance.new(instance)
    for prop, value in pairs(properties) do
        obj[prop] = value
    end
    return obj
end

local function CreateCorner(parent, radius)
    local corner = Create("UICorner", {
        CornerRadius = radius or CORNER_RADIUS
    })
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Create("UIStroke", {
        Color = color or Color3.fromRGB(255, 255, 255),
        Thickness = thickness or 1,
        Transparency = transparency or 0.5
    })
    stroke.Parent = parent
    return stroke
end

local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1 or Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, color2 or Color3.fromRGB(200, 200, 200))
        }),
        Rotation = rotation or 45
    })
    gradient.Parent = parent
    return gradient
end

local function CreatePadding(parent, padding)
    local pad = Create("UIPadding", {
        PaddingLeft = UDim.new(0, padding or 10),
        PaddingRight = UDim.new(0, padding or 10),
        PaddingTop = UDim.new(0, padding or 10),
        PaddingBottom = UDim.new(0, padding or 10)
    })
    pad.Parent = parent
    return pad
end

local function CreateListLayout(parent, direction, padding)
    local layout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, padding or 8)
    })
    layout.Parent = parent
    return layout
end

local function Tween(obj, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(obj, TweenInfo.new(
        duration or ANIMATION_DURATION,
        easingStyle or Enum.EasingStyle.Quart,
        easingDirection or Enum.EasingDirection.Out
    ), properties)
    tween:Play()
    return tween
end

-- Color Picker Helper
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
    
    return Color3.fromRGB(r * 255, g * 255, b * 255)
end

local function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, max
    
    local d = max - min
    if max > 0 then s = d / max end
    
    if max == min then
        h = 0
    elseif max == r then
        h = (g - b) / d
        if g < b then h = h + 6 end
    elseif max == g then
        h = (b - r) / d + 2
    elseif max == b then
        h = (r - g) / d + 4
    end
    
    h = h / 6
    return h, s, v
end

-- Glass Effect Component
local function CreateGlassEffect(parent)
    -- Main glass background
    local glass = Create("Frame", {
        Name = "GlassEffect",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GLASS_BACKGROUND,
        BackgroundTransparency = GLASS_TRANSPARENCY,
        BorderSizePixel = 0,
        Parent = parent
    })
    CreateCorner(glass, CORNER_RADIUS)
    
    -- Gradient overlay for glass effect
    CreateGradient(glass, Color3.fromRGB(255, 255, 255), Color3.fromRGB(240, 240, 245), 135)
    
    -- Subtle border
    CreateStroke(glass, Color3.fromRGB(255, 255, 255), 1, 0.3)
    
    -- Inner glow effect
    local innerGlow = Create("Frame", {
        Name = "InnerGlow",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Parent = glass
    })
    CreateCorner(innerGlow, CORNER_RADIUS)
    
    return glass
end

-- Blur Background (simulated with multiple layers)
local function CreateBlurBackground(parent)
    -- Outer shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://601425199",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = parent
    })
    
    return shadow
end

-- Window Class
LiquidGlassUI.Window = {}
LiquidGlassUI.Window.__index = LiquidGlassUI.Window

function LiquidGlassUI:CreateWindow(config)
    local self = setmetatable({}, LiquidGlassUI.Window)
    
    self.Name = config.Name or "LiquidGlass UI"
    self.Size = config.Size or UDim2.new(0, 500, 0, 400)
    self.Position = config.Position or UDim2.new(0.5, -250, 0.5, -200)
    self.Theme = config.Theme or "Dark"
    self.Tabs = {}
    self.CurrentTab = nil
    self.Visible = true
    
    -- Create ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "LiquidGlassUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    -- Get appropriate parent
    local player = Players.LocalPlayer
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        self.ScreenGui.Parent = playerGui
    else
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    -- Main Container
    self.Container = Create("Frame", {
        Name = "Container",
        Size = self.Size,
        Position = self.Position,
        BackgroundTransparency = 1,
        Parent = self.ScreenGui
    })
    
    -- Blur background
    CreateBlurBackground(self.Container)
    
    -- Glass effect
    self.Glass = CreateGlassEffect(self.Container)
    
    -- Window structure
    self:BuildWindow()
    
    -- Keybind toggle
    self:SetupKeybind()
    
    -- Make draggable
    self:MakeDraggable()
    
    return self
end

function LiquidGlassUI.Window:BuildWindow()
    -- Header
    self.Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        Parent = self.Container
    })
    
    -- Title
    self.Title = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Name,
        TextColor3 = Color3.fromRGB(40, 40, 45),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Header
    })
    
    -- Close button
    self.CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Color3.fromRGB(100, 100, 100),
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Parent = self.Header
    })
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Tab container (sidebar)
    self.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 120, 1, -55),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.Container
    })
    
    self.TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = self.TabContainer
    })
    
    self.TabListLayout = CreateListLayout(self.TabList, Enum.FillDirection.Vertical, 4)
    
    -- Content area
    self.ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -140, 1, -60),
        Position = UDim2.new(0, 135, 0, 50),
        BackgroundTransparency = 1,
        Parent = self.Container
    })
    
    -- Content container with glass effect
    self.ContentGlass = Create("Frame", {
        Name = "ContentGlass",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = Color3.fromRGB(250, 250, 252),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = self.ContentArea
    })
    CreateCorner(self.ContentGlass, UDim.new(0, 12))
    CreateStroke(self.ContentGlass, Color3.fromRGB(255, 255, 255), 1, 0.4)
end

function LiquidGlassUI.Window:MakeDraggable()
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
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
        Tween(self.Container, {Position = self.Position}, 0.3)
        self.ScreenGui.Enabled = true
    else
        Tween(self.Container, {Position = UDim2.new(self.Position.X.Scale, self.Position.X.Offset, -1, 0)}, 0.3)
        task.wait(0.3)
        self.ScreenGui.Enabled = false
    end
end

function LiquidGlassUI.Window:CreateTab(config)
    local tab = {
        Name = config.Name or "Tab",
        Icon = config.Icon,
        Elements = {},
        Window = self
    }
    
    -- Tab button
    tab.Button = Create("TextButton", {
        Name = tab.Name,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        Text = "",
        Parent = self.TabList
    })
    CreateCorner(tab.Button, UDim.new(0, 8))
    
    -- Tab button content
    local tabIcon = Create("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Icon or "¤",
        TextColor3 = Color3.fromRGB(80, 80, 85),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = tab.Button
    })
    
    local tabText = Create("TextLabel", {
        Name = "Text",
        Size = UDim2.new(1, -45, 1, 0),
        Position = UDim2.new(0, 35, 0, 0),
        BackgroundTransparency = 1,
        Text = tab.Name,
        TextColor3 = Color3.fromRGB(80, 80, 85),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tab.Button
    })
    
    -- Tab content frame
    tab.Content = Create("ScrollingFrame", {
        Name = tab.Name .. "Content",
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200),
        Visible = false,
        Parent = self.ContentGlass
    })
    
    tab.ListLayout = CreateListLayout(tab.Content, Enum.FillDirection.Vertical, 8)
    tab.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.ListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab button click
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    -- Create element methods
    setmetatable(tab, {
        __index = function(t, method)
            local componentMethods = {
                "CreateCheckbox", "CreateCombobox", "CreateMultiCombobox",
                "CreateSlider", "CreateColorPicker", "CreateKeybinder",
                "CreateButton", "CreateLabel", "CreateTextBox", "CreateSection"
            }
            
            for _, methodName in ipairs(componentMethods) do
                if method == methodName then
                    return function(_, config2)
                        return self:CreateComponent(tab, methodName, config2)
                    end
                end
            end
            
            return nil
        end
    })
    
    return tab
end

function LiquidGlassUI.Window:SelectTab(tab)
    -- Hide all tabs
    for _, t in ipairs(self.Tabs) do
        t.Content.Visible = false
        t.Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        t.Button.BackgroundTransparency = 0.8
    end
    
    -- Show selected tab
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    tab.Button.BackgroundTransparency = 0.7
    
    self.CurrentTab = tab
end

-- Component Creation
function LiquidGlassUI.Window:CreateComponent(tab, componentType, config)
    local component = {
        Type = componentType,
        Config = config,
        Tab = tab,
        Value = config.Default or config.Value
    }
    
    local methods = {
        CreateCheckbox = function() return self:CreateCheckbox(tab, config) end,
        CreateCombobox = function() return self:CreateCombobox(tab, config) end,
        CreateMultiCombobox = function() return self:CreateMultiCombobox(tab, config) end,
        CreateSlider = function() return self:CreateSlider(tab, config) end,
        CreateColorPicker = function() return self:CreateColorPicker(tab, config) end,
        CreateKeybinder = function() return self:CreateKeybinder(tab, config) end,
        CreateButton = function() return self:CreateButton(tab, config) end,
        CreateLabel = function() return self:CreateLabel(tab, config) end,
        CreateTextBox = function() return self:CreateTextBox(tab, config) end,
        CreateSection = function() return self:CreateSection(tab, config) end
    }
    
    if methods[componentType] then
        return methods[componentType]()
    end
end

-- Section Component
function LiquidGlassUI.Window:CreateSection(tab, config)
    local section = {
        Name = config.Name or "Section",
        Elements = {}
    }
    
    section.Frame = Create("Frame", {
        Name = section.Name,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    section.Label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = section.Name:upper(),
        TextColor3 = Color3.fromRGB(100, 100, 105),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section.Frame
    })
    
    -- Separator line
    section.Separator = Create("Frame", {
        Name = "Separator",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Color3.fromRGB(220, 220, 225),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = section.Frame
    })
    
    return section
end

-- Label Component
function LiquidGlassUI.Window:CreateLabel(tab, config)
    local label = {
        Text = config.Text or "Label"
    }
    
    label.Frame = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = label.Text,
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
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
    local checkbox = {
        Name = config.Name or "Checkbox",
        Value = config.Default or false,
        Callback = config.Callback or function() end
    }
    
    checkbox.Frame = Create("Frame", {
        Name = checkbox.Name,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    -- Checkbox box
    checkbox.Box = Create("TextButton", {
        Name = "Box",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.2,
        Text = "",
        Parent = checkbox.Frame
    })
    CreateCorner(checkbox.Box, UDim.new(0, 6))
    CreateStroke(checkbox.Box, Color3.fromRGB(200, 200, 200), 1, 0.5)
    
    -- Checkmark
    checkbox.Checkmark = Create("TextLabel", {
        Name = "Checkmark",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Color3.fromRGB(100, 150, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Visible = checkbox.Value,
        Parent = checkbox.Box
    })
    
    -- Label
    checkbox.Label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Text = checkbox.Name,
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = checkbox.Frame
    })
    
    -- Click handler
    checkbox.Box.MouseButton1Click:Connect(function()
        checkbox:SetValue(not checkbox.Value)
    end)
    
    function checkbox:SetValue(value)
        checkbox.Value = value
        checkbox.Checkmark.Visible = value
        
        if value then
            checkbox.Box.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            checkbox.Box.BackgroundTransparency = 0.3
        else
            checkbox.Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            checkbox.Box.BackgroundTransparency = 0.2
        end
        
        checkbox.Callback(value)
    end
    
    -- Initialize
    checkbox:SetValue(checkbox.Value)
    
    return checkbox
end

-- Combobox Component
function LiquidGlassUI.Window:CreateCombobox(tab, config)
    local combobox = {
        Name = config.Name or "Combobox",
        Options = config.Options or {"Option 1", "Option 2", "Option 3"},
        Value = config.Default or config.Options[1],
        Callback = config.Callback or function() end,
        Open = false
    }
    
    combobox.Frame = Create("Frame", {
        Name = combobox.Name,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    -- Label
    combobox.Label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 1,
        Text = combobox.Name,
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = combobox.Frame
    })
    
    -- Dropdown button
    combobox.Button = Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(0, 150, 0, 28),
        Position = UDim2.new(1, -155, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.15,
        Text = combobox.Value,
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        Parent = combobox.Frame
    })
    CreateCorner(combobox.Button, UDim.new(0, 8))
    CreateStroke(combobox.Button, Color3.fromRGB(200, 200, 200), 1, 0.5)
    
    -- Arrow indicator
    combobox.Arrow = Create("TextLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -22, 0, 0),
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = Color3.fromRGB(120, 120, 125),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = combobox.Button
    })
    
    -- Dropdown list
    combobox.Dropdown = Create("Frame", {
        Name = "Dropdown",
        Size = UDim2.new(0, 150, 0, 0),
        Position = UDim2.new(1, -155, 1, 4),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = combobox.Frame
    })
    CreateCorner(combobox.Dropdown, UDim.new(0, 8))
    CreateStroke(combobox.Dropdown, Color3.fromRGB(200, 200, 200), 1, 0.5)
    
    combobox.ListLayout = CreateListLayout(combobox.Dropdown, Enum.FillDirection.Vertical, 2)
    
    -- Create options
    for _, option in ipairs(combobox.Options) do
        local optionBtn = Create("TextButton", {
            Name = option,
            Size = UDim2.new(1, -16, 0, 26),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = Color3.fromRGB(60, 60, 65),
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = combobox.Dropdown
        })
        
        optionBtn.MouseButton1Click:Connect(function()
            combobox:SetValue(option)
            combobox:ToggleDropdown(false)
        end)
        
        optionBtn.MouseEnter:Connect(function()
            optionBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            optionBtn.BackgroundTransparency = 0.7
        end)
        
        optionBtn.MouseLeave:Connect(function()
            optionBtn.BackgroundTransparency = 1
        end)
    end
    
    -- Toggle dropdown
    combobox.Button.MouseButton1Click:Connect(function()
        combobox:ToggleDropdown(not combobox.Open)
    end)
    
    -- Close on click outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and combobox.Open then
            local mousePos = UserInputService:GetMouseLocation()
            local buttonPos = combobox.Button.AbsolutePosition
            local buttonSize = combobox.Button.AbsoluteSize
            local dropPos = combobox.Dropdown.AbsolutePosition
            local dropSize = combobox.Dropdown.AbsoluteSize
            
            local inButton = mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X
                and mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y
            local inDropdown = mousePos.X >= dropPos.X and mousePos.X <= dropPos.X + dropSize.X
                and mousePos.Y >= dropPos.Y and mousePos.Y <= dropPos.Y + dropSize.Y
            
            if not inButton and not inDropdown then
                combobox:ToggleDropdown(false)
            end
        end
    end)
    
    function combobox:ToggleDropdown(open)
        combobox.Open = open
        combobox.Dropdown.Visible = open
        
        if open then
            local targetSize = #combobox.Options * 28 + 8
            Tween(combobox.Dropdown, {Size = UDim2.new(0, 150, 0, targetSize)}, 0.2)
            combobox.Arrow.Text = "^"
        else
            Tween(combobox.Dropdown, {Size = UDim2.new(0, 150, 0, 0)}, 0.2)
            combobox.Arrow.Text = "v"
        end
    end
    
    function combobox:SetValue(value)
        combobox.Value = value
        combobox.Button.Text = value
        combobox.Callback(value)
    end
    
    return combobox
end

-- Multi-Combobox Component
function LiquidGlassUI.Window:CreateMultiCombobox(tab, config)
    local multicombo = {
        Name = config.Name or "MultiCombobox",
        Options = config.Options or {"Option 1", "Option 2", "Option 3"},
        Values = config.Default or {},
        Callback = config.Callback or function() end,
        Open = false
    }
    
    -- Initialize values as table
    if type(multicombo.Values) ~= "table" then
        multicombo.Values = {}
    end
    
    multicombo.Frame = Create("Frame", {
        Name = multicombo.Name,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    -- Label
    multicombo.Label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 1,
        Text = multicombo.Name,
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = multicombo.Frame
    })
    
    -- Button
    multicombo.Button = Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(0, 150, 0, 28),
        Position = UDim2.new(1, -155, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.15,
        Text = #multicombo.Values > 0 and table.concat(multicombo.Values, ", ") or "Select...",
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = multicombo.Frame
    })
    CreateCorner(multicombo.Button, UDim.new(0, 8))
    CreateStroke(multicombo.Button, Color3.fromRGB(200, 200, 200), 1, 0.5)
    
    -- Arrow
    multicombo.Arrow = Create("TextLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -22, 0, 0),
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = Color3.fromRGB(120, 120, 125),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = multicombo.Button
    })
    
    -- Dropdown
    multicombo.Dropdown = Create("Frame", {
        Name = "Dropdown",
        Size = UDim2.new(0, 150, 0, 0),
        Position = UDim2.new(1, -155, 1, 4),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = multicombo.Frame
    })
    CreateCorner(multicombo.Dropdown, UDim.new(0, 8))
    CreateStroke(multicombo.Dropdown, Color3.fromRGB(200, 200, 200), 1, 0.5)
    
    multicombo.ListLayout = CreateListLayout(multicombo.Dropdown, Enum.FillDirection.Vertical, 2)
    
    -- Option checkboxes
    multicombo.OptionCheckboxes = {}
    for _, option in ipairs(multicombo.Options) do
        local optionFrame = Create("TextButton", {
            Name = option,
            Size = UDim2.new(1, -16, 0, 26),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = multicombo.Dropdown
        })
        
        local optionBox = Create("Frame", {
            Name = "Box",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 4, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Parent = optionFrame
        })
        CreateCorner(optionBox, UDim.new(0, 4))
        CreateStroke(optionBox, Color3.fromRGB(200, 200, 200), 1, 0.5)
        
        local optionLabel = Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 26, 0, 0),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = Color3.fromRGB(60, 60, 65),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = optionFrame
        })
        
        local isSelected = table.find(multicombo.Values, option) ~= nil
        if isSelected then
            optionBox.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            optionBox.BackgroundTransparency = 0.3
        end
        
        multicombo.OptionCheckboxes[option] = optionBox
        
        optionFrame.MouseButton1Click:Connect(function()
            multicombo:ToggleOption(option)
        end)
    end
    
    multicombo.Button.MouseButton1Click:Connect(function()
        multicombo:ToggleDropdown(not multicombo.Open)
    end)
    
    function multicombo:ToggleDropdown(open)
        multicombo.Open = open
        multicombo.Dropdown.Visible = open
        
        if open then
            local targetSize = #multicombo.Options * 28 + 8
            Tween(multicombo.Dropdown, {Size = UDim2.new(0, 150, 0, targetSize)}, 0.2)
            multicombo.Arrow.Text = "^"
        else
            Tween(multicombo.Dropdown, {Size = UDim2.new(0, 150, 0, 0)}, 0.2)
            multicombo.Arrow.Text = "v"
        end
    end
    
    function multicombo:ToggleOption(option)
        local index = table.find(multicombo.Values, option)
        local checkbox = multicombo.OptionCheckboxes[option]
        
        if index then
            table.remove(multicombo.Values, index)
            checkbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            checkbox.BackgroundTransparency = 0.2
        else
            table.insert(multicombo.Values, option)
            checkbox.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            checkbox.BackgroundTransparency = 0.3
        end
        
        multicombo.Button.Text = #multicombo.Values > 0 and table.concat(multicombo.Values, ", ") or "Select..."
        multicombo.Callback(multicombo.Values)
    end
    
    function multicombo:SetValue(values)
        multicombo.Values = values
        for _, option in ipairs(multicombo.Options) do
            local checkbox = multicombo.OptionCheckboxes[option]
            if table.find(values, option) then
                checkbox.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                checkbox.BackgroundTransparency = 0.3
            else
                checkbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                checkbox.BackgroundTransparency = 0.2
            end
        end
        multicombo.Button.Text = #values > 0 and table.concat(values, ", ") or "Select..."
        multicombo.Callback(values)
    end
    
    return multicombo
end

-- Slider Component
function LiquidGlassUI.Window:CreateSlider(tab, config)
    local slider = {
        Name = config.Name or "Slider",
        Min = config.Min or 0,
        Max = config.Max or 100,
        Value = config.Default or 50,
        Suffix = config.Suffix or "",
        Callback = config.Callback or function() end,
        Decimals = config.Decimals or 0
    }
    
    slider.Frame = Create("Frame", {
        Name = slider.Name,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    -- Label and value display
    slider.Label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.5, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = slider.Name,
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = slider.Frame
    })
    
    slider.ValueLabel = Create("TextLabel", {
        Name = "Value",
        Size = UDim2.new(0.5, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = slider.Value .. slider.Suffix,
        TextColor3 = Color3.fromRGB(100, 150, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = slider.Frame
    })
    
    -- Slider track
    slider.Track = Create("Frame", {
        Name = "Track",
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = Color3.fromRGB(230, 230, 235),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = slider.Frame
    })
    CreateCorner(slider.Track, UDim.new(0, 4))
    
    -- Slider fill
    slider.Fill = Create("Frame", {
        Name = "Fill",
        Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(100, 150, 255),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = slider.Track
    })
    CreateCorner(slider.Fill, UDim.new(0, 4))
    
    -- Slider handle
    slider.Handle = Create("TextButton", {
        Name = "Handle",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -9, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.1,
        Text = "",
        Parent = slider.Track
    })
    CreateCorner(slider.Handle, UDim.new(0, 9))
    CreateStroke(slider.Handle, Color3.fromRGB(100, 150, 255), 2, 0)
    
    -- Dragging logic
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
        slider.Handle.Position = UDim2.new(percent, -9, 0.5, -9)
        slider.ValueLabel.Text = slider.Value .. slider.Suffix
        
        slider.Callback(slider.Value)
    end
    
    return slider
end

-- Color Picker Component
function LiquidGlassUI.Window:CreateColorPicker(tab, config)
    local colorpicker = {
        Name = config.Name or "ColorPicker",
        Value = config.Default or Color3.fromRGB(255, 255, 255),
        Callback = config.Callback or function() end,
        Open = false
    }
    
    colorpicker.Frame = Create("Frame", {
        Name = colorpicker.Name,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    -- Label
    colorpicker.Label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 1,
        Text = colorpicker.Name,
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = colorpicker.Frame
    })
    
    -- Color preview button
    colorpicker.Button = Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(0, 60, 0, 24),
        Position = UDim2.new(1, -65, 0.5, -12),
        BackgroundColor3 = colorpicker.Value,
        BackgroundTransparency = 0,
        Text = "",
        Parent = colorpicker.Frame
    })
    CreateCorner(colorpicker.Button, UDim.new(0, 6))
    CreateStroke(colorpicker.Button, Color3.fromRGB(200, 200, 200), 1, 0.5)
    
    -- Picker container
    colorpicker.Picker = Create("Frame", {
        Name = "Picker",
        Size = UDim2.new(0, 200, 0, 0),
        Position = UDim2.new(1, -205, 1, 4),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = colorpicker.Frame
    })
    CreateCorner(colorpicker.Picker, UDim.new(0, 12))
    CreateStroke(colorpicker.Picker, Color3.fromRGB(200, 200, 200), 1, 0.5)
    
    -- Saturation/Value area
    colorpicker.SatVal = Create("TextButton", {
        Name = "SatVal",
        Size = UDim2.new(0, 180, 0, 150),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BackgroundTransparency = 0,
        Text = "",
        Parent = colorpicker.Picker
    })
    CreateCorner(colorpicker.SatVal, UDim.new(0, 8))
    
    -- Saturation gradient (white to transparent)
    local satGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Rotation = 0,
        Parent = colorpicker.SatVal
    })
    
    -- Value gradient (transparent to black)
    local valGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation = 90,
        Parent = colorpicker.SatVal
    })
    
    -- SatVal indicator
    colorpicker.SatValIndicator = Create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(1, -5, 0, -5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Parent = colorpicker.SatVal
    })
    CreateCorner(colorpicker.SatValIndicator, UDim.new(0, 5))
    CreateStroke(colorpicker.SatValIndicator, Color3.fromRGB(0, 0, 0), 1, 0.5)
    
    -- Hue slider
    colorpicker.Hue = Create("TextButton", {
        Name = "Hue",
        Size = UDim2.new(0, 180, 0, 20),
        Position = UDim2.new(0, 10, 0, 170),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        Text = "",
        Parent = colorpicker.Picker
    })
    CreateCorner(colorpicker.Hue, UDim.new(0, 10))
    
    -- Hue gradient
    local hueGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }),
        Parent = colorpicker.Hue
    })
    
    -- Hue indicator
    colorpicker.HueIndicator = Create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 10, 0, 24),
        Position = UDim2.new(0, -5, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Parent = colorpicker.Hue
    })
    CreateCorner(colorpicker.HueIndicator, UDim.new(0, 5))
    CreateStroke(colorpicker.HueIndicator, Color3.fromRGB(100, 100, 100), 1, 0.3)
    
    -- RGB inputs
    colorpicker.RGBContainer = Create("Frame", {
        Name = "RGB",
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 200),
        BackgroundTransparency = 1,
        Parent = colorpicker.Picker
    })
    
    local rgbLabels = {"R", "G", "B"}
    colorpicker.RGBInputs = {}
    
    for i, label in ipairs(rgbLabels) do
        local input = Create("TextBox", {
            Name = label,
            Size = UDim2.new(0, 56, 0, 24),
            Position = UDim2.new(0, (i - 1) * 62, 0, 0),
            BackgroundColor3 = Color3.fromRGB(250, 250, 252),
            BackgroundTransparency = 0.1,
            Text = "255",
            TextColor3 = Color3.fromRGB(60, 60, 65),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            PlaceholderText = label,
            Parent = colorpicker.RGBContainer
        })
        CreateCorner(input, UDim.new(0, 6))
        CreateStroke(input, Color3.fromRGB(200, 200, 200), 1, 0.5)
        
        input.FocusLost:Connect(function()
            local value = tonumber(input.Text) or 0
            value = math.clamp(math.floor(value), 0, 255)
            input.Text = value
            
            local r = tonumber(colorpicker.RGBInputs.R.Text) or 255
            local g = tonumber(colorpicker.RGBInputs.G.Text) or 255
            local b = tonumber(colorpicker.RGBInputs.B.Text) or 255
            colorpicker:SetValue(Color3.fromRGB(r, g, b))
        end)
        
        colorpicker.RGBInputs[label] = input
    end
    
    -- State
    local h, s, v = RGBtoHSV(colorpicker.Value)
    
    -- Update functions
    local function updateColor()
        local color = HSVtoRGB(h, s, v)
        colorpicker.Button.BackgroundColor3 = color
        colorpicker.SatVal.BackgroundColor3 = HSVtoRGB(h, 1, 1)
        
        colorpicker.RGBInputs.R.Text = math.floor(color.R * 255)
        colorpicker.RGBInputs.G.Text = math.floor(color.G * 255)
        colorpicker.RGBInputs.B.Text = math.floor(color.B * 255)
        
        colorpicker.Value = color
        colorpicker.Callback(color)
    end
    
    -- SatVal dragging
    local satValDragging = false
    
    colorpicker.SatVal.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            satValDragging = true
            local pos = (input.Position - colorpicker.SatVal.AbsolutePosition) / colorpicker.SatVal.AbsoluteSize
            s = math.clamp(pos.X, 0, 1)
            v = 1 - math.clamp(pos.Y, 0, 1)
            colorpicker.SatValIndicator.Position = UDim2.new(s, -5, 1 - v, -5)
            updateColor()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if satValDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = (input.Position - colorpicker.SatVal.AbsolutePosition) / colorpicker.SatVal.AbsoluteSize
            s = math.clamp(pos.X, 0, 1)
            v = 1 - math.clamp(pos.Y, 0, 1)
            colorpicker.SatValIndicator.Position = UDim2.new(s, -5, 1 - v, -5)
            updateColor()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            satValDragging = false
        end
    end)
    
    -- Hue dragging
    local hueDragging = false
    
    colorpicker.Hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            local pos = (input.Position - colorpicker.Hue.AbsolutePosition) / colorpicker.Hue.AbsoluteSize
            h = math.clamp(pos.X, 0, 1)
            colorpicker.HueIndicator.Position = UDim2.new(h, -5, 0.5, -12)
            updateColor()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = (input.Position - colorpicker.Hue.AbsolutePosition) / colorpicker.Hue.AbsoluteSize
            h = math.clamp(pos.X, 0, 1)
            colorpicker.HueIndicator.Position = UDim2.new(h, -5, 0.5, -12)
            updateColor()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)
    
    -- Toggle picker
    colorpicker.Button.MouseButton1Click:Connect(function()
        colorpicker:TogglePicker(not colorpicker.Open)
    end)
    
    function colorpicker:TogglePicker(open)
        colorpicker.Open = open
        
        if open then
            colorpicker.Picker.Visible = true
            Tween(colorpicker.Picker, {Size = UDim2.new(0, 200, 0, 235)}, 0.2)
        else
            Tween(colorpicker.Picker, {Size = UDim2.new(0, 200, 0, 0)}, 0.2)
            task.wait(0.2)
            colorpicker.Picker.Visible = false
        end
    end
    
    function colorpicker:SetValue(color)
        colorpicker.Value = color
        colorpicker.Button.BackgroundColor3 = color
        h, s, v = RGBtoHSV(color)
        
        colorpicker.SatValIndicator.Position = UDim2.new(s, -5, 1 - v, -5)
        colorpicker.HueIndicator.Position = UDim2.new(h, -5, 0.5, -12)
        colorpicker.SatVal.BackgroundColor3 = HSVtoRGB(h, 1, 1)
        
        colorpicker.RGBInputs.R.Text = math.floor(color.R * 255)
        colorpicker.RGBInputs.G.Text = math.floor(color.G * 255)
        colorpicker.RGBInputs.B.Text = math.floor(color.B * 255)
        
        colorpicker.Callback(color)
    end
    
    -- Initialize
    colorpicker:SetValue(colorpicker.Value)
    
    return colorpicker
end

-- Keybinder Component
function LiquidGlassUI.Window:CreateKeybinder(tab, config)
    local keybinder = {
        Name = config.Name or "Keybinder",
        Value = config.Default or Enum.KeyCode.Unknown,
        Callback = config.Callback or function() end,
        Listening = false
    }
    
    keybinder.Frame = Create("Frame", {
        Name = keybinder.Name,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    -- Label
    keybinder.Label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 1,
        Text = keybinder.Name,
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybinder.Frame
    })
    
    -- Key button
    keybinder.Button = Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(0, 100, 0, 28),
        Position = UDim2.new(1, -105, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.15,
        Text = keybinder.Value.Name or "None",
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        Parent = keybinder.Frame
    })
    CreateCorner(keybinder.Button, UDim.new(0, 8))
    CreateStroke(keybinder.Button, Color3.fromRGB(200, 200, 200), 1, 0.5)
    
    -- Click to bind
    keybinder.Button.MouseButton1Click:Connect(function()
        keybinder:StartListening()
    end)
    
    -- Input handler
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
        keybinder.Button.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        keybinder.Button.BackgroundTransparency = 0.3
    end
    
    function keybinder:StopListening()
        keybinder.Listening = false
        keybinder.Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        keybinder.Button.BackgroundTransparency = 0.15
    end
    
    function keybinder:SetValue(keycode)
        keybinder.Value = keycode
        keybinder.Button.Text = keycode.Name or "None"
    end
    
    return keybinder
end

-- Button Component
function LiquidGlassUI.Window:CreateButton(tab, config)
    local button = {
        Name = config.Name or "Button",
        Callback = config.Callback or function() end
    }
    
    button.Frame = Create("TextButton", {
        Name = button.Name,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(100, 150, 255),
        BackgroundTransparency = 0.2,
        Text = button.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        Parent = tab.Content
    })
    CreateCorner(button.Frame, UDim.new(0, 10))
    
    button.Frame.MouseButton1Click:Connect(function()
        button.Callback()
    end)
    
    button.Frame.MouseEnter:Connect(function()
        Tween(button.Frame, {BackgroundTransparency = 0.1}, 0.15)
    end)
    
    button.Frame.MouseLeave:Connect(function()
        Tween(button.Frame, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    return button
end

-- TextBox Component
function LiquidGlassUI.Window:CreateTextBox(tab, config)
    local textbox = {
        Name = config.Name or "TextBox",
        Value = config.Default or "",
        Placeholder = config.Placeholder or "Enter text...",
        Callback = config.Callback or function() end
    }
    
    textbox.Frame = Create("Frame", {
        Name = textbox.Name,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    -- Label
    textbox.Label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 80, 1, 0),
        BackgroundTransparency = 1,
        Text = textbox.Name,
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textbox.Frame
    })
    
    -- Input box
    textbox.Input = Create("TextBox", {
        Name = "Input",
        Size = UDim2.new(0, 200, 0, 28),
        Position = UDim2.new(1, -205, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.15,
        Text = textbox.Value,
        TextColor3 = Color3.fromRGB(60, 60, 65),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        PlaceholderText = textbox.Placeholder,
        Parent = textbox.Frame
    })
    CreateCorner(textbox.Input, UDim.new(0, 8))
    CreateStroke(textbox.Input, Color3.fromRGB(200, 200, 200), 1, 0.5)
    
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

-- Destroy method
function LiquidGlassUI.Window:Destroy()
    self.ScreenGui:Destroy()
end

return LiquidGlassUI
