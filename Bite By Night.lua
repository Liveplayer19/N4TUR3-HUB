if getgenv().NullixLoaded then
    for _, connection in getgenv().NullixConnections do
        connection:Disconnect()
    end
end

getgenv().NullixLoaded = true
getgenv().NullixConnections = {}

--// Services

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

--// Variables

local localPlr = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local playerGui = localPlr.PlayerGui

--// Functions

local function getCharacter()
	return localPlr.Character or localPlr.CharacterAdded:Wait()
end

local safeTeleportEnabled = true
local safeTeleporting = false
local function tpChar(target:CFrame, bypass)
    if safeTeleporting then return end
    if safeTeleportEnabled and not bypass then -- took insporation from Celeron's safe teleport
        local root = getCharacter().PrimaryPart
        root.Anchored = true
        safeTeleporting = true
        
        local startCF = root.CFrame
        local dist = (startCF.Position - target.Position).Magnitude
        local duration = dist / getCharacter():GetAttribute("RunSpeed")

        local step = 0

        while step < duration do
            step += RunService.Heartbeat:Wait()
            
            local alpha = math.clamp(step / duration,0,1)
            root.CFrame = startCF:Lerp(target,alpha)
        end

        root.CFrame = target
        root.Anchored = false
        safeTeleporting = false
    else
        local char = getCharacter()
        local root = char.PrimaryPart
        root.CFrame = target
    end
end

local function getExternalModule(url:string)
	return loadstring(game:HttpGet(url))()
end

local function getTeam()
    return getCharacter():GetAttribute("Team")
end

local function serverHop()
    queue_on_teleport("task.wait(5)loadstring(game:HttpGet('https://raw.githubusercontent.com/caelmn/ExploitScripts/refs/heads/main/CustomScripts/BiteByNight.lua'))()(true)")
    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end

--// Modules

local Library = getExternalModule("https://raw.githubusercontent.com/caelmn/ExploitScripts/refs/heads/main/UILibs/cat.lua")
local CESP = getExternalModule("https://raw.githubusercontent.com/caelmn/ExploitScripts/refs/heads/main/CustomModules/CharacterESP.lua")
local Fullbright = getExternalModule("https://raw.githubusercontent.com/caelmn/ExploitScripts/refs/heads/main/OtherScripts/fullbright.lua")
local ESP = getExternalModule("https://raw.githubusercontent.com/caelmn/ExploitScripts/refs/heads/main/CustomModules/ESP.lua")

--// UI

local Window = Library:CreateWindow("[N4tur3 Hub] Bite By Night - Toggle Right Shift")
local GameTab = Window:CreateTab("Game")
local SurvivorSector = GameTab:CreateSector("Survivor", "left")
local MovementSector = GameTab:CreateSector("Movement", "right")
local MapSector = GameTab:CreateSector("Map", "right")
local VisualSector = GameTab:CreateSector("Visual", "left")
local TPSector = GameTab:CreateSector("Teleports", "right")
local CreditSector = GameTab:CreateSector("Credits", "left")

--// Modules

-- Auto gen

local autoGenConnection
local autoGenToggle = SurvivorSector:AddToggle("Auto Generator", false, function(v)
    autoGenLoop = v
    if v then
        autoGenConnection = RunService.Heartbeat:Connect(function()
            local genUi = playerGui:FindFirstChild("Gen")
            if genUi then
                local event = genUi.GeneratorMain.Event
                event:FireServer({ Wires = true, Switches = true, Lever = true })
            end
        end)
    else
        autoGenConnection:Disconnect()
    end
end)

-- Complete all gens

local function completeAllGenerators()
    autoGenToggle:Set(true)
    local genFolder = workspace.MAPS["GAME MAP"].Generators
    for _, generator in pairs(genFolder:GetChildren()) do
        if generator:GetAttribute("Progress") < 100 then
            tpChar(CFrame.new(generator.PrimaryPart.Position+Vector3.new(0,2,0)))
            task.wait(0.2)
            -- find enabled proximity prompt
            local proximityPrompt = generator.RootPart.Point1.ProximityPrompt
            if not proximityPrompt.Enabled then
                proximityPrompt = generator.RootPart.Point2.ProximityPrompt
            end
            if not proximityPrompt.Enabled then
                proximityPrompt = generator.RootPart.Point3.ProximityPrompt
            end
            if not proximityPrompt.Enabled then
                continue
            end
            fireproximityprompt(proximityPrompt)
            task.wait(3)
        end
    end
end

SurvivorSector:AddButton("Complete All Generators", function()
    task.spawn(completeAllGenerators)
end)

-- Auto barricade

local autoBarricadeConection
SurvivorSector:AddToggle("Auto Barricade", false, function(v)
    if v then
        autoBarricadeConection = RunService.Heartbeat:Connect(function()
            local dotUi -- prior dot uis linger in the playergui so checks for enabled screen gui is mandatory
            for _, v in pairs(playerGui:GetChildren()) do
                if v.Name == "Dot" and v.Enabled == true then
                    dotUi = v
                end
            end
            if dotUi then
                local frame = dotUi.Container.Frame
                local viewportSize = currentCamera.ViewportSize
                local target = UDim2.fromOffset(viewportSize.X/2, viewportSize.Y/2)
                frame.Position = target
            end
        end)
    else
        autoBarricadeConection:Disconnect()
    end
end)

-- raw speed

local rawSpeedConnection
MovementSector:AddToggle("Bypass Slowness", false, function(v)
    if v then
        rawSpeedConnection = RunService.Heartbeat:Connect(function()
            local char = getCharacter()
            local runSpeed = char:GetAttribute("RunSpeed")
            local newSpeed = (runSpeed~=0) and runSpeed or 24
            char.Humanoid.WalkSpeed = newSpeed
            if getTeam() == "Survivor" then
                char:SetAttribute("CustomSpeed", newSpeed)
            elseif getTeam() == "Killer" then
                char:SetAttribute("ModifiedMovementSpeed", newSpeed)
            end
        end)
    else
        rawSpeedConnection:Disconnect()
    end
end)

-- always run

local alwaysRunConnection
MovementSector:AddToggle("Always Run", false, function(v)
    if v then
        alwaysRunConnection = RunService.Heartbeat:Connect(function()
            local char = getCharacter()
            local runSpeed = char:GetAttribute("RunSpeed")
            local newSpeed = (runSpeed~=0) and runSpeed or 24
            char:SetAttribute("WalkSpeed", newSpeed)
        end)
    else
        alwaysRunConnection:Disconnect()
    end
end)

-- enable jumps

local enableJumpingConnection
MovementSector:AddToggle("Enable Jumping", false, function(v)
    if v then
        enableJumpingConnection = RunService.Heartbeat:Connect(function()
            local char = getCharacter()
            local humanoid = char.Humanoid
            humanoid.JumpHeight = v and 5 or 0
        end)
    else
        enableJumpingConnection:Disconnect()
    end
end)

-- no barriers

local noBarriersConnection
MapSector:AddToggle("No Barriers", false, function(v)
    if v then
        noBarriersConnection = RunService.Heartbeat:Connect(function()
            for _, v in pairs(workspace.IGNORE:GetChildren()) do
                if v.Name == "BARRIER" or v.Name == "BOUNDARY" then
                    v.CanCollide = not v
                end
            end
        end)
    else
        noBarriersConnection:Disconnect()
    end
end)

-- survivor esp

local survivorESPs = {}
local heartbeatSurvivorESP
VisualSector:AddToggle("Survivor ESP", false, function(v)
    if v then
        heartbeatSurvivorESP = RunService.RenderStepped:Connect(function()
            for _, char in pairs(workspace.PLAYERS.ALIVE:GetChildren()) do
                if not survivorESPs[char] and char ~= getCharacter() then
                    survivorESPs[char] = CESP.new(char, Color3.new(0,1,0))
                end
            end
            for char, esp in pairs(survivorESPs) do
                if not char.Parent then
                    esp:destroy()
                    survivorESPs[char] = nil
                end
            end
        end)
    else
        if heartbeatSurvivorESP then
            heartbeatSurvivorESP:Disconnect()
        end
        for _, esp in pairs(survivorESPs) do
            esp:destroy()
        end
        survivorESPs = {}
    end
end)

-- killer esp

local killerESPs = {}
local heartbeatKillerESP
VisualSector:AddToggle("Killer ESP", false, function(v)
    if v then
        heartbeatKillerESP = RunService.RenderStepped:Connect(function()
            for _, char in pairs(workspace.PLAYERS.KILLER:GetChildren()) do
                if not killerESPs[char] and char ~= getCharacter() then
                    killerESPs[char] = CESP.new(char, Color3.new(1,0,0))
                end
            end
            for char, esp in pairs(killerESPs) do
                if not char.Parent then
                    esp:destroy()
                    killerESPs[char] = nil
                end
            end
        end)
    else
        if heartbeatKillerESP then
            heartbeatKillerESP:Disconnect()
        end
        for _, esp in pairs(killerESPs) do
            esp:destroy()
        end
        killerESPs = {}
    end
end)

-- generator esp

local generatorESP = ESP.new("Generator", Color3.new(0,0,1))
local genESPConnection
local generatorESPFrames = {}
VisualSector:AddToggle("Generator ESP", false, function(v)
    if v then
        genESPConnection = RunService.Heartbeat:Connect(function()
            if not workspace.MAPS:FindFirstChild("GAME MAP") then return end
            local generatorFolder = workspace.MAPS:FindFirstChild("GAME MAP").Generators
            for _, generator in generatorFolder:GetChildren() do
                if generator:GetAttribute("Progress") < 100 and not generatorESPFrames[generator] then
                    local frame = generatorESP:newFrame(generator.PrimaryPart)
                    frame:addDistanceLabel()
                    generatorESPFrames[generator] = frame
                end
            end
            for generator, frame in pairs(generatorESPFrames) do
                if not generator.Parent or generator:GetAttribute("Progress") >= 100 then
                    frame:destroy()
                end
            end
        end)
    else
        generatorESP:clear()
        genESPConnection:Disconnect()
        generatorESPFrames = {}
    end
end)

-- battery esp

local batteryESP = ESP.new("Battery", Color3.fromRGB(255, 165, 0))
local batteryESPConnection
local batteryESPFrames = {}
VisualSector:AddToggle("Battery ESP", false, function(v)
    if v then
        batteryESPConnection = RunService.Heartbeat:Connect(function()
            local batteries = {}
            for _, v in pairs(workspace.IGNORE:GetChildren()) do
                if v.Name == 'Battery' then
                    table.insert(batteries, v)
                end
            end
            for _, battery in batteries do
                if not batteryESPFrames[battery] then
                    local frame = batteryESP:newFrame(battery)
                    frame:addDistanceLabel()
                    batteryESPFrames[battery] = frame
                end
            end
            for battery, frame in pairs(batteryESPFrames) do
                if not battery.Parent then
                    frame:destroy()
                end
            end
        end)
    else
        batteryESP:clear()
        batteryESPConnection:Disconnect()
        batteryESPFrames = {}
    end
end)

-- trap esp

local trapESP = ESP.new("Trap", Color3.new(1,0,0))
local trapESPConnection
local trapESPFrames = {}
VisualSector:AddToggle("Trap ESP", false, function(v)
    if v then
        trapESPConnection = RunService.Heartbeat:Connect(function()
            local traps = {}
            for _, v in pairs(workspace.IGNORE:GetChildren()) do
                if v.Name == 'Trap' then
                    table.insert(traps, v)
                end
            end
            for _, trap in traps do
                if not trapESPFrames[trap] then
                    local frame = trapESP:newFrame(trap.PrimaryPart)
                    frame:addDistanceLabel()
                    trapESPFrames[trap] = frame
                end
            end
            for trap, frame in pairs(trapESPFrames) do
                if not trap.Parent then
                    frame:destroy()
                end
            end
        end)
    else
        trapESP:clear()
        trapESPConnection:Disconnect()
        trapESPFrames = {}
    end
end)

-- fusebox esp

local fuseboxESP = ESP.new("Fusebox", Color3.new(1,1,0))
local fuseESPConnection
local fuseESPFrames = {}
VisualSector:AddToggle("Fusebox ESP", false, function(v)
    if v then
        fuseESPConnection = RunService.Heartbeat:Connect(function()
            if not workspace.MAPS:FindFirstChild("GAME MAP") then return end
            if not workspace.MAPS:FindFirstChild("GAME MAP"):FindFirstChild("FuseBoxes") then return end
            local fuseboxFolder = workspace.MAPS:FindFirstChild("GAME MAP").FuseBoxes
            for _, fusebox in fuseboxFolder:GetChildren() do
                if not fusebox:GetAttribute("Inserted") and not fuseESPFrames[fusebox] then
                    local frame = fuseboxESP:newFrame(fusebox.PrimaryPart)
                    frame:addDistanceLabel()
                    fuseESPFrames[fusebox] = frame
                end
            end
            for fusebox, frame in pairs(fuseESPFrames) do
                if not fusebox.Parent or fusebox:GetAttribute("Inserted") then
                    frame:destroy()
                end
            end
        end)
    else
        fuseboxESP:clear()
        fuseESPConnection:Disconnect()
        fuseESPFrames = {}
    end
end)

-- fullbright & antiblind

local LightingFolder = Lighting:FindFirstChild("Lighting")
local lightingConnection
VisualSector:AddToggle("Fullbright + Antiblind", false, function(v)
    Fullbright.toggle(v)
    if v then
        lightingConnection = RunService.Heartbeat:Connect(function()
            LightingFolder = LightingFolder or Lighting:FindFirstChild("Lighting")
            LightingFolder.Parent = nil
        end)
    else
        lightingConnection:Disconnect()
        LightingFolder.Parent = Lighting
    end
end)

-- caution

TPSector:AddLabel("⚠️ DON'T SPAM ⚠️") -- more than 2 teleports in like 5 seconds = bad

-- safe mode

TPSector:AddToggle("Safe Teleport", true, function(v)
    safeTeleportEnabled = v
end)

-- tp to lobby

local safePos = workspace.Lobby["Player Position"].CFrame
TPSector:AddButton("Lobby", function()
    tpChar(safePos, true)
end)

-- tp to map

TPSector:AddButton("Map", function()
    local currentGenerators = workspace.MAPS["GAME MAP"].Generators:GetChildren()
    local ranGenerator = currentGenerators[math.random(1,#currentGenerators)]
    tpChar(ranGenerator.PrimaryPart.CFrame, true)
end)

-- tp to exit

local function escapeMap()
    if not workspace.GAME.CAN_ESCAPE.Value then return end

    local escapes = {}
    local a = workspace.MAPS:FindFirstChild("GAME MAP").Escapes:GetChildren()
    -- devs are unorganized and have escape points all over the place depending on the map
    if a[1] then
        escapes = a
    else
        for _, v in pairs(workspace.IGNORE:GetChildren()) do
            if v.Name == "EscapePoint" then
                table.insert(escapes, v)
            end
        end
    end

    for _, v in pairs(escapes) do
        if v:GetAttribute("Enabled") then
            tpChar(v.CFrame, true)
        end
    end
end

TPSector:AddButton("Escape", escapeMap)

local autoEscapeConnection
local autoEscapeToggle = SurvivorSector:AddToggle("Auto Escape", false, function(v)
    if v then
        autoEscapeConnection = RunService.Heartbeat:Connect(function()
            local char = getCharacter()
            if char:GetAttribute("Team") == "Survivor" then
                escapeMap()
            end
        end)
    else
        autoEscapeConnection:Disconnect()
    end
end)

local function toggleKiller(v)
    local args = {
        "SettingChange",
        "DisableKiller",
        not v
    }
    playerGui:WaitForChild("UI"):WaitForChild("Main"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

local autoFarmConnection
local prevTeam
local afToggle = SurvivorSector:AddToggle("Auto Farm", false, function(v)
    if v then
        autoEscapeToggle:Set(true)
        toggleKiller(false)
        autoFarmConnection = RunService.Heartbeat:Connect(function()
            local role = getTeam()
            if role ~= prevTeam then
                prevTeam = role
                if role == "Survivor" then
                    task.spawn(function()
                        task.wait(2)
                        completeAllGenerators()
                        tpChar(safePos, true)
                    end)
                end
            end
            if #game.Players:GetChildren() <= 3 then
                serverHop()
            end
        end)
    else
        toggleKiller(true)
        autoFarmConnection:Disconnect()
        prevTeam = nil
    end
end)

local boost = 0
local runBoostConnection = RunService.Heartbeat:Connect(function()
    local char = getCharacter()
    local team = getTeam()
    if team == "Survivor" then
        char:SetAttribute("RunSpeed", 24+boost)
    elseif team == "Killer" then
        char:SetAttribute("RunSpeed", 24+math.clamp(boost,0,10)) -- slightly slowed down since killer has higher detection
    end
end)

table.insert(getgenv().NullixConnections, runBoostConnection)

MovementSector:AddSlider("Run Boost [No Lobby]", 0, 0, 16, 1, function(v)
    local char = getCharacter()
    boost = v
end)

-- instant prompts

local instantPromptsConnection
MapSector:AddToggle("Instant Prompts", false, function(v)
    if v then
        instantPromptsConnection = RunService.Heartbeat:Connect(function()
            for _, v in workspace:GetDescendants() do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0.1
                end
            end
        end)
    else
        instantPromptsConnection:Disconnect()
    end
end)

-- credits

CreditSector:AddLabel("Made By @liveplayer19_yt")
CreditSector:AddButton("Copy Discord Invite", function()
    setclipboard("https://discord.gg/bYJMudYHuy")
end)

return function(serverHopping)
    if serverHopping then
        afToggle:Set(true)
    end
end
