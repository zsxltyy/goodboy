-- ======================================================
-- 🍔 McDonald’s Script by zsxltyy
-- Infinite Jump + Auto Floor + ESP + ServerHop + Auto Reload
-- ======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- 🌐 Link, ahonnan a script betölti magát
local SCRIPT_URL = "https://raw.githubusercontent.com/zsxltyy/goodboy/main/mc.lua"

-- ======================================================
-- Auto Reload (újraindul, ha szervert váltasz)
-- ======================================================
local teleportData = TeleportService:GetLocalPlayerTeleportData()
if teleportData and teleportData.McDonaldsAutoReload then
    loadstring(game:HttpGet(teleportData.McDonaldsAutoReload))()
    return
end

-- ======================================================
-- Prevent double load
-- ======================================================
if _G.MCDONALDS_LOADED then
    warn("[McDonald’s] Már fut egy példány. Kilépés.")
    return
end
_G.MCDONALDS_LOADED = true

-- Clean old GUI
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local old = pg:FindFirstChild("MCDONALDS_GUI")
        if old then old:Destroy() end
    end
end)

-- ======================================================
-- Állapotváltozók
-- ======================================================
local toggles = { infiniteJump = false, autoFloor = false, esp = false }
local currentRoot, currentHumanoid, activeBlock = nil, nil, nil
local jumpPressed = false
local espObjects = {}
local PLATFORM_SIZE = Vector3.new(6,0.2,6)
local PLATFORM_COLOR = Color3.fromRGB(255, 220, 120)
local walkSpeedValue = 16
local jumpPowerValue = 50

-- ======================================================
-- SERVERHOP (új szerverre lép, és újraindítja a scriptet)
-- ======================================================
local function serverHop()
    print("[McDonald’s] 🍟 ServerHop indítva...")
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

    TeleportService:SetTeleportData({
        McDonaldsAutoReload = SCRIPT_URL
    })

    if #candidates == 0 then
        warn("[McDonald’s] ⚠️ Nem találtam majdnem tele szervert. Fallback teleport...")
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        return
    end

    local target = candidates[math.random(1, #candidates)]
    pcall(function()
        TeleportService:TeleportToPlaceInstance(tonumber(PlaceId), target, LocalPlayer)
    end)
end

-- ======================================================
-- GUI létrehozása (emojikkal 🎨)
-- ======================================================
local function createGui()
    local pg = LocalPlayer:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MCDONALDS_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = pg

    -- Kis piros gomb 🍔
    local smallBtn = Instance.new("TextButton", screenGui)
    smallBtn.Size = UDim2.new(0, 40, 0, 40)
    smallBtn.Position = UDim2.new(0, 10, 0, 100)
    smallBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
    smallBtn.Text = "🍔"
    smallBtn.TextScaled = true
    smallBtn.BorderSizePixel = 0
    smallBtn.ZIndex = 10
    Instance.new("UICorner", smallBtn).CornerRadius = UDim.new(0, 20)
    smallBtn.Draggable = true

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 260, 0, 400)
    mainFrame.Position = UDim2.new(0, 60, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = false
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,60)
    title.Text = "🍟 McDonald’s Menu 🍔"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.BackgroundTransparency = 1

    -- Gombkészítő funkció
    local function makeButton(text, y, key, callback)
        local btn = Instance.new("TextButton", mainFrame)
        btn.Size = UDim2.new(1, -40, 0, 50)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(45,45,55)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextScaled = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        if key and toggles[key] then btn.BackgroundColor3 = Color3.fromRGB(0,170,90) end

        btn.MouseButton1Click:Connect(function()
            if key then
                toggles[key] = not toggles[key]
                TweenService:Create(btn, TweenInfo.new(0.3),
                    { BackgroundColor3 = toggles[key] and Color3.fromRGB(0,170,90)
                    or Color3.fromRGB(45,45,55) }):Play()
            elseif callback then
                callback()
            end
        end)
        return btn
    end

    makeButton("🦘 Infinite Jump", 70, "infiniteJump")
    makeButton("🧱 Auto Floor", 140, "autoFloor")
    makeButton("🧍‍♂️ ESP Players", 210, "esp")
    makeButton("🌐 Server Hop", 280, nil, serverHop)

    smallBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
end
createGui()

-- ======================================================
-- Karakter logika
-- ======================================================
local function onCharacterAdded(char)
    currentHumanoid = char:WaitForChild("Humanoid")
    currentRoot = char:WaitForChild("HumanoidRootPart")
    if currentHumanoid then
        currentHumanoid.WalkSpeed = walkSpeedValue
        currentHumanoid.JumpPower = jumpPowerValue
    end
    if activeBlock then pcall(function() activeBlock:Destroy() end) activeBlock = nil end
end
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space then jumpPressed = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then jumpPressed = false end
end)

-- ======================================================
-- ESP rendszer
-- ======================================================
local function clearESP()
    for _, stuff in pairs(espObjects) do
        if stuff.highlight then pcall(function() stuff.highlight:Destroy() end) end
        if stuff.billboard then pcall(function() stuff.billboard:Destroy() end) end
    end
    espObjects = {}
end

local function applyESP()
    clearESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local char = player.Character
            local highlight = Instance.new("Highlight")
            highlight.Adornee = char
            highlight.FillTransparency = 0.6
            highlight.OutlineColor = Color3.fromRGB(255,255,0)
            highlight.FillColor = Color3.fromRGB(0,170,255)
            highlight.Parent = char

            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Adornee = char:FindFirstChild("Head")
            billboard.Parent = char

            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1,0,1,0)
            label.BackgroundTransparency = 1
            label.Text = "👀 " .. player.Name
            label.TextColor3 = Color3.new(1,1,1)
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true

            espObjects[player] = {highlight = highlight, billboard = billboard}
        end
    end
end

-- ======================================================
-- Update Loop
-- ======================================================
RunService.RenderStepped:Connect(function()
    if toggles.infiniteJump and jumpPressed and currentHumanoid and currentRoot then
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
        pcall(function() activeBlock:Destroy() end)
        activeBlock = nil
    end

    if toggles.esp then
        applyESP()
    else
        clearESP()
    end
end)

print("[McDonald’s 🍔] Loaded: Infinite Jump, AutoFloor, ESP, ServerHop + AutoReload")
