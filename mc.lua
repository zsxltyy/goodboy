--========================================================
--  NEBULAHUB – FULL WORKING SCRIPT
--========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- REMOVE OLD GUI
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("NebulaHub_UI") then
        pg.NebulaHub_UI:Destroy()
    end
end)

----------------------------------------------------------
-- VARIABLES
----------------------------------------------------------
local toggles = {
    infiniteJump = false,
    autoFloor = false,
    esp = false
}

local THEMES = {
    Color3.fromRGB(18,18,25),
    Color3.fromRGB(50,0,80),
    Color3.fromRGB(0,50,100),
    Color3.fromRGB(80,0,0),
    Color3.fromRGB(0,80,40),
    Color3.fromRGB(120,60,180),
    Color3.fromRGB(255,100,0),
    Color3.fromRGB(255,20,147),
    Color3.fromRGB(0,255,200),
    Color3.fromRGB(255,255,255)
}

local currentRoot, currentHumanoid
local jumpPressed = false
local activeBlock = nil
local espObjects = {}

local PLATFORM_SIZE = Vector3.new(6,0.2,6)
local PLATFORM_COLOR = Color3.fromRGB(200,150,255)

local gui, mainFrame, sidebar, mainPanel, infoPanel
local autoFrame, toggleAF
local themePanel

----------------------------------------------------------
-- DRAG SYSTEM
----------------------------------------------------------
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

----------------------------------------------------------
-- MAIN GUI
----------------------------------------------------------
gui = Instance.new("ScreenGui")
gui.Name = "NebulaHub_UI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0,45,0,45)
toggleBtn.Position = UDim2.new(0,20,0.4,0)
toggleBtn.Text = "Nebula"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextScaled = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,6)
makeDraggable(toggleBtn)

mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0,530,0,350)
mainFrame.Position = UDim2.new(0.5,-265,0.5,-175)
mainFrame.BackgroundColor3 = THEMES[1]
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,14)
makeDraggable(mainFrame)

local function openHub()
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0,0,0,0)
    TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
        Size = UDim2.new(0,530,0,350)
    }):Play()
end

local function closeHub()
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0,0,0,0)
    }):Play()
    task.wait(0.3)
    mainFrame.Visible = false
end

toggleBtn.MouseButton1Click:Connect(function()
    if mainFrame.Visible then closeHub() else openHub() end
end)

----------------------------------------------------------
-- SIDEBAR
----------------------------------------------------------
sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0,130,1,0)
sidebar.BackgroundColor3 = THEMES[1]
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,12)

----------------------------------------------------------
-- PANELS
----------------------------------------------------------
mainPanel = Instance.new("Frame", mainFrame)
mainPanel.Size = UDim2.new(1,-140,1,-20)
mainPanel.Position = UDim2.new(0,140,0,10)
mainPanel.BackgroundTransparency = 1

infoPanel = Instance.new("Frame", mainFrame)
infoPanel.Size = UDim2.new(1,-140,1,-20)
infoPanel.Position = UDim2.new(0,140,0,350)
infoPanel.BackgroundTransparency = 1

themePanel = Instance.new("Frame", mainFrame)
themePanel.Size = UDim2.new(1,-140,1,-20)
themePanel.Position = UDim2.new(0,140,0,350)
themePanel.BackgroundTransparency = 1

----------------------------------------------------------
-- TITLE IN MAIN
----------------------------------------------------------
local mainTitle = Instance.new("TextLabel", mainPanel)
mainTitle.Size = UDim2.new(1,0,0,50)
mainTitle.BackgroundTransparency = 1
mainTitle.Font = Enum.Font.GothamBold
mainTitle.TextScaled = true
mainTitle.TextColor3 = Color3.fromRGB(0,200,255)
mainTitle.Text = "NebulaHub"

----------------------------------------------------------
-- SIDEBAR BUTTONS
----------------------------------------------------------
local function CreateSideButton(text, index)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1,-20,0,50)
    btn.Position = UDim2.new(0,10,0,20 + (index-1)*60)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    return btn
end

local btnMain   = CreateSideButton("MAIN", 1)
local btnInfo   = CreateSideButton("INFO", 2)
local btnTheme  = CreateSideButton("THEMES", 3)

----------------------------------------------------------
-- PANEL SLIDES
----------------------------------------------------------
local function showMain()
    TweenService:Create(mainPanel, TweenInfo.new(0.35), {Position = UDim2.new(0,140,0,10)}):Play()
    TweenService:Create(infoPanel, TweenInfo.new(0.35), {Position = UDim2.new(0,140,0,350)}):Play()
    TweenService:Create(themePanel, TweenInfo.new(0.35), {Position = UDim2.new(0,140,0,350)}):Play()
end

local function showInfo()
    TweenService:Create(mainPanel, TweenInfo.new(0.35), {Position = UDim2.new(0,140,0,-350)}):Play()
    TweenService:Create(infoPanel, TweenInfo.new(0.35), {Position = UDim2.new(0,140,0,10)}):Play()
    TweenService:Create(themePanel, TweenInfo.new(0.35), {Position = UDim2.new(0,140,0,350)}):Play()
end

local function showThemes()
    TweenService:Create(mainPanel, TweenInfo.new(0.35), {Position = UDim2.new(0,140,0,-350)}):Play()
    TweenService:Create(infoPanel, TweenInfo.new(0.35), {Position = UDim2.new(0,140,0,350)}):Play()
    TweenService:Create(themePanel, TweenInfo.new(0.35), {Position = UDim2.new(0,140,0,10)}):Play()
end

btnMain.MouseButton1Click:Connect(showMain)
btnInfo.MouseButton1Click:Connect(showInfo)
btnTheme.MouseButton1Click:Connect(showThemes)

----------------------------------------------------------
-- INFO PANEL CONTENT
----------------------------------------------------------
local infoTitle = Instance.new("TextLabel", infoPanel)
infoTitle.Size = UDim2.new(1,0,0,50)
infoTitle.BackgroundTransparency = 1
infoTitle.Font = Enum.Font.GothamBold
infoTitle.TextScaled = true
infoTitle.TextColor3 = Color3.fromRGB(0,200,255)
infoTitle.Text = "NebulaHub – INFO"

local function CreateCopy(text, link, pos)
    local b = Instance.new("TextButton", infoPanel)
    b.Size = UDim2.new(0.7,0,0,50)
    b.Position = UDim2.new(0.15,0,0,pos)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,55)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(function() setclipboard(link) end)
end

CreateCopy("Copy TikTok", "https://www.tiktok.com/@nebula_tt_?_r=1&_t=ZN-91SXgGubrrK", 100)
CreateCopy("Copy Discord", "https://discord.gg/nsWY4CRj5A", 170)

----------------------------------------------------------
-- THEMES PANEL
----------------------------------------------------------
local tTitle = Instance.new("TextLabel", themePanel)
tTitle.Size = UDim2.new(1,0,0,40)
tTitle.BackgroundTransparency = 1
tTitle.Font = Enum.Font.GothamBold
tTitle.TextScaled = true
tTitle.TextColor3 = Color3.fromRGB(0,200,255)
tTitle.Text = "Themes"

local x = 0
local y = 60

for _, clr in ipairs(THEMES) do
    local box = Instance.new("TextButton", themePanel)
    box.Size = UDim2.new(0,50,0,50)
    box.Position = UDim2.new(0,x,0,y)
    box.BackgroundColor3 = clr
    box.Text = ""
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)

    box.MouseButton1Click:Connect(function()
        mainFrame.BackgroundColor3 = clr
        sidebar.BackgroundColor3 = clr
    end)

    x = x + 60
    if x > 300 then x = 0 y = y + 60 end
end

----------------------------------------------------------
-- AUTO FLOOR WINDOW
----------------------------------------------------------
autoFrame = Instance.new("Frame", gui)
autoFrame.Size = UDim2.new(0,220,0,150)
autoFrame.Position = UDim2.new(0.5,-110,0.5,-75)
autoFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
autoFrame.Visible = false
Instance.new("UICorner", autoFrame).CornerRadius = UDim.new(0,12)
makeDraggable(autoFrame)

local autoTitle = Instance.new("TextLabel", autoFrame)
autoTitle.Size = UDim2.new(1,0,0,40)
autoTitle.BackgroundTransparency = 1
autoTitle.Font = Enum.Font.GothamBold
autoTitle.TextScaled = true
autoTitle.TextColor3 = Color3.fromRGB(0,200,255)
autoTitle.Text = "Auto Floor Settings"

toggleAF = Instance.new("TextButton", autoFrame)
toggleAF.Size = UDim2.new(0.8,0,0,40)
toggleAF.Position = UDim2.new(0.1,0,0.45,0)
toggleAF.BackgroundColor3 = Color3.fromRGB(40,40,55)
toggleAF.Font = Enum.Font.GothamBold
toggleAF.TextScaled = true
toggleAF.TextColor3 = Color3.new(1,1,1)
toggleAF.Text = "Auto Floor: OFF"
Instance.new("UICorner", toggleAF).CornerRadius = UDim.new(0,10)

local function updateAF()
    toggleAF.Text = toggles.autoFloor and "Auto Floor: ON" or "Auto Floor: OFF"
    toggleAF.BackgroundColor3 = toggles.autoFloor and Color3.fromRGB(0,170,90) or Color3.fromRGB(40,40,55)
end

toggleAF.MouseButton1Click:Connect(function()
    toggles.autoFloor = not toggles.autoFloor
    updateAF()
end)

local closeAF = Instance.new("TextButton", autoFrame)
closeAF.Size = UDim2.new(0.3,0,0,30)
closeAF.Position = UDim2.new(0.35,0,0.8,0)
closeAF.BackgroundColor3 = Color3.fromRGB(255,60,60)
closeAF.Font = Enum.Font.GothamBold
closeAF.TextScaled = true
closeAF.Text = "Close"
Instance.new("UICorner", closeAF).CornerRadius = UDim.new(0,8)

closeAF.MouseButton1Click:Connect(function()
    autoFrame.Visible = false
end)

----------------------------------------------------------
-- MAIN BUTTONS
----------------------------------------------------------
local function makeButton(text, y, callback)
    local btn = Instance.new("TextButton", mainPanel)
    btn.Size = UDim2.new(1,-40,0,50)
    btn.Position = UDim2.new(0,20,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

    btn.MouseButton1Click:Connect(callback)
end

-- ServerHop
local function serverHop()
    local PlaceId = tostring(game.PlaceId)
    local JobId = tostring(game.JobId)

    local function fetch(cursor)
        local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        if cursor then url = url .. "&cursor="..HttpService:UrlEncode(cursor) end

        local ok, body = pcall(function() return game:HttpGet(url) end)
        if not ok then return end

        local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
        if ok2 then return data end
    end

    local servers = {}
    local cursor = nil

    for _ = 1,5 do
        local data = fetch(cursor)
        if not data then break end

        for _,srv in ipairs(data.data) do
            if srv.id ~= JobId and srv.playing == srv.maxPlayers-1 then
                table.insert(servers, srv.id)
            end
        end

        cursor = data.nextPageCursor
        if not cursor then break end
    end

    if #servers == 0 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
        return
    end

    TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], LocalPlayer)
end

-- ESP
local function clearESP()
    for _,set in pairs(espObjects) do
        if set.highlight then set.highlight:Destroy() end
    end
    espObjects = {}
end

local function applyESP()
    clearESP()

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = Instance.new("Highlight")
            hl.Adornee = plr.Character
            hl.FillTransparency = 0.5
            hl.FillColor = Color3.fromRGB(255,0,0)
            hl.OutlineColor = Color3.fromRGB(255,0,0)
            hl.Parent = plr.Character

            espObjects[plr] = {highlight = hl}
        end
    end
end

makeButton("Infinite Jump", 70, function()
    toggles.infiniteJump = not toggles.infiniteJump
end)

makeButton("Auto Floor", 140, function()
    autoFrame.Visible = true
end)

makeButton("ESP Players", 210, function()
    toggles.esp = not toggles.esp
    if toggles.esp then applyESP() else clearESP() end
end)

makeButton("Server Hop", 280, function()
    serverHop()
end)

----------------------------------------------------------
-- CHARACTER TRACKING
----------------------------------------------------------
local function onCharacterAdded(char)
    currentHumanoid = char:WaitForChild("Humanoid")
    currentRoot = char:WaitForChild("HumanoidRootPart")
end

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

----------------------------------------------------------
-- INPUT HANDLER
----------------------------------------------------------
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

----------------------------------------------------------
-- MAIN LOOP
----------------------------------------------------------
local lastESPState = false

RunService.RenderStepped:Connect(function()

    -- Infinite Jump
    if toggles.infiniteJump and jumpPressed and currentRoot then
        currentRoot.Velocity = Vector3.new(
            currentRoot.Velocity.X,
            50,
            currentRoot.Velocity.Z
        )
    end

    -- Auto Floor
    if toggles.autoFloor and currentRoot and currentHumanoid then
        if not activeBlock or not activeBlock.Parent then
            activeBlock = Instance.new("Part")
            activeBlock.Size = PLATFORM_SIZE
            activeBlock.CanCollide = true
            activeBlock.Anchored = true
            activeBlock.Material = Enum.Material.Neon
            activeBlock.Color = PLATFORM_COLOR
            activeBlock.Parent = Workspace
        end

        activeBlock.Position = currentRoot.Position - Vector3.new(
            0,
            currentHumanoid.HipHeight + activeBlock.Size.Y/2,
            0
        )
    elseif activeBlock then
        activeBlock:Destroy()
        activeBlock = nil
    end

    -- ESP auto update
    if toggles.esp ~= lastESPState then
        lastESPState = toggles.esp
        if toggles.esp then applyESP() else clearESP() end
    end
end)
