-- ======================================================
-- 🍔 McDonald’s Script (Stable AutoReload + Simple ServerHop)
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
-- 🌐 Auto reload teleport után
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
-- Alap beállítások
-- ======================================================
local toggles = { infiniteJump = false, autoFloor = false, esp = false }
local currentRoot, currentHumanoid, activeBlock = nil, nil, nil
local jumpPressed = false
local espObjects = {}
local PLATFORM_SIZE = Vector3.new(6,0.2,6)
local PLATFORM_COLOR = Color3.fromRGB(255,220,120)

-- ======================================================
-- 🌀 EGYSZERŰ SERVERHOP (minden executorral működik)
-- ======================================================
local function simpleServerHop()
    print("[McDonald’s] 🌐 Random szerver keresése...")
    local servers = {}
    local PlaceId = game.PlaceId
    local function listServers(cursor)
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then url = url .. "&cursor=" .. cursor end
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and result and result.data then
            for _, srv in pairs(result.data) do
                if srv.playing < srv.maxPlayers then
                    table.insert(servers, srv.id)
                end
            end
            return result.nextPageCursor
        end
        return nil
    end

    local cursor = nil
    for i = 1, 3 do
        cursor = listServers(cursor)
        if not cursor then break end
        task.wait(0.2)
    end

    if #servers == 0 then
        warn("[McDonald’s] ⚠️ Nincs elérhető szerver, újracsatlakozás...")
        TeleportService:SetTeleportData({ ReloadScript = game:HttpGet("https://raw.githubusercontent.com/zsxltyy/goodboy/main/mc.lua") })
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
        return
    end

    local randomServer = servers[math.random(1, #servers)]
    TeleportService:SetTeleportData({ ReloadScript = game:HttpGet("https://raw.githubusercontent.com/zsxltyy/goodboy/main/mc.lua") })
    TeleportService:TeleportToPlaceInstance(PlaceId, randomServer, LocalPlayer)
end

-- ======================================================
-- GUI létrehozás (🍟 Emojikkal)
-- ======================================================
local function createGui()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui", pg)
    gui.Name = "MCDONALDS_GUI"
    gui.ResetOnSpawn = false

    local toggle = Instance.new("TextButton", gui)
    toggle.Size = UDim2.new(0, 40, 0, 40)
    toggle.Position = UDim2.new(0, 10, 0, 100)
    toggle.Text = "🍔"
    toggle.TextScaled = true
    toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 20)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 260, 0, 400)
    frame.Position = UDim2.new(0, 60, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.Visible = false
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Text = "🍟 McDonald’s Menu"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true

    local function makeButton(text, y, key, callback)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(1, -40, 0, 50)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextScaled = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
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
    makeButton("🌐 Server Hop", 280, nil, simpleServerHop)

    toggle.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)
end
createGui()

-- ======================================================
-- Infinite Jump, AutoFloor, ESP logika
-- ======================================================
local function onCharacterAdded(char)
    currentHumanoid = char:WaitForChild("Humanoid")
    currentRoot = char:WaitForChild("HumanoidRootPart")
end
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Space then jumpPressed = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space then jumpPressed = false end
end)

local function clearESP()
    for _,v in pairs(espObjects) do
        pcall(function() if v.highlight then v.highlight:Destroy() end end)
        pcall(function() if v.billboard then v.billboard:Destroy() end end)
    end
    espObjects = {}
end

local function applyESP()
    clearESP()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local c = p.Character
            local h = Instance.new("Highlight")
            h.Adornee = c
            h.FillTransparency = 0.6
            h.OutlineColor = Color3.fromRGB(255,255,0)
            h.FillColor = Color3.fromRGB(0,170,255)
            h.Parent = c

            local b = Instance.new("BillboardGui")
            b.Size = UDim2.new(0,200,0,50)
            b.StudsOffset = Vector3.new(0,3,0)
            b.AlwaysOnTop = true
            b.Adornee = c:FindFirstChild("Head")
            b.Parent = c

            local t = Instance.new("TextLabel", b)
            t.Size = UDim2.new(1,0,1,0)
            t.BackgroundTransparency = 1
            t.Text = "👀 " .. p.Name
            t.TextColor3 = Color3.new(1,1,1)
            t.Font = Enum.Font.GothamBold
            t.TextScaled = true

            espObjects[p] = {highlight = h, billboard = b}
        end
    end
end

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
        activeBlock.Position = currentRoot.Position - Vector3.new(0, 4, 0)
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

print("[🍟 McDonald’s] Betöltve – minden funkció aktív ✅")
