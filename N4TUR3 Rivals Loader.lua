-- [[ N4TUR3 HUB | RIVALS EDITION V1 - STABLE ]] --
local util = require(game:GetService("ReplicatedStorage").Modules.Utility)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- [[ SETTINGS ]] --
local Settings = {
    SilentAim = true,
    TargetPart = "Head",
    HitChance = 100,
    WalkSpeed = 0, 
    FOV = 150,
    MaxDist = 200,
    ESP = false,
    ESPNames = false,
    ESPTracers = false,
    Running = true,
    MenuVisible = true,
    Discord = "https://discord.gg/bYJMudYHuy",
    Webhook = "https://discord.com/api/webhooks/1494066414628241550/KUQ5RgDvGuIb-NWIJBPw3eo7N7f0DKEESo4NEgE3m4pA45fgNIXzWr-eJ5LL7w_tMnnW"
}

local isOwner = (LP.UserId == 10814224460 or LP.Name == "KRZXYRIVAL" or LP.Name == "007n7_frendswithadam" or LP.UserId == 10485671512 or LP.Name == "Adam_OnGuilded31")
local UI_Elements = {Toggles = {}, Sliders = {}}
local ESP_Objects = {} -- Track drawings for clean unload

-- [[ UI REFRESH SYSTEM ]] --
local function RefreshUI()
    for prop, btn in pairs(UI_Elements.Toggles) do
        local state = Settings[prop]
        btn.Text = btn.Name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 0, 150) or Color3.fromRGB(30, 30, 30)
    end
    for prop, data in pairs(UI_Elements.Sliders) do
        local val = Settings[prop]
        data.Label.Text = data.Name .. ": " .. val
        local perc = math.clamp((val - data.Min) / (data.Max - data.Min), 0, 1)
        data.Fill.Size = UDim2.new(perc, 0, 1, 0)
    end
end

-- [[ LOG SYSTEM ]] --
local function LogUser()
    pcall(function()
        local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if request then
            local executorName = (identifyexecutor and identifyexecutor()) or "Unknown"
            request({
                Url = Settings.Webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    ["embeds"] = {{
                        ["title"] = isOwner and "👑 **OWNER LOGIN | N4TUR3 HUB**" or "🚀 **Execution | N4TUR3 Hub**",
                        ["description"] = "🎯 **(Rivals)** Edition Active.",
                        ["color"] = isOwner and 0xFFD700 or 0x640096,
                        ["fields"] = {
                            {["name"] = "👤 User", ["value"] = "``" .. (isOwner and "⭐ OWNER: " or "") .. LP.Name .. "``", ["inline"] = true},
                            {["name"] = "🆔 ID", ["value"] = "``" .. LP.UserId .. "``", ["inline"] = true},
                            {["name"] = "🎮 Game", ["value"] = "``Rivals``", ["inline"] = false},
                            {["name"] = "🔗 Links", ["value"] = "[Profile](https://www.roblox.com/users/" .. LP.UserId .. "/profile)", ["inline"] = false}
                        },
                        ["footer"] = {["text"] = "by N4TUR3 Hub • Global Tracking"}
                    }}
                })
            })
        end
    end)
end
LogUser()

-- [[ LOADER ]] --
local function RunLoadingSequence()
    local loaderGui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
    loaderGui.IgnoreGuiInset = true
    local back = Instance.new("Frame", loaderGui)
    back.Size = UDim2.new(1, 0, 1, 100); back.Position = UDim2.new(0, 0, 0, -50); back.BackgroundColor3 = Color3.fromRGB(10, 10, 10); back.BackgroundTransparency = 0.1
    local main = Instance.new("Frame", back)
    main.Size = UDim2.new(0, 320, 0, 180); main.Position = UDim2.new(0.5, -160, 0.5, -90); main.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", main)
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 45); title.Position = UDim2.new(0, 0, 0, 15); title.Text = isOwner and "👑 OWNER | N4TUR3 HUB" or "🌀 N4TUR3 HUB"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.TextSize = 22; title.BackgroundTransparency = 1
    local discLabel = Instance.new("TextLabel", main)
    discLabel.Size = UDim2.new(1, 0, 0, 20); discLabel.Position = UDim2.new(0, 0, 0, 45); discLabel.Text = "discord.gg/bYJMudYHuy"; discLabel.TextColor3 = Color3.fromRGB(180, 100, 255); discLabel.Font = Enum.Font.GothamSemibold; discLabel.TextSize = 14; discLabel.BackgroundTransparency = 1
    local barBack = Instance.new("Frame", main)
    barBack.Size = UDim2.new(0.8, 0, 0, 10); barBack.Position = UDim2.new(0.1, 0, 0.7, 0); barBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", barBack)
    local fill = Instance.new("Frame", barBack); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(120, 0, 200); Instance.new("UICorner", fill)
    local status = Instance.new("TextLabel", main)
    status.Size = UDim2.new(1, 0, 0, 20); status.Position = UDim2.new(0, 0, 0.85, 0); status.Text = "Initializing..."; status.TextColor3 = Color3.fromRGB(200, 200, 200); status.Font = Enum.Font.Gotham; status.TextSize = 14; status.BackgroundTransparency = 1

    task.wait(1.0); fill:TweenSize(UDim2.new(0.4, 0, 1, 0), "Out", "Quad", 1.2); status.Text = "Bypassing Security..."; task.wait(1.5)
    if not isOwner and setclipboard then setclipboard(Settings.Discord); StarterGui:SetCore("SendNotification", {Title = "🌀 N4TUR3 Hub", Text = "Discord link copied!", Duration = 5}) end
    fill:TweenSize(UDim2.new(0.7, 0, 1, 0), "Out", "Quad", 1.2); status.Text = "Finalizing Injection..."; task.wait(1.5)
    fill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", 0.8); task.wait(1.0); loaderGui:Destroy()
end
RunLoadingSequence()

-- [[ TARGETING ]] --
local function getTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestDist = nil, Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP or not p.Character then continue end
        local part = p.Character:FindFirstChild(Settings.TargetPart)
        if part and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local sp, vis = Camera:WorldToViewportPoint(part.Position)
            if vis then
                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if d < bestDist then bestDist = d; best = part end
            end
        end
    end
    return best
end

local origRaycast = util.Raycast
util.Raycast = function(self, origin, direction, distance, ...)
    if Settings.Running and Settings.SilentAim and math.random(1, 100) <= Settings.HitChance then
        local target = getTarget()
        if target then return origRaycast(self, origin, target.Position, distance, ...) end
    end
    return origRaycast(self, origin, direction, distance, ...)
end

RunService.RenderStepped:Connect(function()
    if Settings.Running and Settings.WalkSpeed > 0 then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and hum and hum.MoveDirection.Magnitude > 0 then
            char:TranslateBy(hum.MoveDirection * (Settings.WalkSpeed / 400))
        end
    end
end)

-- [[ ESP SYSTEM ]] --
local NeonColor = Color3.fromRGB(0, 255, 255)
local function CreateESP(p)
    local Box = Drawing.new("Square"); Box.Thickness = 1; Box.Filled = false
    local Name = Drawing.new("Text"); Name.Size = 14; Name.Center = true; Name.Outline = true
    local Tracer = Drawing.new("Line"); Tracer.Thickness = 1.5
    local HealthBar = Drawing.new("Line"); HealthBar.Thickness = 2 -- Health ESP
    
    table.insert(ESP_Objects, Box); table.insert(ESP_Objects, Name); table.insert(ESP_Objects, Tracer); table.insert(ESP_Objects, HealthBar)

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not Settings.Running or not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            Box.Visible, Name.Visible, Tracer.Visible, HealthBar.Visible = false, false, false, false
            if not Settings.Running then connection:Disconnect() end
            return
        end
        local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
        local hum = p.Character:FindFirstChildOfClass("Humanoid")

        if vis and hum and (Settings.ESP or Settings.ESPTracers) then
            local size = 2000 / pos.Z
            if Settings.ESP then
                Box.Size = Vector2.new(size, size * 1.5); Box.Position = Vector2.new(pos.X - Box.Size.X/2, pos.Y - Box.Size.Y/2); Box.Color = NeonColor; Box.Visible = true
                
                -- Health ESP Logic
                local healthPerc = hum.Health / hum.MaxHealth
                HealthBar.From = Vector2.new(Box.Position.X - 5, Box.Position.Y + Box.Size.Y)
                HealthBar.To = Vector2.new(Box.Position.X - 5, Box.Position.Y + Box.Size.Y - (Box.Size.Y * healthPerc))
                HealthBar.Color = Color3.fromHSV(healthPerc * 0.3, 1, 1) -- Green to Red
                HealthBar.Visible = true

                if Settings.ESPNames then Name.Text = p.Name; Name.Position = Vector2.new(pos.X, pos.Y - (size * 0.8) - 15); Name.Color = NeonColor; Name.Visible = true else Name.Visible = false end
            else Box.Visible, Name.Visible, HealthBar.Visible = false, false, false end
            if Settings.ESPTracers then Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); Tracer.To = Vector2.new(pos.X, pos.Y + (size*1.5)/2); Tracer.Color = NeonColor; Tracer.Visible = true else Tracer.Visible = false end
        else Box.Visible, Name.Visible, Tracer.Visible, HealthBar.Visible = false, false, false, false end
    end)
end
for _, v in pairs(Players:GetPlayers()) do if v ~= LP then CreateESP(v) end end
Players.PlayerAdded:Connect(CreateESP)

-- [[ UI BUILDER ]] --
local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 680); Main.Position = UDim2.new(0.05, 0, 0.1, 0); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true; Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45); Title.Text = " 🌀 CRXSHHY HUB | RIVALS "; Title.TextColor3 = Color3.new(1, 1, 1); Title.BackgroundColor3 = Color3.fromRGB(80, 0, 150); Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Instance.new("UICorner", Title)

local currentY = 55
local function AddToggle(text, prop)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, currentY); b.Text = text .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamSemibold; b.Name = text; Instance.new("UICorner", b)
    UI_Elements.Toggles[prop] = b; b.MouseButton1Click:Connect(function() Settings[prop] = not Settings[prop]; RefreshUI() end)
    currentY = currentY + 42
end

local TargetBtn = Instance.new("TextButton", Main)
TargetBtn.Size = UDim2.new(0.9, 0, 0, 35); TargetBtn.Position = UDim2.new(0.05, 0, 0, currentY); TargetBtn.Text = "🎯 Target: Head"; TargetBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 150); TargetBtn.TextColor3 = Color3.new(1, 1, 1); TargetBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", TargetBtn)
TargetBtn.MouseButton1Click:Connect(function()
    if Settings.TargetPart == "Head" then Settings.TargetPart = "Neck" elseif Settings.TargetPart == "Neck" then Settings.TargetPart = "LowerTorso" else Settings.TargetPart = "Head" end
    TargetBtn.Text = "🎯 Target: " .. (Settings.TargetPart == "LowerTorso" and "Pelvis" or Settings.TargetPart)
end)
currentY = currentY + 42

local function AddSlider(text, prop, min, max, default)
    local label = Instance.new("TextLabel", Main); label.Size = UDim2.new(1, 0, 0, 20); label.Position = UDim2.new(0, 0, 0, currentY); label.Text = text .. ": " .. default; label.TextColor3 = Color3.new(1, 1, 1); label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham
    local btn = Instance.new("TextButton", Main); btn.Size = UDim2.new(0.9, 0, 0, 6); btn.Position = UDim2.new(0.05, 0, 0, currentY + 22); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.Text = ""; Instance.new("UICorner", btn)
    local fill = Instance.new("Frame", btn); fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(180, 100, 255); Instance.new("UICorner", fill)
    UI_Elements.Sliders[prop] = {Label = label, Fill = fill, Min = min, Max = max, Name = text}
    btn.MouseButton1Down:Connect(function() local conn; conn = RunService.RenderStepped:Connect(function() if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() return end local perc = math.clamp((UserInputService:GetMouseLocation().X - btn.AbsolutePosition.X) / btn.AbsoluteSize.X, 0, 1); Settings[prop] = math.floor(min + (perc * (max - min))); RefreshUI() end) end)
    currentY = currentY + 50
end

AddToggle("Silent Aim", "SilentAim"); AddToggle("Full Box ESP", "ESP"); AddToggle("Show ESP Names", "ESPNames"); AddToggle("Feet Tracers", "ESPTracers")
AddSlider("Hit Chance %", "HitChance", 0, 100, 100); AddSlider("Speed Boost", "WalkSpeed", 0, 50, 0); AddSlider("FOV Size", "FOV", 10, 600, 150)

-- [[ CONFIG BUTTONS ]] --
local SaveBtn = Instance.new("TextButton", Main); SaveBtn.Size = UDim2.new(0.42, 0, 0, 35); SaveBtn.Position = UDim2.new(0.05, 0, 0, currentY + 10); SaveBtn.Text = "SAVE"; SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0); SaveBtn.TextColor3 = Color3.new(1, 1, 1); SaveBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", SaveBtn)
SaveBtn.MouseButton1Click:Connect(function() writefile("Rivals_Config.json", HttpService:JSONEncode(Settings)) end)

local LoadBtn = Instance.new("TextButton", Main); LoadBtn.Size = UDim2.new(0.42, 0, 0, 35); LoadBtn.Position = UDim2.new(0.53, 0, 0, currentY + 10); LoadBtn.Text = "LOAD"; LoadBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 120); LoadBtn.TextColor3 = Color3.new(1, 1, 1); LoadBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", LoadBtn)
LoadBtn.MouseButton1Click:Connect(function() if isfile("Rivals_Config.json") then local data = HttpService:JSONDecode(readfile("Rivals_Config.json")); for k,v in pairs(data) do Settings[k] = v end RefreshUI() end end)

local circle = Drawing.new("Circle"); circle.Thickness, circle.Visible = 1.5, true
table.insert(ESP_Objects, circle)

local function UnloadHub()
    Settings.Running = false
    task.wait(0.1)
    for _, obj in pairs(ESP_Objects) do
        pcall(function() obj:Remove() end)
    end
    ScreenGui:Destroy()
end

local Unload = Instance.new("TextButton", Main); Unload.Size = UDim2.new(0.9, 0, 0, 35); Unload.Position = UDim2.new(0.05, 0, 0, 630); Unload.Text = "UNLOAD HUB"; Unload.BackgroundColor3 = Color3.fromRGB(150, 0, 0); Unload.TextColor3 = Color3.new(1, 1, 1); Unload.Font = Enum.Font.GothamBold; Instance.new("UICorner", Unload)
Unload.MouseButton1Click:Connect(UnloadHub)

RunService.RenderStepped:Connect(function()
    if not Settings.Running then circle.Visible = false return end
    local target = getTarget()
    circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); circle.Radius = Settings.FOV
    circle.Color = target and Color3.fromRGB(255, 50, 255) or Color3.fromRGB(0, 255, 255)
    circle.Visible = Settings.SilentAim
end)

UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.LeftAlt then Main.Visible = not Main.Visible end end)
