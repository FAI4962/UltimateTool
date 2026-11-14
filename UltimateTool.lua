--[[
    ULTIMATE TOOL V2 - PURPLE APOCALYPSE
    Universal client framework for Roblox experiences YOU OWN or are authorized to modify.

    INSTALL:
    1. In Roblox Studio, create a LocalScript in StarterPlayer > StarterPlayerScripts.
    2. Paste this entire file into that LocalScript.
    3. Press Play to test.
    4. Game-specific/server-authoritative features belong in separate server scripts
       and should validate owner/admin permissions on the server.

    Controls:
    - RightShift: show/hide panel
    - Movement controls affect the local character and may be overridden by server game logic.
    - Teleport coordinates are local testing utilities, not cross-game exploit features.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    Title = "ULTIMATE TOOL",
    Subtitle = "PURPLE APOCALYPSE  •  UNIVERSAL CORE",
    Accent = Color3.fromRGB(174, 92, 255),
    AccentDark = Color3.fromRGB(94, 35, 160),
    Background = Color3.fromRGB(14, 11, 22),
    Panel = Color3.fromRGB(25, 19, 38),
    Text = Color3.fromRGB(245, 237, 255),
    Muted = Color3.fromRGB(169, 151, 190),
    DefaultWalkSpeed = 16,
    DefaultJumpPower = 50,
}

local old = PlayerGui:FindFirstChild("UltimateToolV2")
if old then old:Destroy() end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local gui = make("ScreenGui", {
    Name = "UltimateToolV2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(590, 390),
    Position = UDim2.new(0.5, -295, 0.5, -195),
    BackgroundColor3 = CONFIG.Background,
    BorderSizePixel = 0,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 14)}, main)
make("UIStroke", {Color = CONFIG.Accent, Thickness = 1.5, Transparency = 0.12}, main)

local scale = make("UIScale", {Scale = 1}, main)
local function fitScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    scale.Scale = math.clamp(math.min(viewport.X / 650, viewport.Y / 440), 0.62, 1)
end
fitScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale)
end

local top = make("Frame", {
    Size = UDim2.new(1, 0, 0, 66),
    BackgroundColor3 = Color3.fromRGB(37, 23, 58),
    BorderSizePixel = 0,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 14)}, top)
make("Frame", {
    Position = UDim2.new(0, 0, 1, -14),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundColor3 = top.BackgroundColor3,
    BorderSizePixel = 0,
}, top)

local title = make("TextLabel", {
    Position = UDim2.fromOffset(18, 9),
    Size = UDim2.new(1, -100, 0, 27),
    BackgroundTransparency = 1,
    Text = CONFIG.Title,
    Font = Enum.Font.GothamBlack,
    TextSize = 20,
    TextColor3 = CONFIG.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)
local subtitle = make("TextLabel", {
    Position = UDim2.fromOffset(19, 36),
    Size = UDim2.new(1, -100, 0, 18),
    BackgroundTransparency = 1,
    Text = CONFIG.Subtitle,
    Font = Enum.Font.GothamMedium,
    TextSize = 9,
    TextColor3 = CONFIG.Accent,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local close = make("TextButton", {
    Position = UDim2.new(1, -46, 0, 15),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = Color3.fromRGB(92, 35, 75),
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = CONFIG.Text,
    BorderSizePixel = 0,
}, top)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Drag panel from its header.
do
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(12, 78),
    Size = UDim2.new(0, 142, 1, -91),
    BackgroundColor3 = CONFIG.Panel,
    BorderSizePixel = 0,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 10)}, sidebar)
make("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)
make("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 9),
    PaddingRight = UDim.new(0, 9),
}, sidebar)

local content = make("Frame", {
    Position = UDim2.fromOffset(166, 78),
    Size = UDim2.new(1, -178, 1, -91),
    BackgroundColor3 = CONFIG.Panel,
    BorderSizePixel = 0,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 10)}, content)

local pages, tabButtons = {}, {}
local activePage
local function showPage(name)
    for pageName, page in pairs(pages) do page.Visible = pageName == name end
    for tabName, button in pairs(tabButtons) do
        button.BackgroundColor3 = tabName == name and CONFIG.AccentDark or Color3.fromRGB(39, 29, 54)
    end
    activePage = name
end

local function createPage(name, order)
    local tab = make("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Color3.fromRGB(39, 29, 54),
        Text = "  " .. name,
        TextColor3 = CONFIG.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        LayoutOrder = order,
    }, sidebar)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, tab)

    local page = make("ScrollingFrame", {
        Name = name .. "Page",
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.new(1, -24, 1, -24),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = CONFIG.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, content)
    make("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    tab.MouseButton1Click:Connect(function() showPage(name) end)
    pages[name], tabButtons[name] = page, tab
    return page
end

local function section(parent, text)
    return make("TextLabel", {
        Size = UDim2.new(1, -4, 0, 25),
        BackgroundTransparency = 1,
        Text = string.upper(text),
        TextColor3 = CONFIG.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local function info(parent, text)
    return make("TextLabel", {
        Size = UDim2.new(1, -4, 0, 42),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CONFIG.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local function button(parent, text, callback)
    local b = make("TextButton", {
        Size = UDim2.new(1, -4, 0, 36),
        BackgroundColor3 = Color3.fromRGB(55, 35, 79),
        Text = text,
        TextColor3 = CONFIG.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        BorderSizePixel = 0,
        AutoButtonColor = true,
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 8)}, b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function textBox(parent, placeholder, defaultText)
    local box = make("TextBox", {
        Size = UDim2.new(1, -4, 0, 36),
        BackgroundColor3 = Color3.fromRGB(17, 13, 26),
        Text = defaultText or "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = CONFIG.Muted,
        TextColor3 = CONFIG.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 8)}, box)
    return box
end

local function getCharacter()
    local character = LocalPlayer.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, root
end

-- OVERVIEW
local overview = createPage("Overview", 1)
section(overview, "Welcome back")
info(overview, "Purple Apocalypse core is online. This is a reusable client framework for experiences you own or are authorized to modify.")
section(overview, "Quick controls")
button(overview, "RESET MOVEMENT DEFAULTS", function()
    local _, humanoid = getCharacter()
    if humanoid then
        humanoid.WalkSpeed = CONFIG.DefaultWalkSpeed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = CONFIG.DefaultJumpPower
    end
end)
button(overview, "RELOAD CHARACTER", function()
    LocalPlayer:LoadCharacter()
end)

-- PLAYER
local player = createPage("Player", 2)
section(player, "Movement")
local speedBox = textBox(player, "WalkSpeed (example: 32)", "32")
button(player, "APPLY WALKSPEED", function()
    local value = tonumber(speedBox.Text)
    local _, humanoid = getCharacter()
    if value and humanoid then humanoid.WalkSpeed = math.clamp(value, 0, 100) end
end)
local jumpBox = textBox(player, "JumpPower (example: 70)", "70")
button(player, "APPLY JUMP POWER", function()
    local value = tonumber(jumpBox.Text)
    local _, humanoid = getCharacter()
    if value and humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = math.clamp(value, 0, 150)
    end
end)
info(player, "Movement changes are local test controls. Your game's server scripts may enforce their own movement rules.")

-- TELEPORT
local teleport = createPage("Teleport", 3)
section(teleport, "Coordinate teleport")
info(teleport, "Enter X, Y, Z coordinates in your own test map.")
local xBox = textBox(teleport, "X coordinate", "0")
local yBox = textBox(teleport, "Y coordinate", "10")
local zBox = textBox(teleport, "Z coordinate", "0")
button(teleport, "TELEPORT TO COORDINATES", function()
    local x, y, z = tonumber(xBox.Text), tonumber(yBox.Text), tonumber(zBox.Text)
    local _, _, root = getCharacter()
    if x and y and z and root then
        root.CFrame = CFrame.new(x, y, z)
    end
end)
button(teleport, "RETURN TO SPAWN", function()
    local _, _, root = getCharacter()
    local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if root and spawn then root.CFrame = spawn.CFrame + Vector3.new(0, 4, 0) end
end)

-- VISUALS
local visuals = createPage("Visuals", 4)
section(visuals, "Local effects")
local auraEnabled = false
local aura
local function clearAura()
    if aura then aura:Destroy(); aura = nil end
end
button(visuals, "TOGGLE PURPLE AURA", function()
    auraEnabled = not auraEnabled
    clearAura()
    local character = LocalPlayer.Character
    if auraEnabled and character then
        aura = Instance.new("Highlight")
        aura.Name = "UltimatePurpleAura"
        aura.FillColor = CONFIG.Accent
        aura.OutlineColor = Color3.fromRGB(230, 190, 255)
        aura.FillTransparency = 0.72
        aura.OutlineTransparency = 0.05
        aura.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        aura.Parent = character
    end
end)
button(visuals, "DISABLE ALL LOCAL EFFECTS", function()
    auraEnabled = false
    clearAura()
end)
info(visuals, "Visual effects are client-side and may only be visible to you.")

-- ADAPTERS
local adapters = createPage("Adapters", 5)
section(adapters, "Game adapter interface")
info(adapters, "Add a separate adapter for each experience you own. Each adapter can expose approved features for that game's systems.")
button(adapters, "PRINT ADAPTER TEMPLATE", function()
    print([[
-- Example adapter module (place in a ModuleScript you own):
local Adapter = {}
Adapter.GameName = "My Experience"
function Adapter.Init(context)
    print("Adapter initialized for", context.Player.Name)
end
return Adapter
]])
end)
info(adapters, "Server features such as granting resources, spawning NPCs, or combat testing must be implemented by your game's server scripts with server-side owner/admin checks. Never trust client-only permission checks.")

-- SETTINGS
local settings = createPage("Settings", 6)
section(settings, "Interface")
button(settings, "HIDE PANEL  •  RIGHTSHIFT TO SHOW", function()
    main.Visible = false
end)
button(settings, "RESET PANEL POSITION", function()
    main.Position = UDim2.new(0.5, -295, 0.5, -195)
end)
info(settings, "Ultimate Tool V2 • Purple Apocalypse\nUniversal client core • Build your own authorized game adapters.")

showPage("Overview")

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift and gui.Parent then
        main.Visible = not main.Visible
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if auraEnabled then
        clearAura()
        local character = LocalPlayer.Character
        if character then
            aura = Instance.new("Highlight")
            aura.Name = "UltimatePurpleAura"
            aura.FillColor = CONFIG.Accent
            aura.OutlineColor = Color3.fromRGB(230, 190, 255)
            aura.FillTransparency = 0.72
            aura.OutlineTransparency = 0.05
            aura.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            aura.Parent = character
        end
    end
end)

print("[UltimateTool V2] Purple Apocalypse loaded for", LocalPlayer.Name)
