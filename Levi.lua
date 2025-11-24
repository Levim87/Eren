local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Icon library
local Icons = {
    Home = "rbxassetid://7733960981",
    Settings = "rbxassetid://7734053495", 
}

-- Helper functions
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    TweenService:Create(object, TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quart, easingDirection or Enum.EasingDirection.Out), properties):Play()
end

local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for key, value in pairs(properties) do
        if key ~= "Parent" then
            instance[key] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function AddCorner(object, radius)
    return CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = object
    })
end

local function AddStroke(object, color, thickness)
    return CreateInstance("UIStroke", {
        Color = color or Color3.fromRGB(80, 120, 200),
        Thickness = thickness or 1,
        Transparency = 0.5,
        Parent = object
    })
end

local function AddGlow(object, color, size)
    return CreateInstance("ImageLabel", {
        Size = UDim2.new(1, size or 25, 1, size or 25),
        Position = UDim2.new(0.5, -(size or 25)/2, 0.5, -(size or 25)/2),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = color or Color3.fromRGB(100, 150, 255),
        ImageTransparency = 0.8,
        ZIndex = object.ZIndex - 1,
        Parent = object
    })
end

-- Notification system
local Notifications = {}
local ActiveNotifications = {}

local function UpdateNotificationPositions()
    for index, notification in ipairs(ActiveNotifications) do
        if notification and notification.Parent then
            CreateTween(notification, {
                Position = UDim2.new(1, -320, 1, -20 - (index * 80))
            }, 0.3, Enum.EasingStyle.Back)
        end
    end
end

local MirageUI = {}

function MirageUI:Notify(title, content, duration, iconType)
    local notificationScreen = CoreGui:FindFirstChild("MirageNotify") or CreateInstance("ScreenGui", {
        Name = "MirageNotify",
        ResetOnSpawn = false,
        Parent = CoreGui
    })

    local notificationFrame = CreateInstance("Frame", {
        Size = UDim2.new(0, 300, 0, 70),
        Position = UDim2.new(1, 320, 1, -100),
        BackgroundColor3 = Color3.fromRGB(15, 18, 25),
        Parent = notificationScreen
    })

    AddCorner(notificationFrame, 10)
    local notificationStroke = AddStroke(notificationFrame, Color3.fromRGB(100, 150, 255), 1.5)
    local notificationGlow = AddGlow(notificationFrame, Color3.fromRGB(80, 120, 200), 35)
    notificationGlow.ImageTransparency = 1

    table.insert(ActiveNotifications, notificationFrame)
    UpdateNotificationPositions()

    local icon = CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Image = Icons[iconType] or Icons.Home,
        ImageColor3 = Color3.fromRGB(100, 150, 255),
        Parent = notificationFrame
    })

    CreateInstance("TextLabel", {
        Size = UDim2.new(1, -50, 0, 20),
        Position = UDim2.new(0, 45, 0, 10),
        BackgroundTransparency = 1,
        Text = title or "Notification",
        TextColor3 = Color3.fromRGB(240, 245, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notificationFrame
    })

    CreateInstance("TextLabel", {
        Size = UDim2.new(1, -50, 0, 16),
        Position = UDim2.new(0, 45, 0, 32),
        BackgroundTransparency = 1,
        Text = content or "",
        TextColor3 = Color3.fromRGB(140, 150, 180),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = notificationFrame
    })

    local progressBackground = CreateInstance("Frame", {
        Size = UDim2.new(1, -20, 0, 3),
        Position = UDim2.new(0, 10, 1, -10),
        BackgroundColor3 = Color3.fromRGB(35, 40, 50),
        Parent = notificationFrame
    })
    AddCorner(progressBackground, 2)

    local progressFill = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(100, 150, 255),
        Parent = progressBackground
    })
    AddCorner(progressFill, 2)

    local progressGradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 100, 255))
        }),
        Parent = progressFill
    })

    CreateTween(notificationGlow, {ImageTransparency = 0.7}, 0.4)
    CreateTween(icon, {Rotation = 360}, 0.5, Enum.EasingStyle.Back)

    task.spawn(function()
        local displayTime = duration or 3
        for progress = 100, 0, -1 do
            progressFill.Size = UDim2.new(progress / 100, 0, 1, 0)
            progressGradient.Rotation = (100 - progress) * 3.6
            task.wait(displayTime / 100)
        end

        CreateTween(notificationFrame, {
            Position = UDim2.new(1, 320, notificationFrame.Position.Y.Scale, notificationFrame.Position.Y.Offset),
            BackgroundTransparency = 1
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)

        CreateTween(notificationStroke, {Transparency = 1}, 0.3)
        CreateTween(notificationGlow, {ImageTransparency = 1}, 0.3)

        task.wait(0.4)
        for index, notification in ipairs(ActiveNotifications) do
            if notification == notificationFrame then
                table.remove(ActiveNotifications, index)
                break
            end
        end
        notificationFrame:Destroy()
        UpdateNotificationPositions()
    end)

    return notificationFrame
end

function MirageUI:Window(title)
    local WindowAPI = {}
    local ScreenGui = CreateInstance("ScreenGui", {
        Name = "MirageUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })

    -- Toggle button
    local ToggleButton = CreateInstance("ImageButton", {
        Size = UDim2.new(0, 45, 0, 45),
        Position = UDim2.new(0, 20, 0.5, -22),
        BackgroundColor3 = Color3.fromRGB(15, 18, 25),
        Parent = ScreenGui
    })
    AddCorner(ToggleButton, 10)
    local ToggleStroke = AddStroke(ToggleButton, Color3.fromRGB(100, 150, 255), 1.5)
    local ToggleGlow = AddGlow(ToggleButton, Color3.fromRGB(100, 150, 255), 30)

    local ToggleIcon = CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0.5, -10, 0.5, -10),
        BackgroundTransparency = 1,
        Image = Icons.Home,
        ImageColor3 = Color3.fromRGB(100, 150, 255),
        Parent = ToggleButton
    })

    -- Rotate icon continuously
    task.spawn(function()
        while task.wait(0.03) do
            if ToggleIcon and ToggleIcon.Parent then
                ToggleIcon.Rotation = ToggleIcon.Rotation + 1
            end
        end
    end)

    -- Pulsing glow effect
    task.spawn(function()
        while task.wait(0.05) do
            if ToggleGlow and ToggleGlow.Parent then
                ToggleGlow.ImageTransparency = 0.7 + math.sin(tick() * 3) * 0.1
            end
        end
    end)

    -- Main window
    local MainFrame = CreateInstance("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(12, 14, 20),
        Visible = false,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 12)
    local MainStroke = AddStroke(MainFrame, Color3.fromRGB(80, 120, 200), 1.5)
    local MainGlow = AddGlow(MainFrame, Color3.fromRGB(60, 100, 180), 50)
    MainGlow.ImageTransparency = 1

    -- Header
    local Header = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(8, 10, 15),
        Parent = MainFrame
    })
    AddCorner(Header, 12)
    CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -15),
        BackgroundColor3 = Color3.fromRGB(8, 10, 15),
        Parent = Header
    })

    local HeaderLine = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(100, 150, 255),
        Parent = Header
    })
    local HeaderGradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))
        }),
        Parent = HeaderLine
    })

    -- Animated gradient
    task.spawn(function()
        while task.wait(0.02) do
            if HeaderGradient then
                HeaderGradient.Offset = Vector2.new((HeaderGradient.Offset.X + 0.01) % 2 - 1, 0)
            end
        end
    end)

    -- Logo
    local Logo = CreateInstance("Frame", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 10, 0, 9),
        BackgroundColor3 = Color3.fromRGB(100, 150, 255),
        Parent = Header
    })
    AddCorner(Logo, 8)
    local LogoGradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 100, 255))
        }),
        Rotation = 45,
        Parent = Logo
    })

    task.spawn(function()
        while task.wait(0.03) do
            if LogoGradient then
                LogoGradient.Rotation = LogoGradient.Rotation + 1
            end
        end
    end)

    CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0.5, -9, 0.5, -9),
        BackgroundTransparency = 1,
        Image = Icons.Home,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Logo
    })

    CreateInstance("TextLabel", {
        Size = UDim2.new(0, 180, 0, 18),
        Position = UDim2.new(0, 52, 0, 8),
        BackgroundTransparency = 1,
        Text = title or "Mirage UI",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })

    CreateInstance("TextLabel", {
        Size = UDim2.new(0, 180, 0, 12),
        Position = UDim2.new(0, 52, 0, 28),
        BackgroundTransparency = 1,
        Text = "Leviiiiiiiii",
        TextColor3 = Color3.fromRGB(100, 120, 160),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })

    -- Search box
    local SearchBox = CreateInstance("Frame", {
        Size = UDim2.new(0, 160, 0, 28),
        Position = UDim2.new(1, -170, 0, 11),
        BackgroundColor3 = Color3.fromRGB(15, 15, 22),
        Parent = Header
    })
    AddCorner(SearchBox, 8)
    local SearchStroke = AddStroke(SearchBox, Color3.fromRGB(60, 80, 120))

    CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 8, 0.5, -7),
        BackgroundTransparency = 1,
        Image = Icons.Home,
        ImageColor3 = Color3.fromRGB(100, 120, 160),
        Parent = SearchBox
    })

    local SearchTextBox = CreateInstance("TextBox", {
        Size = UDim2.new(1, -35, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search...",
        TextColor3 = Color3.fromRGB(220, 220, 255),
        PlaceholderColor3 = Color3.fromRGB(80, 90, 120),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = SearchBox
    })

    -- Close button
    local CloseButton = CreateInstance("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -38, 0, 11),
        BackgroundColor3 = Color3.fromRGB(20, 24, 32),
        Text = "",
        Parent = Header
    })
    AddCorner(CloseButton, 8)
    local CloseStroke = AddStroke(CloseButton, Color3.fromRGB(50, 60, 80))

    local CloseIcon = CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundTransparency = 1,
        Image = Icons.Home,
        ImageColor3 = Color3.fromRGB(200, 100, 100),
        Parent = CloseButton
    })

    -- Close button interactions
    CloseButton.MouseEnter:Connect(function()
        CreateTween(CloseButton, {BackgroundColor3 = Color3.fromRGB(60, 30, 30), Size = UDim2.new(0, 30, 0, 30)}, 0.2, Enum.EasingStyle.Back)
        CreateTween(CloseStroke, {Color = Color3.fromRGB(255, 100, 100)}, 0.2)
        CreateTween(CloseIcon, {Rotation = 90}, 0.3)
    end)

    CloseButton.MouseLeave:Connect(function()
        CreateTween(CloseButton, {BackgroundColor3 = Color3.fromRGB(20, 24, 32), Size = UDim2.new(0, 28, 0, 28)}, 0.2)
        CreateTween(CloseStroke, {Color = Color3.fromRGB(50, 60, 80)}, 0.2)
        CreateTween(CloseIcon, {Rotation = 0}, 0.3)
    end)

    -- Tabs container
    local TabsContainer = CreateInstance("Frame", {
        Size = UDim2.new(0, 130, 1, -60),
        Position = UDim2.new(0, 8, 0, 55),
        BackgroundColor3 = Color3.fromRGB(15, 18, 25),
        Parent = MainFrame
    })
    AddCorner(TabsContainer, 10)
    CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabsContainer
    })
    CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        Parent = TabsContainer
    })

    -- Content container
    local ContentContainer = CreateInstance("ScrollingFrame", {
        Size = UDim2.new(1, -150, 1, -60),
        Position = UDim2.new(0, 145, 0, 55),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(80, 120, 200),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = MainFrame
    })
    local ContentLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ContentContainer
    })
    CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 8),
        Parent = ContentContainer
    })

    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Window state
    local IsOpen = false
    local CurrentTab = nil
    local TabData = {}
    local AllElements = {}

    -- Animation functions
    local function OpenWindow()
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        CreateTween(MainFrame, {Size = UDim2.new(0, 580, 0, 420)}, 0.5, Enum.EasingStyle.Back)
        CreateTween(MainStroke, {Transparency = 0.3}, 0.4)
        CreateTween(MainGlow, {ImageTransparency = 0.75}, 0.5)
        CreateTween(ToggleButton, {Rotation = 180}, 0.5, Enum.EasingStyle.Back)
        CreateTween(ToggleStroke, {Thickness = 3, Transparency = 0}, 0.3)
        self:Notify("Mirage UI", "Window opened!", 2, "Check")
    end

    local function CloseWindow()
        CreateTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        CreateTween(MainStroke, {Transparency = 1}, 0.3)
        CreateTween(MainGlow, {ImageTransparency = 1}, 0.3)
        CreateTween(ToggleButton, {Rotation = 0}, 0.5, Enum.EasingStyle.Back)
        CreateTween(ToggleStroke, {Thickness = 1.5, Transparency = 0.5}, 0.3)
        task.delay(0.4, function()
            MainFrame.Visible = false
        end)
    end

    -- Toggle button click
    ToggleButton.MouseButton1Click:Connect(function()
        IsOpen = not IsOpen
        if IsOpen then
            OpenWindow()
        else
            CloseWindow()
        end
    end)

    -- Close button click
    CloseButton.MouseButton1Click:Connect(function()
        IsOpen = false
        CloseWindow()
    end)

    -- Toggle button hover effects
    ToggleButton.MouseEnter:Connect(function()
        CreateTween(ToggleButton, {Size = UDim2.new(0, 48, 0, 48)}, 0.3, Enum.EasingStyle.Back)
        CreateTween(ToggleStroke, {Transparency = 0.2}, 0.2)
        CreateTween(ToggleGlow, {ImageTransparency = 0.5, Size = UDim2.new(1, 40, 1, 40)}, 0.3)
    end)

    ToggleButton.MouseLeave:Connect(function()
        CreateTween(ToggleButton, {Size = UDim2.new(0, 45, 0, 45)}, 0.3, Enum.EasingStyle.Back)
        CreateTween(ToggleStroke, {Transparency = IsOpen and 0 or 0.5}, 0.2)
        CreateTween(ToggleGlow, {ImageTransparency = 0.7, Size = UDim2.new(1, 30, 1, 30)}, 0.3)
    end)

    -- Dragging functionality
    local Dragging = false
    local DragInput, DragStart, StartPosition

    local function UpdateDrag(input)
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(
            StartPosition.X.Scale, 
            StartPosition.X.Offset + delta.X,
            StartPosition.Y.Scale, 
            StartPosition.Y.Offset + delta.Y
        )
        MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdateDrag(input)
        end
    end)

    -- Search functionality
    SearchTextBox.Focused:Connect(function()
        CreateTween(SearchStroke, {Color = Color3.fromRGB(100, 150, 255), Transparency = 0.2}, 0.2)
        CreateTween(SearchBox, {BackgroundColor3 = Color3.fromRGB(25, 30, 40)}, 0.2)
    end)

    SearchTextBox.FocusLost:Connect(function()
        CreateTween(SearchStroke, {Color = Color3.fromRGB(60, 80, 120), Transparency = 0.5}, 0.2)
        CreateTween(SearchBox, {BackgroundColor3 = Color3.fromRGB(15, 15, 22)}, 0.2)
    end)

    SearchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchTextBox.Text:lower()
        for _, element in pairs(AllElements) do
            if query == "" then
                element.frame.Visible = (element.tab == CurrentTab)
            else
                local match = element.name:lower():find(query, 1, true)
                element.frame.Visible = match ~= nil
            end
        end
    end)

    -- Tab creation
    function WindowAPI:Tab(name, icon)
        local TabAPI = {}

        local TabButton = CreateInstance("TextButton", {
            Size = UDim2.new(1, -10, 0, 36),
            BackgroundColor3 = Color3.fromRGB(20, 24, 32),
            Text = "",
            AutoButtonColor = false,
            Parent = TabsContainer
        })
        AddCorner(TabButton, 8)
        local TabStroke = AddStroke(TabButton, Color3.fromRGB(40, 50, 70))

        local TabIcon = CreateInstance("ImageLabel", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 10, 0.5, -8),
            BackgroundTransparency = 1,
            Image = Icons[icon] or Icons.Home,
            ImageColor3 = Color3.fromRGB(140, 160, 200),
            Parent = TabButton
        })

        local TabName = CreateInstance("TextLabel", {
            Size = UDim2.new(1, -38, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
            Text = name or "Tab",
            TextColor3 = Color3.fromRGB(180, 190, 220),
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })

        local TabIndicator = CreateInstance("Frame", {
            Size = UDim2.new(0, 2, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(100, 150, 255),
            Parent = TabButton
        })
        AddCorner(TabIndicator, 2)

        local TabContent = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = ContentContainer
        })
        CreateInstance("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })

        TabData[name] = {
            button = TabButton,
            content = TabContent,
            stroke = TabStroke,
            label = TabName,
            icon = TabIcon,
            indicator = TabIndicator
        }

        local function SelectTab()
            TabButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            TabStroke.Color = Color3.fromRGB(100, 150, 255)
            TabStroke.Transparency = 0.3
            TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            CreateTween(TabIndicator, {Size = UDim2.new(0, 2, 0.7, 0)}, 0.3, Enum.EasingStyle.Back)
            CreateTween(TabIcon, {Rotation = 360}, 0.4)
            task.delay(0.4, function()
                TabIcon.Rotation = 0
            end)
        end

        local function DeselectTab()
            CreateTween(TabButton, {BackgroundColor3 = Color3.fromRGB(20, 24, 32)}, 0.2)
            CreateTween(TabStroke, {Color = Color3.fromRGB(40, 50, 70), Transparency = 0.5}, 0.2)
            CreateTween(TabName, {TextColor3 = Color3.fromRGB(180, 190, 220)}, 0.2)
            CreateTween(TabIcon, {ImageColor3 = Color3.fromRGB(140, 160, 200)}, 0.2)
            CreateTween(TabIndicator, {Size = UDim2.new(0, 2, 0, 0)}, 0.2)
        end

        if not CurrentTab then
            CurrentTab = name
            TabContent.Visible = true
            SelectTab()
        end

        TabButton.MouseButton1Click:Connect(function()
            if CurrentTab ~= name then
                if CurrentTab and TabData[CurrentTab] then
                    TabData[CurrentTab].content.Visible = false
                    for tabName, tabInfo in pairs(TabData) do
                        if tabName == CurrentTab then
                            CreateTween(tabInfo.button, {BackgroundColor3 = Color3.fromRGB(20, 24, 32)}, 0.2)
                            CreateTween(tabInfo.stroke, {Color = Color3.fromRGB(40, 50, 70), Transparency = 0.5}, 0.2)
                            CreateTween(tabInfo.label, {TextColor3 = Color3.fromRGB(180, 190, 220)}, 0.2)
                            CreateTween(tabInfo.icon, {ImageColor3 = Color3.fromRGB(140, 160, 200)}, 0.2)
                            CreateTween(tabInfo.indicator, {Size = UDim2.new(0, 2, 0, 0)}, 0.2)
                        end
                    end
                end
                CurrentTab = name
                TabContent.Visible = true
                SelectTab()
                ContentContainer.CanvasPosition = Vector2.new(0, 0)
                SearchTextBox.Text = ""

                for _, element in pairs(AllElements) do
                    element.frame.Visible = (element.tab == name)
                end
            end
        end)

        TabButton.MouseEnter:Connect(function()
            if CurrentTab ~= name then
                CreateTween(TabButton, {BackgroundColor3 = Color3.fromRGB(30, 36, 48)}, 0.2)
                CreateTween(TabStroke, {Color = Color3.fromRGB(60, 80, 120)}, 0.2)
                CreateTween(TabIndicator, {Size = UDim2.new(0, 2, 0.3, 0)}, 0.2)
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if CurrentTab ~= name then
                CreateTween(TabButton, {BackgroundColor3 = Color3.fromRGB(20, 24, 32)}, 0.2)
                CreateTween(TabStroke, {Color = Color3.fromRGB(40, 50, 70)}, 0.2)
                CreateTween(TabIndicator, {Size = UDim2.new(0, 2, 0, 0)}, 0.2)
            end
        end)

        -- Button element
        function TabAPI:Button(text, buttonIcon, callback)
            local Button = CreateInstance("TextButton", {
                Size = UDim2.new(1, -8, 0, 40),
                BackgroundColor3 = Color3.fromRGB(20, 24, 32),
                Text = "",
                AutoButtonColor = false,
                Parent = TabContent
            })
            AddCorner(Button, 8)
            local ButtonStroke = AddStroke(Button, Color3.fromRGB(50, 60, 80))
            local ButtonGlow = AddGlow(Button, Color3.fromRGB(80, 120, 200), 20)
            ButtonGlow.ImageTransparency = 1

            local ButtonIcon = CreateInstance("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 12, 0.5, -9),
                BackgroundTransparency = 1,
                Image = Icons[buttonIcon] or Icons.Home,
                ImageColor3 = Color3.fromRGB(100, 150, 255),
                Parent = Button
            })

            CreateInstance("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 38, 0, 0),
                BackgroundTransparency = 1,
                Text = text or "Button",
                TextColor3 = Color3.fromRGB(220, 230, 255),
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Button
            })

            local Arrow = CreateInstance("ImageLabel", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(1, -26, 0.5, -6),
                BackgroundTransparency = 1,
                Image = Icons.Home,
                ImageColor3 = Color3.fromRGB(80, 100, 140),
                Rotation = -90,
                Parent = Button
            })

            table.insert(AllElements, {frame = Button, name = text or "Button", tab = name})

            Button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
                CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(100, 150, 255)}, 0.1)
                CreateTween(ButtonIcon, {Rotation = 360}, 0.4)
                CreateTween(ButtonGlow, {ImageTransparency = 0.6}, 0.1)
                task.delay(0.1, function()
                    CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(20, 24, 32)}, 0.25)
                    CreateTween(ButtonGlow, {ImageTransparency = 1}, 0.25)
                end)
                task.delay(0.4, function()
                    ButtonIcon.Rotation = 0
                end)
            end)

            Button.MouseEnter:Connect(function()
                CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(30, 36, 48)}, 0.2)
                CreateTween(ButtonStroke, {Color = Color3.fromRGB(80, 120, 200), Transparency = 0.3}, 0.2)
                CreateTween(Arrow, {Position = UDim2.new(1, -22, 0.5, -6)}, 0.2)
                CreateTween(ButtonGlow, {ImageTransparency = 0.85}, 0.2)
            end)

            Button.MouseLeave:Connect(function()
                CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(20, 24, 32)}, 0.2)
                CreateTween(ButtonStroke, {Color = Color3.fromRGB(50, 60, 80), Transparency = 0.5}, 0.2)
                CreateTween(Arrow, {Position = UDim2.new(1, -26, 0.5, -6)}, 0.2)
                CreateTween(ButtonGlow, {ImageTransparency = 1}, 0.2)
            end)

            return Button
        end

        -- Toggle element
        function TabAPI:Toggle(text, toggleIcon, default, callback)
            local IsOn = default or false

            local Toggle = CreateInstance("Frame", {
                Size = UDim2.new(1, -8, 0, 40),
                BackgroundColor3 = Color3.fromRGB(20, 24, 32),
                Parent = TabContent
            })
            AddCorner(Toggle, 8)
            local ToggleStroke = AddStroke(Toggle, IsOn and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 60, 80))
            ToggleStroke.Transparency = IsOn and 0.3 or 0.5

            local ToggleGlow = AddGlow(Toggle, Color3.fromRGB(80, 120, 200), 20)
            ToggleGlow.ImageTransparency = IsOn and 0.8 or 1

            CreateInstance("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 12, 0.5, -9),
                BackgroundTransparency = 1,
                Image = Icons[toggleIcon] or Icons.Home,
                ImageColor3 = Color3.fromRGB(100, 150, 255),
                Parent = Toggle
            })

            CreateInstance("TextLabel", {
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 38, 0, 0),
                BackgroundTransparency = 1,
                Text = text or "Toggle",
                TextColor3 = Color3.fromRGB(220, 230, 255),
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Toggle
            })

            local Switch = CreateInstance("Frame", {
                Size = UDim2.new(0, 48, 0, 24),
                Position = UDim2.new(1, -60, 0.5, -12),
                BackgroundColor3 = IsOn and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(35, 40, 50),
                Parent = Toggle
            })
            AddCorner(Switch, 12)

            local Knob = CreateInstance("Frame", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = IsOn and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = Switch
            })
            AddCorner(Knob, 10)
            local KnobGlow = AddGlow(Knob, Color3.fromRGB(255, 255, 255), 12)
            KnobGlow.ImageTransparency = IsOn and 0.6 or 1

            local Check = CreateInstance("ImageLabel", {
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(0.5, -5, 0.5, -5),
                BackgroundTransparency = 1,
                Image = Icons.Home,
                ImageColor3 = IsOn and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(60, 70, 90),
                ImageTransparency = IsOn and 0 or 1,
                Parent = Knob
            })

            local ToggleButton = CreateInstance("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Toggle
            })

            table.insert(AllElements, {frame = Toggle, name = text or "Toggle", tab = name})

            ToggleButton.MouseButton1Click:Connect(function()
                IsOn = not IsOn

                CreateTween(Switch, {
                    BackgroundColor3 = IsOn and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(35, 40, 50)
                }, 0.25, Enum.EasingStyle.Quart)

                CreateTween(Knob, {
                    Position = IsOn and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                }, 0.25, Enum.EasingStyle.Back)

                CreateTween(KnobGlow, {
                    ImageTransparency = IsOn and 0.6 or 1
                }, 0.25)

                CreateTween(Check, {
                    ImageColor3 = IsOn and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(60, 70, 90),
                    ImageTransparency = IsOn and 0 or 1
                }, 0.2)

                CreateTween(ToggleStroke, {
                    Color = IsOn and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 60, 80),
                    Transparency = IsOn and 0.3 or 0.5
                }, 0.2)

                CreateTween(ToggleGlow, {
                    ImageTransparency = IsOn and 0.8 or 1
                }, 0.25)

                if callback then
                    callback(IsOn)
                end
            end)

            ToggleButton.MouseEnter:Connect(function()
                CreateTween(Toggle, {BackgroundColor3 = Color3.fromRGB(25, 30, 40)}, 0.2)
            end)

            ToggleButton.MouseLeave:Connect(function()
                CreateTween(Toggle, {BackgroundColor3 = Color3.fromRGB(20, 24, 32)}, 0.2)
            end)

            return {
                Set = function(value)
                    IsOn = value
                    CreateTween(Switch, {
                        BackgroundColor3 = IsOn and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(35, 40, 50)
                    }, 0.2)
                    CreateTween(Knob, {
                        Position = IsOn and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                    }, 0.2)
                    CreateTween(Check, {
                        ImageTransparency = IsOn and 0 or 1
                    }, 0.2)
                end,
                Get = function()
                    return IsOn
                end
            }
        end

        function TabAPI:Slider(text, sliderIcon, min, max, default, callback)
    local Value = default or min

    local Slider = CreateInstance("Frame", {
        Size = UDim2.new(1, -8, 0, 45),
        BackgroundColor3 = Color3.fromRGB(15, 18, 25),
        Parent = TabContent
    })
    AddCorner(Slider, 10)
    local SliderStroke = AddStroke(Slider, Color3.fromRGB(40, 50, 70))

    CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundTransparency = 1,
        Image = Icons[sliderIcon] or Icons.Slider,
        ImageColor3 = Color3.fromRGB(100, 150, 255),
        Parent = Slider
    })

    -- Title
    CreateInstance("TextLabel", {
        Size = UDim2.new(0, 100, 0, 16),
        Position = UDim2.new(0, 32, 0.5, -8),
        BackgroundTransparency = 1,
        Text = text or "Slider",
        TextColor3 = Color3.fromRGB(240, 245, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Slider
    })

    local SliderBar = CreateInstance("Frame", {
        Size = UDim2.new(0, 120, 0, 5),
        Position = UDim2.new(1, -180, 0.5, -2.5),
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Parent = Slider
    })
    AddCorner(SliderBar, 2.5)
    AddStroke(SliderBar, Color3.fromRGB(50, 60, 80))

    -- Filled portion
    local SliderFill = CreateInstance("Frame", {
        Size = UDim2.new((Value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(100, 150, 255),
        Parent = SliderBar
    })
    AddCorner(SliderFill, 2.5)

    local FillGradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 100, 255))
        }),
        Parent = SliderFill
    })

        local SliderHandle = CreateInstance("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((Value - min) / (max - min), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(100, 150, 255),
        Parent = SliderBar
    })
    AddCorner(SliderHandle, 7)

    local HandleGlow = AddGlow(SliderHandle, Color3.fromRGB(100, 150, 255), 15)
    HandleGlow.ImageTransparency = 0.7

    local HandleStroke = AddStroke(SliderHandle, Color3.fromRGB(255, 255, 255))
    HandleStroke.Thickness = 1.5
    HandleStroke.Transparency = 0.8

    local ValueLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 45, 0, 16),
        Position = UDim2.new(1, -50, 0.5, -8),
        BackgroundTransparency = 1,
        Text = tostring(Value),
        TextColor3 = Color3.fromRGB(100, 150, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Slider
    })

    table.insert(AllElements, {frame = Slider, name = text or "Slider", tab = name})

    local IsDragging = false

    local function UpdateSlider(input)
        local barX = SliderBar.AbsolutePosition.X
        local barWidth = SliderBar.AbsoluteSize.X
        local percentage = math.clamp((input.Position.X - barX) / barWidth, 0, 1)
        Value = math.floor(min + (max - min) * percentage)
        ValueLabel.Text = tostring(Value)

        CreateTween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
        CreateTween(SliderHandle, {Position = UDim2.new(percentage, 0, 0.5, 0)}, 0.1)

        if callback then
            callback(Value)
        end
    end

    local SliderButton = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 10,
        Parent = Slider
    })

    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsDragging = true
            UpdateSlider(input)
            CreateTween(SliderHandle, {Size = UDim2.new(0, 18, 0, 18)}, 0.15)
            CreateTween(HandleGlow, {ImageTransparency = 0.4}, 0.15)
            CreateTween(SliderStroke, {Color = Color3.fromRGB(100, 150, 255), Transparency = 0.3}, 0.15)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsDragging = false
            CreateTween(SliderHandle, {Size = UDim2.new(0, 14, 0, 14)}, 0.15)
            CreateTween(HandleGlow, {ImageTransparency = 0.7}, 0.15)
            CreateTween(SliderStroke, {Color = Color3.fromRGB(40, 50, 70), Transparency = 0.5}, 0.15)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)

    return {
        Set = function(value)
            Value = value
            ValueLabel.Text = tostring(value)
            local percentage = (value - min) / (max - min)
            CreateTween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.2)
            CreateTween(SliderHandle, {Position = UDim2.new(percentage, 0, 0.5, 0)}, 0.2)
        end,
        Get = function()
            return Value
        end
    }
end

        -- Dropdown element
        function TabAPI:Dropdown(text, dropdownIcon, options, default, callback)
            local Selected = default or options[1] or ""
            local IsExpanded = false

            local Dropdown = CreateInstance("Frame", {
                Size = UDim2.new(1, -8, 0, 40),
                BackgroundColor3 = Color3.fromRGB(20, 24, 32),
                ClipsDescendants = true,
                Parent = TabContent
            })
            AddCorner(Dropdown, 8)
            local DropdownStroke = AddStroke(Dropdown, Color3.fromRGB(50, 60, 80))

            CreateInstance("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 12, 0, 11),
                BackgroundTransparency = 1,
                Image = Icons[dropdownIcon] or Icons.Dropdown,
                ImageColor3 = Color3.fromRGB(100, 150, 255),
                Parent = Dropdown
            })

            CreateInstance("TextLabel", {
                Size = UDim2.new(1, -140, 0, 40),
                Position = UDim2.new(0, 38, 0, 0),
                BackgroundTransparency = 1,
                Text = text or "Dropdown",
                TextColor3 = Color3.fromRGB(220, 230, 255),
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Dropdown
            })

            local SelectedValue = CreateInstance("TextLabel", {
                Size = UDim2.new(0, 70, 0, 22),
                Position = UDim2.new(1, -80, 0, 9),
                BackgroundColor3 = Color3.fromRGB(30, 35, 45),
                Text = Selected,
                TextColor3 = Color3.fromRGB(150, 170, 220),
                TextSize = 10,
                Font = Enum.Font.Gotham,
                Parent = Dropdown
            })
            AddCorner(SelectedValue, 6)

            local Arrow = CreateInstance("ImageLabel", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(1, -26, 0, 14),
                BackgroundTransparency = 1,
                Image = Icons.Home
                ,
                ImageColor3 = Color3.fromRGB(100, 150, 255),
                Rotation = 90,
                Parent = Dropdown
            })

            local OptionsContainer = CreateInstance("Frame", {
                Size = UDim2.new(1, -10, 0, 0),
                Position = UDim2.new(0, 5, 0, 44),
                BackgroundTransparency = 1,
                Parent = Dropdown
            })
            CreateInstance("UIListLayout", {
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = OptionsContainer
            })

            table.insert(AllElements, {frame = Dropdown, name = text or "Dropdown", tab = name})

            for _, option in ipairs(options) do
                local OptionButton = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Color3.fromRGB(25, 30, 40),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = OptionsContainer
                })
                AddCorner(OptionButton, 6)

                local OptionIcon = CreateInstance("ImageLabel", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, 8, 0.5, -6),
                    BackgroundTransparency = 1,
                    Image = Icons.Home,
                    ImageColor3 = Color3.fromRGB(100, 150, 255),
                    ImageTransparency = Selected == option and 0 or 1,
                    Parent = OptionButton
                })

                CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 26, 0, 0),
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = Color3.fromRGB(180, 190, 220),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = OptionButton
                })

                OptionButton.MouseEnter:Connect(function()
                    CreateTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(60, 90, 150)}, 0.15)
                end)

                OptionButton.MouseLeave:Connect(function()
                    CreateTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(25, 30, 40)}, 0.15)
                end)

                OptionButton.MouseButton1Click:Connect(function()
                    for _, child in pairs(OptionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            local childIcon = child:FindFirstChild("ImageLabel")
                            if childIcon then
                                CreateTween(childIcon, {ImageTransparency = 1}, 0.15)
                            end
                        end
                    end

                    CreateTween(OptionIcon, {ImageTransparency = 0}, 0.15)
                    Selected = option
                    SelectedValue.Text = option
                    IsExpanded = false
                    CreateTween(Dropdown, {Size = UDim2.new(1, -8, 0, 40)}, 0.25, Enum.EasingStyle.Back)
                    CreateTween(Arrow, {Rotation = 90}, 0.2)
                    CreateTween(DropdownStroke, {Color = Color3.fromRGB(50, 60, 80)}, 0.2)
                    if callback then
                        callback(Selected)
                    end
                end)
            end

            local HeaderButton = CreateInstance("TextButton", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Dropdown
            })

            HeaderButton.MouseButton1Click:Connect(function()
                IsExpanded = not IsExpanded
                local targetHeight = IsExpanded and (44 + #options * 31) or 40
                CreateTween(Dropdown, {Size = UDim2.new(1, -8, 0, targetHeight)}, 0.3, Enum.EasingStyle.Back)
                CreateTween(Arrow, {Rotation = IsExpanded and 270 or 90}, 0.25)
                CreateTween(DropdownStroke, {Color = IsExpanded and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 60, 80)}, 0.2)
            end)

            return {
                Set = function(value)
                    Selected = value
                    SelectedValue.Text = value
                end,
                Get = function()
                    return Selected
                end
            }
        end

        -- MultiDropdown element
        function TabAPI:MultiDropdown(text, multiIcon, options, defaults, callback)
    local Selected = defaults or {}
    local IsExpanded = false

    local Dropdown = CreateInstance("Frame", {
        Size = UDim2.new(1, -8, 0, 40),
        BackgroundColor3 = Color3.fromRGB(20, 24, 32),
        ClipsDescendants = true,
        Parent = TabContent
    })
    AddCorner(Dropdown, 8)
    local DropdownStroke = AddStroke(Dropdown, Color3.fromRGB(50, 60, 80))

    CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 12, 0, 11),
        BackgroundTransparency = 1,
        Image = Icons[multiIcon] or Icons.Home,
        ImageColor3 = Color3.fromRGB(100, 150, 255),
        Parent = Dropdown
    })

    CreateInstance("TextLabel", {
        Size = UDim2.new(1, -140, 0, 40),
        Position = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        Text = text or "Multi Select",
        TextColor3 = Color3.fromRGB(220, 230, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Dropdown
    })

    local SelectedCount = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 70, 0, 22),
        Position = UDim2.new(1, -80, 0, 9),
        BackgroundColor3 = Color3.fromRGB(30, 35, 45),
        Text = #Selected .. " selected",
        TextColor3 = Color3.fromRGB(150, 170, 220),
        TextSize = 9,
        Font = Enum.Font.Gotham,
        Parent = Dropdown
    })
    AddCorner(SelectedCount, 6)

    local Arrow = CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -26, 0, 14),
        BackgroundTransparency = 1,
        Image = Icons.Home,
        ImageColor3 = Color3.fromRGB(100, 150, 255),
        Rotation = 90,
        Parent = Dropdown
    })

    local OptionsContainer = CreateInstance("Frame", {
        Size = UDim2.new(1, -10, 0, 0),
        Position = UDim2.new(0, 5, 0, 44),
        BackgroundTransparency = 1,
        Parent = Dropdown
    })
    CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = OptionsContainer
    })

    table.insert(AllElements, {frame = Dropdown, name = text or "MultiDropdown", tab = self.Name or "Unknown"})

    local function HasValue(tbl, value)
        for _, v in pairs(tbl) do
            if v == value then
                return true
            end
        end
        return false
    end

    local function RemoveValue(tbl, value)
        for i, v in pairs(tbl) do
            if v == value then
                table.remove(tbl, i)
                return
            end
        end
    end

    for _, option in ipairs(options) do
        local IsSelected = HasValue(Selected, option)

        local OptionButton = CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Color3.fromRGB(25, 30, 40),
            Text = "",
            AutoButtonColor = false,
            Parent = OptionsContainer
        })
        AddCorner(OptionButton, 6)

        local OptionBox = CreateInstance("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 6, 0.5, -8),
            BackgroundColor3 = IsSelected and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(40, 45, 55),
            Parent = OptionButton
        })
        AddCorner(OptionBox, 4)

        local OptionCheck = CreateInstance("ImageLabel", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0.5, -5, 0.5, -5),
            BackgroundTransparency = 1,
            Image = Icons.Home,
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = IsSelected and 0 or 1,
            Parent = OptionBox
        })

        CreateInstance("TextLabel", {
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 28, 0, 0),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = Color3.fromRGB(180, 190, 220),
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = OptionButton
        })

        OptionButton.MouseEnter:Connect(function()
            CreateTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(35, 42, 55)}, 0.15)
        end)

        OptionButton.MouseLeave:Connect(function()
            CreateTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(25, 30, 40)}, 0.15)
        end)

        OptionButton.MouseButton1Click:Connect(function()
            local CurrentlySelected = HasValue(Selected, option)
            if CurrentlySelected then
                RemoveValue(Selected, option)
            else
                table.insert(Selected, option)
            end

            local NowSelected = not CurrentlySelected
            CreateTween(OptionBox, {
                BackgroundColor3 = NowSelected and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(40, 45, 55)
            }, 0.2)
            CreateTween(OptionCheck, {
                ImageTransparency = NowSelected and 0 or 1
            }, 0.2)
            SelectedCount.Text = #Selected .. " selected"

            if callback then
                callback(Selected)
            end
        end)
    end

    local HeaderButton = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Dropdown
    })

    HeaderButton.MouseButton1Click:Connect(function()
        IsExpanded = not IsExpanded
        -- Calculate height: header(44) + options(28 each) + padding(3 * (options - 1))
        local targetHeight = IsExpanded and (44 + #options * 28 + (#options - 1) * 3) or 40
        CreateTween(Dropdown, {Size = UDim2.new(1, -8, 0, targetHeight)}, 0.3, Enum.EasingStyle.Back)
        CreateTween(Arrow, {Rotation = IsExpanded and 270 or 90}, 0.25)
        CreateTween(DropdownStroke, {Color = IsExpanded and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 60, 80)}, 0.2)
    end)

    return {
        Set = function(values)
            Selected = values
            SelectedCount.Text = #Selected .. " selected"
        end,
        Get = function()
            return Selected
        end
    }
end

        -- Input element
        function TabAPI:Input(text, inputIcon, placeholder, callback)
            local Input = CreateInstance("Frame", {
                Size = UDim2.new(1, -8, 0, 36),
                BackgroundColor3 = Color3.fromRGB(15, 15, 22),
                Parent = TabContent
            })
            AddCorner(Input, 8)
            local InputStroke = AddStroke(Input, Color3.fromRGB(60, 80, 120))

            CreateInstance("ImageLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 8, 0.5, -8),
                BackgroundTransparency = 1,
                Image = Icons[inputIcon] or Icons.Home,
                ImageColor3 = Color3.fromRGB(100, 150, 255),
                Parent = Input
            })

            local TextBox = CreateInstance("TextBox", {
                Size = UDim2.new(1, -36, 1, 0),
                Position = UDim2.new(0, 32, 0, 0),
                BackgroundColor3 = Color3.fromRGB(30, 35, 45),
                BackgroundTransparency = 1,
                Text = "",
                PlaceholderText = placeholder or text,
                TextColor3 = Color3.fromRGB(220, 220, 255),
                PlaceholderColor3 = Color3.fromRGB(100, 110, 150),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = Input
            })

            table.insert(AllElements, {frame = Input, name = text or "Input", tab = name})

            TextBox.Focused:Connect(function()
                CreateTween(InputStroke, {Color = Color3.fromRGB(100, 150, 255), Transparency = 0.2, Thickness = 1.5}, 0.3)
                CreateTween(Input, {BackgroundColor3 = Color3.fromRGB(20, 25, 35)}, 0.3)
            end)

            TextBox.FocusLost:Connect(function(enterPressed)
                CreateTween(InputStroke, {Color = Color3.fromRGB(60, 80, 120), Transparency = 0.5, Thickness = 1}, 0.3)
                CreateTween(Input, {BackgroundColor3 = Color3.fromRGB(15, 15, 22)}, 0.3)
                if enterPressed and callback then
                    callback(TextBox.Text)
                end
            end)

            return {
                Set = function(value)
                    TextBox.Text = value
                end,
                Get = function()
                    return TextBox.Text
                end
            }
        end

        -- Label element
        function TabAPI:Label(text)
            local Label = CreateInstance("TextLabel", {
                Size = UDim2.new(1, -8, 0, 24),
                BackgroundTransparency = 1,
                Text = text or "Label",
                TextColor3 = Color3.fromRGB(100, 120, 160),
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabContent
            })

            table.insert(AllElements, {frame = Label, name = text or "Label", tab = name})
            return Label
        end

        -- Separator element
        function TabAPI:Separator()
            local Separator = CreateInstance("Frame", {
                Size = UDim2.new(1, -25, 0, 1),
                BackgroundColor3 = Color3.fromRGB(40, 50, 70),
                Parent = TabContent
            })
            AddCorner(Separator, 1)

            local SeparatorGradient = CreateInstance("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 50, 70)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 150, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 50, 70))
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.5, 0),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Parent = Separator
            })

            return Separator
        end

        -- Keybind element
        function TabAPI:Keybind(text, keybindIcon, default, callback)
            local Key = default or Enum.KeyCode.E
            local IsListening = false

            local Keybind = CreateInstance("Frame", {
                Size = UDim2.new(1, -8, 0, 40),
                BackgroundColor3 = Color3.fromRGB(20, 24, 32),
                Parent = TabContent
            })
            AddCorner(Keybind, 8)
            local KeybindStroke = AddStroke(Keybind, Color3.fromRGB(50, 60, 80))

            CreateInstance("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 12, 0.5, -9),
                BackgroundTransparency = 1,
                Image = Icons[keybindIcon] or Icons.Settings,
                ImageColor3 = Color3.fromRGB(100, 150, 255),
                Parent = Keybind
            })

            CreateInstance("TextLabel", {
                Size = UDim2.new(1, -120, 1, 0),
                Position = UDim2.new(0, 38, 0, 0),
                BackgroundTransparency = 1,
                Text = text or "Keybind",
                TextColor3 = Color3.fromRGB(220, 230, 255),
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Keybind
            })

            local KeyButton = CreateInstance("TextButton", {
                Size = UDim2.new(0, 60, 0, 24),
                Position = UDim2.new(1, -68, 0.5, -12),
                BackgroundColor3 = Color3.fromRGB(30, 35, 45),
                Text = Key.Name,
                TextColor3 = Color3.fromRGB(150, 170, 220),
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                Parent = Keybind
            })
            AddCorner(KeyButton, 6)
            local KeyButtonStroke = AddStroke(KeyButton, Color3.fromRGB(50, 60, 80))

            table.insert(AllElements, {frame = Keybind, name = text or "Keybind", tab = name})

            KeyButton.MouseButton1Click:Connect(function()
                IsListening = true
                KeyButton.Text = "..."
                CreateTween(KeyButtonStroke, {Color = Color3.fromRGB(100, 150, 255)}, 0.2)
                CreateTween(KeybindStroke, {Color = Color3.fromRGB(100, 150, 255), Transparency = 0.3}, 0.2)
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if IsListening and input.UserInputType == Enum.UserInputType.Keyboard and not gameProcessed then
                    Key = input.KeyCode
                    KeyButton.Text = Key.Name
                    IsListening = false
                    CreateTween(KeyButtonStroke, {Color = Color3.fromRGB(50, 60, 80)}, 0.2)
                    CreateTween(KeybindStroke, {Color = Color3.fromRGB(50, 60, 80), Transparency = 0.5}, 0.2)
                    if callback then
                        callback(Key)
                    end
                end
            end)

            return {
                Set = function(value)
                    Key = value
                    KeyButton.Text = value.Name
                end,
                Get = function()
                    return Key
                end
            }
        end

        -- ColorPicker element
        function TabAPI:ColorPicker(text, colorIcon, default, callback)
            local Color = default or Color3.fromRGB(100, 150, 255)
            local IsExpanded = false

            local ColorPicker = CreateInstance("Frame", {
                Size = UDim2.new(1, -8, 0, 40),
                BackgroundColor3 = Color3.fromRGB(20, 24, 32),
                ClipsDescendants = true,
                Parent = TabContent
            })
            AddCorner(ColorPicker, 8)
            local ColorPickerStroke = AddStroke(ColorPicker, Color3.fromRGB(50, 60, 80))

            CreateInstance("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 12, 0, 11),
                BackgroundTransparency = 1,
                Image = Icons[colorIcon] or Icons.Home,
                ImageColor3 = Color3.fromRGB(100, 150, 255),
                Parent = ColorPicker
            })

            CreateInstance("TextLabel", {
                Size = UDim2.new(1, -120, 0, 40),
                Position = UDim2.new(0, 38, 0, 0),
                BackgroundTransparency = 1,
                Text = text or "Color",
                TextColor3 = Color3.fromRGB(220, 230, 255),
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ColorPicker
            })

            local Preview = CreateInstance("Frame", {
                Size = UDim2.new(0, 45, 0, 22),
                Position = UDim2.new(1, -55, 0, 9),
                BackgroundColor3 = Color,
                Parent = ColorPicker
            })
            AddCorner(Preview, 6)
            AddStroke(Preview, Color3.fromRGB(60, 80, 120))

            local Colors = {
                Color3.fromRGB(255, 0, 0),      -- Red
                Color3.fromRGB(255, 127, 0),    -- Orange
                Color3.fromRGB(255, 255, 0),    -- Yellow
                Color3.fromRGB(0, 255, 0),      -- Green
                Color3.fromRGB(0, 255, 255),    -- Cyan
                Color3.fromRGB(0, 127, 255),    -- Light Blue
                Color3.fromRGB(0, 0, 255),      -- Blue
                Color3.fromRGB(127, 0, 255),    -- Purple
                Color3.fromRGB(255, 0, 255),    -- Magenta
                Color3.fromRGB(255, 255, 255),  -- White
                Color3.fromRGB(180, 180, 180),  -- Light Gray
                Color3.fromRGB(100, 100, 100),  -- Gray
                Color3.fromRGB(50, 50, 50),     -- Dark Gray
                Color3.fromRGB(0, 0, 0)         -- Black
            }

            local ColorGrid = CreateInstance("Frame", {
                Size = UDim2.new(1, -16, 0, 50),
                Position = UDim2.new(0, 8, 0, 46),
                BackgroundTransparency = 1,
                Parent = ColorPicker
            })
            CreateInstance("UIGridLayout", {
                CellSize = UDim2.new(0, 32, 0, 22),
                CellPadding = UDim2.new(0, 5, 0, 5),
                Parent = ColorGrid
            })

            table.insert(AllElements, {frame = ColorPicker, name = text or "ColorPicker", tab = name})

            for _, colorValue in ipairs(Colors) do
                local ColorButton = CreateInstance("TextButton", {
                    Size = UDim2.new(0, 32, 0, 22),
                    BackgroundColor3 = colorValue,
                    Text = "",
                    Parent = ColorGrid
                })
                AddCorner(ColorButton, 4)

                ColorButton.MouseButton1Click:Connect(function()
                    Color = colorValue
                    Preview.BackgroundColor3 = colorValue
                    if callback then
                        callback(colorValue)
                    end
                end)

                ColorButton.MouseEnter:Connect(function()
                    CreateTween(ColorButton, {Size = UDim2.new(0, 34, 0, 24)}, 0.1, Enum.EasingStyle.Back)
                end)

                ColorButton.MouseLeave:Connect(function()
                    CreateTween(ColorButton, {Size = UDim2.new(0, 32, 0, 22)}, 0.1)
                end)
            end

            local HeaderButton = CreateInstance("TextButton", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Text = "",
                Parent = ColorPicker
            })

            HeaderButton.MouseButton1Click:Connect(function()
                IsExpanded = not IsExpanded
                CreateTween(ColorPicker, {
                    Size = UDim2.new(1, -8, 0, IsExpanded and 110 or 40)
                }, 0.3, Enum.EasingStyle.Back)
                CreateTween(ColorPickerStroke, {
                    Color = IsExpanded and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 60, 80)
                }, 0.2)
            end)

            return {
                Set = function(value)
                    Color = value
                    Preview.BackgroundColor3 = value
                end,
                Get = function()
                    return Color
                end
            }
        end

        return TabAPI
    end

    function WindowAPI:Notify(title, content, duration, icon)
    return MirageUI:Notify(title, content, duration, icon)
    end

    function WindowAPI:Destroy()
        ScreenGui:Destroy()
    end

    return WindowAPI
end

return MirageUI