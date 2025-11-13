-- ======================================================
-- Key GUI + Key Cache
-- ======================================================
local LINKVERTISE_LINK = "https://linkvertise.com/1443607/JNXqZHX147qx?o=sharing"
local CORRECT_KEY = "10ko57cl69"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Local cache to remember key entry
if not _G.NEBULAHUB_KEY_ENTERED then
    _G.NEBULAHUB_KEY_ENTERED = false
end

local function keyGui()
    if _G.NEBULAHUB_KEY_ENTERED then return end

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
            _G.NEBULAHUB_KEY_ENTERED = true
            TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            task.wait(0.5)
            screenGui:Destroy()
        else
            textbox.Text = ""
            textbox.PlaceholderText = "Incorrect key!"
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

-- Show GUI if key not entered
keyGui()

-- ======================================================
-- Load main script
-- ======================================================
loadstring(game:HttpGet("https://raw.githubusercontent.com/zsxltyy/goodboy/main/mc.lua"))()
