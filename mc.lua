-- ======================================================
-- 🍔 McDonald’s Script (Stable AutoReload + ServerHop)
-- ======================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ======================================================
-- 🌐 Automatikus újratöltés teleport után
-- ======================================================
local teleportData = TeleportService:GetLocalPlayerTeleportData()
if teleportData and teleportData.ReloadScript then
    loadstring(teleportData.ReloadScript)()
    return
end

-- ======================================================
-- Prevent double load
-- ======================================================
if _G.MCDONALDS_RUNNING then
    warn("[McDonald’s] Már fut egy példány.")
    return
end
_G.MCDONALDS_RUNNING = true

-- ======================================================
-- Alap állapotok
-- ======================================================
local toggles = { infiniteJump = false, autoFloor = false, esp = false }
local currentRoot, currentHumanoid, activeBlock = nil, nil, nil
local jumpPressed = false
local espObjects = {}
local PLATFORM_SIZE = Vector3.new(6,0.2,6)
local PLATFORM_COLOR = Color3.fromRGB(255,220,120)
local walkSpeedValue = 16
local jumpPowerValue = 50

-- ======================================================
-- SERVERHOP ✅
-- ======================================================
local function serverHop()
    print("[McDonald’s] 🌐 ServerHop indítva...")
    local PlaceId, JobId = tostring(game.PlaceId), tostring(game.JobId)

    local function getServers(cursor)
        local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        if cursor then url = url .. "&cursor="..HttpService:UrlEncode(cursor) end
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if not ok then return nil end
        local data = HttpService:JSONDecode(res)
        return data
    end

    local servers = {}
    local cursor = nil
    for i=1,5 do
        local data = getServers(cursor)
        if not data then break end
        for _,srv in pairs(data.data) do
            if srv.id ~= JobId and srv.playing < srv.maxPlayers then
                table.insert(servers, srv.id)
            end
        end
        cursor = data.nextPageCursor
        if not cursor then break end
    end

    if #servers == 0 then
        warn("[McDonald’s] ⚠️ Nem találtam üres szervert, újracsatlakozás...")
        TeleportService:SetTeleportData({ ReloadScript = game:HttpGet("https://raw.githubusercontent.com/zsxltyy/goodboy/main/mc.lua") })
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
        return
    end

    local target = servers[math.random(1, #servers)]
    TeleportService:SetTeleportData({ ReloadScript = game:HttpGet("https://raw.githubusercontent.com/zsxltyy/goodboy/main/mc.lua") })
    TeleportService:TeleportToPlaceInstance(tonumber(PlaceId), target, LocalPlayer)
end

-- ======================================================
-- GUI létrehozása (🍟 Emojikkal)
-- ======================================================
local function createGui()
    local pg = LocalPlayer:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MCDONALDS_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = pg

    local toggleBtn = Instance.new("TextButton", screenGui)
    toggleBtn.Size = UDim2.new(0,40,0,40)
    toggleBtn.Position = UDim2.new(0,10,0,100)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
    toggleBtn.Text = "🍔"
    toggleBtn.TextScaled = true
    toggleBtn.BorderSizePixel = 0
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,20)
    toggleBtn.Draggable = true

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0,260,0,400)
    frame.Position = UDim2.new(0,60,0.5,-200)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,35)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,60)
    title.Text = "🍟 McDonald's Menu"
    title.TextColor3 = Color3.fromRGB(255,200,0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true

    local function makeButton(text, y, key, callback)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(1,-40,0,50)
        btn.Position = UDim2.new(0,20,0,y)
        btn.BackgroundColor3 = Color3.fromRGB(45,45,55)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextScaled = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        btn.MouseButton1Click:Connect(function()
            if key then
                toggles[key] = not toggles[key]
                TweenService:Create(btn, TweenInfo.new(0.3), {
                    BackgroundColor3 = toggles[key] and Color3.fromRGB(0,170,90) or Color3.fromRGB(45,45,55)
                }):Play()
            elseif callback then
                callback()
            end
        end)
    end

    makeButton("🦘 Infinite Jump", 70, "infiniteJump")
    makeButton("🧱 Auto Floor", 140, "autoFloor")
    makeButton("👀 ESP Players", 210, "esp")
    makeButton("🌐 Server Hop", 280, nil, serverHop)

    toggleBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
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
    for _,v in pairs(espObjects) do
        pcall(function() if v.highlight then v.highlight:Destroy() end end)
        pcall(function() if v.billboard then v.billboard:Destroy() end end)
    end
    espObjects = {}
end

local function applyESP()
    clearESP()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local char = plr.Character
            local h = Instance.new("Highlight")
            h.Adornee = char
            h.FillTransparency = 0.6
            h.OutlineColor = Color3.fromRGB(255,255,0)
            h.FillColor = Color3.fromRGB(0,170,255)
            h.Parent = char

            local b = Instance.new("BillboardGui")
            b.Size = UDim2.new(0,200,0,50)
            b.StudsOffset = Vector3.new(0,3,0)
            b.AlwaysOnTop = true
            b.Adornee = char:FindFirstChild("Head")
            b.Parent = char

            local t = Instance.new("TextLabel", b)
            t.Size = UDim2.new(1,0,1,0)
            t.BackgroundTransparency = 1
            t.Text = "👀 " .. plr.Name
            t.TextColor3 = Color3.new(1,1,1)
            t.Font = Enum.Font.GothamBold
            t.TextScaled = true

            espObjects[plr] = {highlight = h, billboard = b}
        end
    end
end

-- ======================================================
-- Update ciklus
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
        pcall(function() activeBlock:Destroy() end)
        activeBlock = nil
    end

    if toggles.esp then
        applyESP()
    else
        clearESP()
    end
end)

print("[🍔 McDonald’s] Betöltve: Infinite Jump, AutoFloor, ESP, ServerHop + AutoReload ✅")
