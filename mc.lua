--========================================================--
-- PART 1: KEY SAVE / LOAD SYSTEM
--========================================================--

local SAVED_KEY_FILE = "goodboy_key.txt"

local function SaveKey(key)
    pcall(function()
        writefile(SAVED_KEY_FILE, key)
    end)
end

local function LoadSavedKey()
    local ok, result = pcall(function()
        return readfile(SAVED_KEY_FILE)
    end)
    if ok and typeof(result) == "string" and result ~= "" then
        return result
    end
    return nil
end

--========================================================--
-- PART 1: SERVICES, CONFIG, COLORS, STATE
--========================================================--

local Services = {

    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- CONFIG
local Config = {
    MaxKeyLength = 50,
    AnimationSpeed = 0.4,
    ParticleCount = 60,
    ParticleSpeed = 60
}

-- COLOR SCHEME
local Colors = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(25, 25, 30),
    Primary = Color3.fromRGB(45, 45, 50),
    Secondary = Color3.fromRGB(35, 35, 40),
    Border = Color3.fromRGB(40, 40, 45),
    TextPrimary = Color3.fromRGB(220, 220, 225),
    TextSecondary = Color3.fromRGB(140, 140, 150),
    Success = Color3.fromRGB(25, 135, 84),
    Error = Color3.fromRGB(180, 50, 50),
    Warning = Color3.fromRGB(200, 120, 30),
    Discord = Color3.fromRGB(60, 70, 180),
    GetKey = Color3.fromRGB(40, 140, 100),
    HoverPrimary = Color3.fromRGB(55, 55, 60),
    HoverDiscord = Color3.fromRGB(50, 60, 160),
    HoverGetKey = Color3.fromRGB(30, 120, 80),
    NeonWhite = Color3.fromRGB(255, 255, 255),
    NeonGlow = Color3.fromRGB(240, 248, 255)
}

-- STATE
local State = {
    IsLoading = false,
    Particles = {},
    Animations = {},
    IsDestroyed = false,
    MousePosition = {X = 0, Y = 0},
    FocusStates = {
        InputFocused = false,
        ButtonHovered = {},
        AnimationsActive = true
    }
}

-- UI reference container
local UI = {}

local KEY_URL = "https://pastebin.com/raw/mHTfUEdG"
local DISCORD_LINK = "https://discord.gg/nsWY4CRj5A"

local function FetchValidKey()
    local success, result = pcall(function()
        return game:HttpGet(KEY_URL)
    end)

    if success and result and result ~= "" then
        return string.gsub(result, "%s+", "")
    end

    return nil
end

local function ValidateKey(inputKey)
    local validKey = FetchValidKey()
    if not validKey then
        ShowStatus("Failed to fetch key.", true)
        return false
    end

    return inputKey == validKey
end

--========================================================--
-- PART 2: GUI CREATION (FULL)
--========================================================--

-- MAIN GUI
local function CreateMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeySystemGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 100
    screenGui.Parent = PlayerGui

    UI.ScreenGui = screenGui
    return screenGui
end

-- BACKDROP
local function CreateBackdrop(parent)
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.35
    backdrop.BorderSizePixel = 0
    backdrop.ZIndex = 100
    backdrop.Parent = parent

    UI.Backdrop = backdrop
    return backdrop
end

-- MAIN CONTAINER
local function CreateContainer(parent)
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.new(0, 420, 0, 600)
    container.Position = UDim2.new(0.5, -210, 0.5, -300)
    container.BackgroundColor3 = Colors.Background
    container.BorderSizePixel = 0
    container.ZIndex = 110
    container.Parent = parent

    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 20)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = container

    UI.Container = container
    return container
end

-- GLOWING BORDER
local function CreateAnimatedBorder(parent)
    local border = Instance.new("Frame")
    border.Name = "AnimatedBorder"
    border.Size = UDim2.new(1, 6, 1, 6)
    border.Position = UDim2.new(0, -3, 0, -3)
    border.BackgroundTransparency = 1
    border.ZIndex = 109
    border.Parent = parent

    Instance.new("UICorner", border).CornerRadius = UDim.new(0, 23)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.NeonWhite
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = border

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.NeonWhite),
        ColorSequenceKeypoint.new(0.5, Colors.NeonGlow),
        ColorSequenceKeypoint.new(1, Colors.NeonWhite)
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.2, 0.1),
        NumberSequenceKeypoint.new(0.8, 0.1),
        NumberSequenceKeypoint.new(1, 0.9)
    }
    gradient.Parent = stroke

    UI.AnimatedBorder = {Frame = border, Gradient = gradient, Stroke = stroke}
    return border
end

-- HEADER
local function CreateHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 80)
    header.BackgroundTransparency = 1
    header.ZIndex = 111
    header.Parent = parent

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Access Key Required"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 28
    title.ZIndex = 112
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -20, 0, 20)
    subtitle.Position = UDim2.new(0, 10, 0, 45)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Add your access key to continue."
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextColor3 = Colors.TextSecondary
    subtitle.TextSize = 16
    subtitle.ZIndex = 112
    subtitle.Parent = header

    UI.Header = header
end

-- CONTENT HOLDER
local function CreateContent(parent)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -80)
    content.Position = UDim2.new(0, 0, 0, 80)
    content.BackgroundTransparency = 1
    content.ZIndex = 111
    content.Parent = parent

    UI.Content = content
    return content
end

-- INPUT SECTION
local function CreateInputSection(parent)
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "Input"
    inputFrame.Size = UDim2.new(1, -40, 0, 60)
    inputFrame.Position = UDim2.new(0, 20, 0, 20)
    inputFrame.BackgroundColor3 = Colors.Surface
    inputFrame.ZIndex = 112
    inputFrame.Parent = parent

    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = inputFrame

    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, -20, 1, -20)
    textBox.Position = UDim2.new(0, 10, 0, 10)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.PlaceholderText = "Enter your access key..."
    textBox.Font = Enum.Font.Gotham
    textBox.TextColor3 = Colors.TextPrimary
    textBox.PlaceholderColor3 = Colors.TextSecondary
    textBox.TextSize = 18
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 113
    textBox.Parent = inputFrame

    local counter = Instance.new("TextLabel")
    counter.Name = "Counter"
    counter.Size = UDim2.new(1, -12, 0, 16)
    counter.Position = UDim2.new(0, 6, 1, -18)
    counter.BackgroundTransparency = 1
    counter.Font = Enum.Font.Gotham
    counter.TextColor3 = Colors.TextSecondary
    counter.TextSize = 14
    counter.TextXAlignment = Enum.TextXAlignment.Right
    counter.ZIndex = 113
    counter.Text = "0/" .. Config.MaxKeyLength
    counter.Parent = inputFrame

    UI.Input = {
        Frame = inputFrame,
        TextBox = textBox,
        Counter = counter,
        Stroke = stroke
    }
end

-- BUTTONS
local function CreateButtons(parent)
    local buttons = {}

    local function MakeButton(name, posY, color)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(1, -40, 0, 50)
        btn.Position = UDim2.new(0, 20, 0, posY)
        btn.BackgroundColor3 = color
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.ZIndex = 112
        btn.Parent = parent

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

        return btn
    end

    buttons.Submit = MakeButton("Verify Access Key", 110, Colors.Primary)
    buttons.GetKey = MakeButton("Get Key", 170, Colors.GetKey)
    buttons.Discord = MakeButton("Join Discord", 230, Colors.Discord)

    local loader = Instance.new("Frame")
    loader.Name = "Loading"
    loader.Size = UDim2.new(0, 30, 0, 30)
    loader.Position = UDim2.new(0.5, -15, 0.5, -15)
    loader.BackgroundTransparency = 1
    loader.Visible = false
    loader.ZIndex = 113
    loader.Parent = buttons.Submit

    local spinner = Instance.new("ImageLabel")
    spinner.Name = "Spinner"
    spinner.Size = UDim2.new(1, 0, 1, 0)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://3926307971"
    spinner.ImageRectOffset = Vector2.new(4, 4)
    spinner.ImageRectSize = Vector2.new(36, 36)
    spinner.ZIndex = 114
    spinner.Parent = loader

    buttons.Loading = {
        Container = loader,
        Spinner = spinner
    }

    UI.Buttons = buttons
end

-- STATUS LABEL
local function CreateStatus(parent)
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.new(0, 20, 0, 300)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextColor3 = Colors.Warning
    status.TextSize = 16
    status.ZIndex = 112
    status.Text = ""
    status.TextTransparency = 1
    status.Parent = parent

    UI.Status = status
end

--========================================================--
-- PART 3: STATUS DISPLAY, LOADING, PARTICLES, ANIM LOOPS
--========================================================--

-- STATUS DISPLAY
local function ShowStatus(message, isError, isSuccess)
    if not UI.Status then return end

    UI.Status.Text = message

    if isSuccess then
        UI.Status.TextColor3 = Colors.Success
    elseif isError then
        UI.Status.TextColor3 = Colors.Error
    else
        UI.Status.TextColor3 = Colors.Warning
    end

    UI.Status.TextTransparency = 1

    Services.TweenService:Create(
        UI.Status,
        TweenInfo.new(0.3),
        {TextTransparency = 0}
    ):Play()
end

local function ClearStatus()
    if UI.Status then
        Services.TweenService:Create(
            UI.Status,
            TweenInfo.new(0.3),
            {TextTransparency = 1}
        ):Play()
    end
end

-- SET LOADING STATE
local function SetLoading(isLoading)
    State.IsLoading = isLoading

    UI.Buttons.Loading.Container.Visible = isLoading
    UI.Buttons.Submit.Text = isLoading and "" or "Verify Access Key"

    if isLoading then
        local tween = Services.TweenService:Create(
            UI.Buttons.Loading.Spinner,
            TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
            {Rotation = 360}
        )
        tween:Play()
        State.Animations.SpinTween = tween
    else
        if State.Animations.SpinTween then
            State.Animations.SpinTween:Cancel()
        end
        UI.Buttons.Loading.Spinner.Rotation = 0
    end
end

-- COPY TO CLIPBOARD
local function CopyToClipboard(text)
    local ok = pcall(function()
        if setclipboard then
            setclipboard(text)
        end
    end)

    if ok then
        ShowStatus("Copied to clipboard.", false, true)
    else
        ShowStatus("Link: " .. text, false, true)
    end
end

-- CHARACTER COUNTER
local function UpdateCharCounter()
    local currentLength = #UI.Input.TextBox.Text
    UI.Input.Counter.Text = currentLength .. "/" .. Config.MaxKeyLength

    if currentLength >= Config.MaxKeyLength then
        UI.Input.Counter.TextColor3 = Colors.Error
    elseif currentLength >= Config.MaxKeyLength * 0.8 then
        UI.Input.Counter.TextColor3 = Colors.Warning
    else
        UI.Input.Counter.TextColor3 = Colors.TextSecondary
    end
end

--========================================================--
-- PARTICLE SYSTEM
--========================================================--

local function CreateParticleContainer(parent)
    local container = Instance.new("Frame")
    container.Name = "ParticleContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ZIndex = 105
    container.Parent = parent

    UI.ParticleContainer = container
end

-- SINGLE PARTICLE
local function CreateParticle()
    if not UI.ParticleContainer or State.IsDestroyed then return end

    local size = math.random(8, 22)
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, size, 0, size)
    p.Position = UDim2.new(math.random(), 0, 1.2, 0)
    p.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    p.BackgroundTransparency = 0.7
    p.BorderSizePixel = 0
    p.ZIndex = 106
    p.Parent = UI.ParticleContainer

    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)

    local data = {
        frame = p,
        vx = (math.random() - 0.5) * 0.003,
        vy = -math.random(25, 45) / 10000,
        rot = math.random() * 360,
        rotSpeed = (math.random() - 0.5) * 2,
        created = tick(),
        lifetime = math.random(30, 50),
        size = size,
        pulse = math.random() * math.pi * 2
    }

    table.insert(State.Particles, data)
end

-- UPDATE ALL PARTICLES
local function UpdateParticles()
    if State.IsDestroyed then return end

    for i = #State.Particles, 1, -1 do
        local p = State.Particles[i]
        if not p.frame or not p.frame.Parent then
            table.remove(State.Particles, i)
            continue
        end

        local age = tick() - p.created
        if age > p.lifetime or p.frame.Position.Y.Scale < -0.3 then
            p.frame:Destroy()
            table.remove(State.Particles, i)
            continue
        end

        p.rot += p.rotSpeed
        p.frame.Rotation = p.rot

        p.frame.Position = UDim2.new(
            p.frame.Position.X.Scale + p.vx,
            0,
            p.frame.Position.Y.Scale + p.vy,
            0
        )

        local s = p.size * (1 + math.sin(tick() * 2 + p.pulse) * 0.15)
        p.frame.Size = UDim2.new(0, s, 0, s)
    end
end

--========================================================--
-- ANIMATION LOOPS
--========================================================--

local function StartAnimationLoops()

    task.spawn(function()
        while not State.IsDestroyed and UI.ParticleContainer do
            if #State.Particles < Config.ParticleCount then
                CreateParticle()
            end
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while not State.IsDestroyed do
            UpdateParticles()
            task.wait(1 / Config.ParticleSpeed)
        end
    end)

    task.spawn(function()
        while not State.IsDestroyed and UI.AnimatedBorder do
            local tween = Services.TweenService:Create(
                UI.AnimatedBorder.Gradient,
                TweenInfo.new(3, Enum.EasingStyle.Linear),
                {Rotation = UI.AnimatedBorder.Gradient.Rotation + 360}
            )
            tween:Play()
            tween.Completed:Wait()
            UI.AnimatedBorder.Gradient.Rotation %= 360
        end
    end)
end

--========================================================--
-- ENTRANCE ANIMATION
--========================================================--

local function PlayEntranceAnimation()
    UI.Container.Size = UDim2.new(0, 0, 0, 0)
    UI.Container.BackgroundTransparency = 1
    UI.Backdrop.BackgroundTransparency = 1

    Services.TweenService:Create(
        UI.Backdrop,
        TweenInfo.new(0.35),
        {BackgroundTransparency = 0.35}
    ):Play()

    task.wait(0.12)

    Services.TweenService:Create(
        UI.Container,
        TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 420, 0, 600), BackgroundTransparency = 0}
    ):Play()

    task.wait(0.55)

    if UI.Input and UI.Input.TextBox then
        UI.Input.TextBox:CaptureFocus()
    end
end

--========================================================--
-- PART 4: EVENT CONNECTIONS
--========================================================--

local function ConnectEvents()

    -- Mouse tracking
    Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            State.MousePosition.X = input.Position.X
            State.MousePosition.Y = input.Position.Y
        end
    end)

    -- Character limit + counter
    UI.Input.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = UI.Input.TextBox.Text

        if #txt > Config.MaxKeyLength then
            UI.Input.TextBox.Text = string.sub(txt, 1, Config.MaxKeyLength)
            ShowStatus("Max character limit reached!", true)
        end

        UpdateCharCounter()
        ClearStatus()
    end)

    --============ ENTER VALIDATION ============--
    Services.UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Return and UI.Input.TextBox:IsFocused() then

            local key = UI.Input.TextBox.Text

            if key == "" then
                ShowStatus("Enter a key first.", true)
                return
            end

            SetLoading(true)
            ShowStatus("Validating key...", false, false)

            task.wait(1)

            if ValidateKey(key) then
                SaveKey(key)
                ShowStatus("Access granted!", false, true)

                task.wait(0.3)
                UI.ScreenGui:Destroy()

                loadstring(game:HttpGet("https://raw.githubusercontent.com/zsxltyy/goodboy/main/mc.lua"))()
            else
                ShowStatus("Invalid key!", true)
            end

            SetLoading(false)
        end
    end)

    --============ SUBMIT BUTTON VALIDATION ============--
    UI.Buttons.Submit.MouseButton1Click:Connect(function()
        if State.IsLoading then return end

        local key = UI.Input.TextBox.Text

        if key == "" then
            ShowStatus("Enter a key first.", true)
            return
        end

        SetLoading(true)
        ShowStatus("Validating key...", false, false)

        task.wait(1)

        if ValidateKey(key) then
            SaveKey(key)
            ShowStatus("Access granted!", false, true)

            task.wait(0.3)
            UI.ScreenGui:Destroy()

            loadstring(game:HttpGet("https://raw.githubusercontent.com/zsxltyy/goodboy/main/mc.lua"))()
        else
            ShowStatus("Invalid key!", true)
        end

        SetLoading(false)
    end)

    --============ GET KEY BUTTON ============--
UI.Buttons.GetKey.MouseButton1Click:Connect(function()
    CopyToClipboard("https://bst.gg/kxpqu")  -- <-- reklámos link IDE
end)

    --============ DISCORD BUTTON ============--
    UI.Buttons.Discord.MouseButton1Click:Connect(function()
        CopyToClipboard(DISCORD_LINK)
    end)
end

UI.Functions = {
    ShowStatus = ShowStatus,
    ClearStatus = ClearStatus,
    SetLoading = SetLoading,
    ValidateKey = ValidateKey,
    ConnectEvents = ConnectEvents
}

--========================================================--
-- AUTO LOGIN CHECK (AFTER GUI FUNCTIONS LOADED)
--========================================================--

local savedKey = LoadSavedKey()
local currentValid = FetchValidKey()

if savedKey and currentValid and savedKey == currentValid then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/zsxltyy/goodboy/main/mc.lua"))()
    return
end

--========================================================--
-- INITIALIZER
--========================================================--

local function Initialize()
    local screenGui = CreateMainGUI()
    local backdrop = CreateBackdrop(screenGui)
    CreateParticleContainer(backdrop)

    local container = CreateContainer(screenGui)
    CreateAnimatedBorder(container)

    CreateHeader(container)
    local content = CreateContent(container)

    CreateInputSection(content)
    CreateButtons(content)
    CreateStatus(content)

    ConnectEvents()
    StartAnimationLoops()
    PlayEntranceAnimation()
end

Initialize()
