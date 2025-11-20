--========================================================
--  NEBULAHUB – SAFE GUI WITH FUNCTIONS
--========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

----------------------------------------------------
-- SCREEN GUI
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "NebulaHub_UI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

----------------------------------------------------
-- DRAG FUNCTION
----------------------------------------------------
local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        obj.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

----------------------------------------------------
-- LOADING SCREEN
----------------------------------------------------
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(0,400,0,200)
LoadingFrame.Position = UDim2.new(0.5,-200,0.5,-100)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0,20)

local Title = Instance.new("TextLabel", LoadingFrame)
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0.15,0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1)
Title.Text = "NebulaHub – Loading..."
Title.TextScaled = true

local Sub = Instance.new("TextLabel", LoadingFrame)
Sub.Size = UDim2.new(1,0,0,30)
Sub.Position = UDim2.new(0,0,0.38,0)
Sub.BackgroundTransparency = 1
Sub.Font = Enum.Font.Gotham
Sub.TextColor3 = Color3.fromRGB(180,180,180)
Sub.TextScaled = true
Sub.Text = "Welcome @"..LocalPlayer.Name

local BarBG = Instance.new("Frame", LoadingFrame)
BarBG.Size = UDim2.new(0.8,0,0,20)
BarBG.Position = UDim2.new(0.1,0,0.7,0)
BarBG.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", BarBG).CornerRadius = UDim.new(0,10)

local Bar = Instance.new("Frame", BarBG)
Bar.Size = UDim2.new(0,0,1,0)
Bar.BackgroundColor3 = Color3.fromRGB(255,80,255)
Instance.new("UICorner", Bar).CornerRadius = UDim.new(0,10)

TweenService:Create(Bar, TweenInfo.new(3, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,1,0)}):Play()
task.wait(3)
LoadingFrame:Destroy()

----------------------------------------------------
-- ROUND OPEN BUTTON
----------------------------------------------------
local CircleBtn = Instance.new("ImageButton", ScreenGui)
CircleBtn.Size = UDim2.new(0,60,0,60)
CircleBtn.Position = UDim2.new(0.08,0,0.3,0)
CircleBtn.Image = "rbxassetid://73373521013315"
CircleBtn.BackgroundTransparency = 1
Instance.new("UICorner", CircleBtn).CornerRadius = UDim.new(1,0)

local Stroke = Instance.new("UIStroke", CircleBtn)
Stroke.Thickness = 3

makeDraggable(CircleBtn)

task.spawn(function()
    while CircleBtn.Parent do
        TweenService:Create(Stroke, TweenInfo.new(1), {Color=Color3.fromRGB(180,0,255)}):Play()
        task.wait(1)
        TweenService:Create(Stroke, TweenInfo.new(1), {Color=Color3.fromRGB(255,80,255)}):Play()
        task.wait(1)
    end
end)

----------------------------------------------------
-- MAIN HUB WINDOW
----------------------------------------------------
local MainHub = Instance.new("Frame", ScreenGui)
MainHub.Size = UDim2.new(0,260,0,350)
MainHub.Position = UDim2.new(0.5,-130,0.5,-175)
MainHub.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainHub.Visible = false
Instance.new("UICorner", MainHub).CornerRadius = UDim.new(0,15)

local MHStroke = Instance.new("UIStroke", MainHub)
MHStroke.Color = Color3.fromRGB(255,40,255)
MHStroke.Thickness = 2

makeDraggable(MainHub)

CircleBtn.MouseButton1Click:Connect(function()
    MainHub.Visible = not MainHub.Visible
end)

----------------------------------------------------
-- TOP BAR
----------------------------------------------------
local Top = Instance.new("Frame", MainHub)
Top.Size = UDim2.new(1,0,0,60)
Top.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", Top).CornerRadius = UDim.new(0,15)

local Icon = Instance.new("ImageLabel", Top)
Icon.Size = UDim2.new(0,40,0,40)
Icon.Position = UDim2.new(0,8,0,10)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://73373521013315"
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local TitleFrame = Instance.new("Frame", Top)
TitleFrame.Size = UDim2.new(1,-60,1,0)
TitleFrame.Position = UDim2.new(0,55,0,0)
TitleFrame.BackgroundTransparency = 1

local T1 = Instance.new("TextLabel", TitleFrame)
T1.Size = UDim2.new(1,0,0.5,0)
T1.BackgroundTransparency = 1
T1.Font = Enum.Font.GothamBlack
T1.TextSize = 26
T1.TextXAlignment = Enum.TextXAlignment.Left
T1.Text = "Nebula"

local T2 = Instance.new("TextLabel", TitleFrame)
T2.Size = UDim2.new(1,0,0.5,0)
T2.Position = UDim2.new(0,0,0.5,0)
T2.BackgroundTransparency = 1
T2.Font = Enum.Font.GothamBold
T2.TextSize = 20
T2.TextXAlignment = Enum.TextXAlignment.Left
T2.TextColor3 = Color3.fromRGB(200,200,200)
T2.Text = "Hub Premium"

----------------------------------------------------
-- BUTTON SCROLL FRAME
----------------------------------------------------
local Scroll = Instance.new("ScrollingFrame", MainHub)
Scroll.Size = UDim2.new(1,-20,1,-65)
Scroll.Position = UDim2.new(0,10,0,60)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6

local Layout = Instance.new("UIListLayout", Scroll)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0,5)

local function updateCanvas()
    Scroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y)
end

Layout:GetPropertyChangedSignal("AbsoluteContentSize")
    :Connect(updateCanvas)

----------------------------------------------------
-- BUTTON MAKER (ANIMATED)
----------------------------------------------------
local function makeButton(name, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1,-20,0,50)
    btn.BackgroundColor3 = Color3.fromRGB(255,40,255)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextColor3 = Color3.new(0,0,0)
    btn.TextScaled = true

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

    local active = false

    btn.MouseButton1Click:Connect(function()
        active = not active

        TweenService:Create(
            btn,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad),
            {BackgroundColor3 = active and Color3.fromRGB(0,255,0)
                or Color3.fromRGB(255,40,255)}
        ):Play()

        callback(active)
    end)
end

----------------------------------------------------
-- FUNCTION LOGIC
----------------------------------------------------
local toggles = {
    infiniteJump = false,
    autoFloor = false,
    esp = false
}

local currentRoot, currentHumanoid
local jumpPressed = false
local activeBlock = nil
local espObjects = {}
local PLATFORM_SIZE = Vector3.new(6,0.2,6)
local PLATFORM_COLOR = Color3.fromRGB(200,150,255)

----------------------------------------------------
-- ESP FUNCTION
----------------------------------------------------
local function clearESP()
    for _, set in pairs(espObjects) do
        if set.highlight then
            set.highlight:Destroy()
        end
    end
    espObjects = {}
end

local function applyESP()
    clearESP()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = plr.Character
            highlight.FillTransparency = 0.5
            highlight.FillColor = Color3.fromRGB(255,0,0)
            highlight.OutlineColor = Color3.fromRGB(255,0,0)
            highlight.Parent = plr.Character

            espObjects[plr] = {highlight = highlight}
        end
    end
end

----------------------------------------------------
-- SERVER HOP
----------------------------------------------------
local function serverHop()
    local placeId = tostring(game.PlaceId)
    local currentJob = tostring(game.JobId)

    local function fetch(cursor)
        local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
        if cursor then
            url = url .. "&cursor="..HttpService:UrlEncode(cursor)
        end

        local ok, body = pcall(function()
            return game:HttpGet(url)
        end)
        if not ok then return end

        local ok2, data = pcall(function()
            return HttpService:JSONDecode(body)
        end)

        if ok2 then return data end
    end

    local servers = {}
    local cursor = nil

    for _ = 1,5 do
        local data = fetch(cursor)
        if not data then break end

        for _, srv in ipairs(data.data) do
            if srv.id ~= currentJob and srv.playing < srv.maxPlayers then
                table.insert(servers, srv.id)
            end
        end

        cursor = data.nextPageCursor
        if not cursor then break end
    end

    if #servers == 0 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            servers[math.random(1, #servers)],
            LocalPlayer
        )
    end
end

----------------------------------------------------
-- BUTTONS
----------------------------------------------------
makeButton("Infinite Jump", function(state)
    toggles.infiniteJump = state
end)

makeButton("Auto Floor", function(state)
    toggles.autoFloor = state
end)

makeButton("ESP Players", function(state)
    toggles.esp = state
    if state then
        applyESP()
    else
        clearESP()
    end
end)

makeButton("Server Hop", function()
    serverHop()
end)

----------------------------------------------------
-- CHARACTER TRACKING
----------------------------------------------------
local function onCharacterAdded(char)
    currentHumanoid = char:WaitForChild("Humanoid")
    currentRoot = char:WaitForChild("HumanoidRootPart")
end

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

----------------------------------------------------
-- INPUT HANDLER
----------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.Space then
        jumpPressed = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        jumpPressed = false
    end
end)

----------------------------------------------------
-- MAIN LOOP
----------------------------------------------------
local lastESP = false

RunService.RenderStepped:Connect(function()
    -- INFINITE JUMP
    if toggles.infiniteJump and jumpPressed and currentRoot then
        currentRoot.Velocity = Vector3.new(
            currentRoot.Velocity.X,
            50,
            currentRoot.Velocity.Z
        )
    end

    -- AUTO FLOOR
    if toggles.autoFloor and currentRoot and currentHumanoid then
        if not activeBlock or not activeBlock.Parent then
            activeBlock = Instance.new("Part")
            activeBlock.Size = PLATFORM_SIZE
            activeBlock.Anchored = true
            activeBlock.CanCollide = true
            activeBlock.Material = Enum.Material.Neon
            activeBlock.Color = PLATFORM_COLOR
            activeBlock.Parent = Workspace
        end

        activeBlock.Position = currentRoot.Position - Vector3.new(
            0,
            currentHumanoid.HipHeight + activeBlock.Size.Y / 2,
            0
        )
    elseif activeBlock then
        activeBlock:Destroy()
        activeBlock = nil
    end

    -- ESP AUTO REFRESH
    if toggles.esp ~= lastESP then
        lastESP = toggles.esp
        if toggles.esp then
            applyESP()
        else
            clearESP()
        end
    end
end)
