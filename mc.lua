-- ======================================================
-- Key GUI
-- ======================================================
local LINKVERTISE_LINK = "https://linkvertise.com/1443607/JNXqZHX147qx?o=sharing"
local CORRECT_KEY = "10ko57cl69"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local function keyGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeyLinkGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 400, 0, 220)
    frame.Position = UDim2.new(0.5, -200, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,20)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,50)
    title.Position = UDim2.new(0,0,0,0)
    title.Text = "NebulaHub Key System"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.BackgroundTransparency = 1

    local linkBtn = Instance.new("TextButton", frame)
    linkBtn.Size = UDim2.new(0.8,0,0,50)
    linkBtn.Position = UDim2.new(0.1,0,0.3,0)
    linkBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    linkBtn.TextColor3 = Color3.new(1,1,1)
    linkBtn.Font = Enum.Font.GothamBold
    linkBtn.TextScaled = true
    linkBtn.Text = "Copy Link"
    local linkCorner = Instance.new("UICorner", linkBtn)
    linkCorner.CornerRadius = UDim.new(0,12)

    -- Hover effect
    linkBtn.MouseEnter:Connect(function()
        TweenService:Create(linkBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 220, 255)}):Play()
    end)
    linkBtn.MouseLeave:Connect(function()
        TweenService:Create(linkBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
    end)

    linkBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(LINKVERTISE_LINK) end
        linkBtn.Text = "Copied!"
        task.wait(1)
        linkBtn.Text = "Copy Link"
    end)

    local textbox = Instance.new("TextBox", frame)
    textbox.Size = UDim2.new(0.8,0,0,50)
    textbox.Position = UDim2.new(0.1,0,0.55,0)
    textbox.PlaceholderText = "Enter key here"
    textbox.BackgroundColor3 = Color3.fromRGB(40,40,50)
    textbox.TextColor3 = Color3.new(1,1,1)
    textbox.Font = Enum.Font.Gotham
    textbox.TextScaled = true
    local boxCorner = Instance.new("UICorner", textbox)
    boxCorner.CornerRadius = UDim.new(0,12)

    local submitBtn = Instance.new("TextButton", frame)
    submitBtn.Size = UDim2.new(0.6,0,0,45)
    submitBtn.Position = UDim2.new(0.2,0,0.8,0)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    submitBtn.TextColor3 = Color3.new(1,1,1)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextScaled = true
    submitBtn.Text = "Submit"
    local submitCorner = Instance.new("UICorner", submitBtn)
    submitCorner.CornerRadius = UDim.new(0,12)

    local success = false
    submitBtn.MouseButton1Click:Connect(function()
        if textbox.Text == CORRECT_KEY then
            success = true
            TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            task.wait(0.5)
            screenGui:Destroy()
        else
            textbox.Text = ""
            textbox.PlaceholderText = "Incorrect key!"
            -- Shake animation
            for i = 1, 3 do
                TweenService:Create(frame, TweenInfo.new(0.05), {Position = frame.Position + UDim2.new(0.02,0,0,0)}):Play()
                task.wait(0.05)
                TweenService:Create(frame, TweenInfo.new(0.05), {Position = frame.Position - UDim2.new(0.02,0,0,0)}):Play()
                task.wait(0.05)
            end
        end
    end)

    repeat task.wait() until success
end

keyGui()

-- ======================================================
-- NebulaHub Main Script
-- ======================================================
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Double load prevention
if _G.NEBULAHUB_LOADED then
    warn("[NebulaHub] Már fut egy példány. Kilépés.")
    return
end
_G.NEBULAHUB_LOADED = true

-- GUI cleanup
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local old = pg:FindFirstChild("NebulaHub_GUI")
        if old then old:Destroy() end
    end
end)

-- ======================================================
-- Variables
-- ======================================================
local toggles = { infiniteJump = false, autoFloor = false, esp = false }
local currentRoot, currentHumanoid, activeBlock = nil, nil, nil
local jumpPressed = false
local espObjects = {}
local PLATFORM_SIZE = Vector3.new(6,0.2,6)
local PLATFORM_COLOR = Color3.fromRGB(200,150,255)
local autoFrame, toggleBtn

-- ======================================================
-- ServerHop Function
-- ======================================================
local function serverHop()
    print("[NebulaHub] Precise ServerHop indítva...")
    local PlaceId, JobId = tostring(game.PlaceId), tostring(game.JobId)
    local function fetchPage(cursor)
        local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        if cursor then url = url .. "&cursor=" .. HttpService:UrlEncode(cursor) end
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if not ok or not body then return nil end
        local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok2 or not data or not data.data then return nil end
        return data
    end

    local candidates = {}
    local cursor = nil
    for page = 1, 5 do
        local data = fetchPage(cursor)
        if not data then break end
        for _, srv in ipairs(data.data) do
            if srv.id and tostring(srv.id) ~= JobId then
                local playing = tonumber(srv.playing) or 0
                local maxPlayers = tonumber(srv.maxPlayers) or 0
                if maxPlayers > 0 and playing == maxPlayers - 1 then
                    table.insert(candidates, srv.id)
                end
            end
        end
        cursor = data.nextPageCursor
        if not cursor then break end
        task.wait(0.05)
    end
    if #candidates == 0 then
        warn("[NebulaHub] Nem találtam majdnem full szervert. Fallback teleport...")
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        return
    end
    local target = candidates[math.random(1, #candidates)]
    pcall(function()
        TeleportService:TeleportToPlaceInstance(tonumber(PlaceId), target, LocalPlayer)
    end)
end

-- ======================================================
-- GUI Creation
-- ======================================================
local function createGui()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NebulaHub_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = pg

    local smallBtn = Instance.new("TextButton", screenGui)
    smallBtn.Size = UDim2.new(0, 40, 0, 40)
    smallBtn.Position = UDim2.new(0, 10, 0, 100)
    smallBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
    smallBtn.Text = "NH"
    smallBtn.BorderSizePixel = 0
    smallBtn.ZIndex = 10
    Instance.new("UICorner", smallBtn).CornerRadius = UDim.new(0, 20)
    smallBtn.Draggable = true

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 260, 0, 400)
    mainFrame.Position = UDim2.new(0, 50, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = false
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,60)
    title.Text = "NebulaHub"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.BackgroundTransparency = 1

    -- ======================================================
    -- AutoFloor Popup (Draggable)
    -- ======================================================
    autoFrame = Instance.new("Frame", screenGui)
    autoFrame.Size = UDim2.new(0, 220, 0, 150)
    autoFrame.Position = UDim2.new(0.5, -110, 0.5, -75)
    autoFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
    autoFrame.BorderSizePixel = 0
    autoFrame.Visible = false
    autoFrame.Active = true
    autoFrame.Draggable = true
    Instance.new("UICorner", autoFrame).CornerRadius = UDim.new(0,12)

    local autoTitle = Instance.new("TextLabel", autoFrame)
    autoTitle.Size = UDim2.new(1,0,0,40)
    autoTitle.Text = "Auto Floor Settings"
    autoTitle.TextColor3 = Color3.fromRGB(0,200,255)
    autoTitle.Font = Enum.Font.GothamBold
    autoTitle.TextScaled = true
    autoTitle.BackgroundTransparency = 1

    toggleBtn = Instance.new("TextButton", autoFrame)
    toggleBtn.Size = UDim2.new(0.8,0,0,40)
    toggleBtn.Position = UDim2.new(0.1,0,0.45,0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    toggleBtn.Text = "Enable Auto Floor: OFF"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextScaled = true
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,10)

    local function updateAutoButton()
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = toggles.autoFloor and Color3.fromRGB(0,170,90) or Color3.fromRGB(40,40,50)
        }):Play()
        toggleBtn.Text = "Enable Auto Floor: " .. (toggles.autoFloor and "ON" or "OFF")
    end

    toggleBtn.MouseButton1Click:Connect(function()
        toggles.autoFloor = not toggles.autoFloor
        updateAutoButton()
    end)

    local closeBtn = Instance.new("TextButton", autoFrame)
    closeBtn.Size = UDim2.new(0.3,0,0,30)
    closeBtn.Position = UDim2.new(0.35,0,0.8,0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255,60,60)
    closeBtn.Text = "Close"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextScaled = true
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)
    closeBtn.MouseButton1Click:Connect(function()
        autoFrame.Visible = false
    end)

    -- ======================================================
    -- Button Factory
    -- ======================================================
    local function makeButton(text, y, key, callback)
        local btn = Instance.new("TextButton", mainFrame)
        btn.Size = UDim2.new(1,-40,0,50)
        btn.Position = UDim2.new(0,20,0,y)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextScaled = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        if key and toggles[key] then btn.BackgroundColor3 = Color3.fromRGB(0,170,90) end
        btn.MouseButton1Click:Connect(function()
            if text == "Auto Floor" then
                autoFrame.Visible = true
            elseif key then
                toggles[key] = not toggles[key]
                TweenService:Create(btn, TweenInfo.new(0.3), {
                    BackgroundColor3 = toggles[key] and Color3.fromRGB(0,170,90) or Color3.fromRGB(40,40,50)
                }):Play()
            elseif callback then
                callback()
            end
        end)
    end

    makeButton("Infinite Jump", 70, "infiniteJump")
    makeButton("Auto Floor", 140, "autoFloor")
    makeButton("ESP Players", 210, "esp")
    makeButton("Server Hop", 280, nil, serverHop)

    smallBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
end

createGui()

-- ======================================================
-- Character Logic
-- ======================================================
local function onCharacterAdded(char)
    currentHumanoid = char:WaitForChild("Humanoid")
    currentRoot = char:WaitForChild("HumanoidRootPart")
end
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space then
        jumpPressed = true
    elseif input.KeyCode == Enum.KeyCode.G then
        toggles.autoFloor = not toggles.autoFloor
        if toggleBtn then
            TweenService:Create(toggleBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = toggles.autoFloor and Color3.fromRGB(0,170,90) or Color3.fromRGB(40,40,50)
            }):Play()
            toggleBtn.Text = "Enable Auto Floor: " .. (toggles.autoFloor and "ON" or "OFF")
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        jumpPressed = false
    end
end)

-- ======================================================
-- ESP Logic
-- ======================================================
local function clearESP()
    for _, stuff in pairs(espObjects) do
        if stuff.highlight then pcall(function() stuff.highlight:Destroy() end) end
    end
    espObjects = {}
end

local function applyESP()
    clearESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = player.Character
            highlight.FillTransparency = 0.5
            highlight.FillColor = Color3.fromRGB(255,0,0)
            highlight.OutlineColor = Color3.fromRGB(255,0,0)
            highlight.Parent = player.Character
            espObjects[player] = {highlight = highlight}
        end
    end
end

-- ======================================================
-- Update Loop
-- ======================================================
RunService.RenderStepped:Connect(function()
    if toggles.infiniteJump and jumpPressed and currentRoot then
        currentRoot.Velocity = Vector3.new(currentRoot.Velocity.X, 50, currentRoot.Velocity.Z)
    end

    if toggles.autoFloor and currentRoot then
        if not activeBlock or not activeBlock.Parent then
            activeBlock = Instance.new("Part")
            activeBlock.Size = PLATFORM_SIZE
            activeBlock.Anchored = true
            activeBlock.CanCollide = true
            activeBlock.Color = PLATFORM_COLOR
            activeBlock.Material = Enum.Material.Neon
            activeBlock.Parent = Workspace
        end
        local hum = currentRoot.Parent:FindFirstChildOfClass("Humanoid")
        if hum then
            activeBlock.Position = currentRoot.Position - Vector3.new(0, hum.HipHeight + activeBlock.Size.Y/2, 0)
        end
    elseif activeBlock then
        activeBlock:Destroy()
        activeBlock = nil
    end

    if toggles.esp then
        applyESP()
    else
        clearESP()
    end
end)
