--[[
ULTIMATE TOOL V4 - PURPLE APOCALYPSE
Client-side dashboard and personal trackers only.
No remote-event firing, no server manipulation, no admin bypass,
no fake Robux/donations, no automation of gameplay.
Use only where local client scripts are permitted.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("UltimateToolV4")
if old then old:Destroy() end

local PURPLE = Color3.fromRGB(164, 78, 255)
local DEEP = Color3.fromRGB(26, 15, 39)
local PANEL = Color3.fromRGB(37, 24, 53)
local PANEL2 = Color3.fromRGB(54, 34, 76)
local TEXT = Color3.fromRGB(245, 237, 255)
local MUTED = Color3.fromRGB(178, 159, 198)
local GREEN = Color3.fromRGB(105, 225, 163)

local state = {
    page = "Home",
    selectedGame = "Auto",
    liftCount = 0,
    liftGoal = 100,
    summonLog = {},
    boothDraft = "",
    notes = {},
    favorites = {},
}

local gui = Instance.new("ScreenGui")
gui.Name = "UltimateToolV4"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = obj
end

local function stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or PURPLE
    s.Thickness = thickness or 1
    s.Transparency = 0.2
    s.Parent = obj
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local main = make("Frame", {
    Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.53), Size = UDim2.new(0.88, 0, 0.78, 0),
    BackgroundColor3 = DEEP, BorderSizePixel = 0,
}, gui)
main.Size = UDim2.new(0, math.min(900, workspace.CurrentCamera.ViewportSize.X - 24), 0, math.min(590, workspace.CurrentCamera.ViewportSize.Y - 70))
corner(main, 20); stroke(main, PURPLE, 2)

local top = make("Frame", {Size=UDim2.new(1,0,0,82), BackgroundColor3=Color3.fromRGB(48,25,68), BorderSizePixel=0}, main)
corner(top, 18)
make("TextLabel", {
    Position=UDim2.new(0,20,0,10), Size=UDim2.new(1,-100,0,36),
    BackgroundTransparency=1, Text="ULTIMATE TOOL V4", TextColor3=TEXT,
    Font=Enum.Font.GothamBlack, TextSize=25, TextXAlignment=Enum.TextXAlignment.Left,
}, top)
make("TextLabel", {
    Position=UDim2.new(0,21,0,47), Size=UDim2.new(1,-100,0,22),
    BackgroundTransparency=1, Text="PURPLE APOCALYPSE  •  MULTI-GAME CLIENT",
    TextColor3=PURPLE, Font=Enum.Font.GothamBold, TextSize=12,
    TextXAlignment=Enum.TextXAlignment.Left,
}, top)

local close = make("TextButton", {
    Position=UDim2.new(1,-58,0,16), Size=UDim2.new(0,40,0,40),
    Text="×", TextSize=25, Font=Enum.Font.GothamBold,
    TextColor3=TEXT, BackgroundColor3=Color3.fromRGB(105,35,91), BorderSizePixel=0,
}, top)
corner(close, 12)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Drag from header; touch and mouse supported.
do
    local dragging, dragInput, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local side = make("Frame", {
    Position=UDim2.new(0,12,0,94), Size=UDim2.new(0,190,1,-106),
    BackgroundColor3=Color3.fromRGB(23,16,34), BorderSizePixel=0,
}, main)
corner(side, 15)
local navList = make("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, side)
make("UIPadding", {PaddingTop=UDim.new(0,12), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10)}, side)

local content = make("ScrollingFrame", {
    Position=UDim2.new(0,214,0,94), Size=UDim2.new(1,-226,1,-106),
    BackgroundColor3=Color3.fromRGB(24,17,35), BorderSizePixel=0,
    ScrollBarThickness=5, ScrollBarImageColor3=PURPLE,
    CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
}, main)
corner(content, 15)
make("UIPadding", {PaddingTop=UDim.new(0,18), PaddingBottom=UDim.new(0,18), PaddingLeft=UDim.new(0,18), PaddingRight=UDim.new(0,18)}, content)
local contentList = make("UIListLayout", {Padding=UDim.new(0,11), SortOrder=Enum.SortOrder.LayoutOrder}, content)

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
    end
end

local function label(parent, text, size, color, height)
    return make("TextLabel", {
        Size=UDim2.new(1,0,0,height or 28), BackgroundTransparency=1,
        Text=text, TextColor3=color or TEXT, Font=Enum.Font.Gotham,
        TextSize=size or 14, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left,
    }, parent)
end

local function section(parent, title)
    local box = make("Frame", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundColor3=PANEL, BorderSizePixel=0}, parent)
    corner(box, 13); stroke(box, Color3.fromRGB(85,54,112), 1)
    make("UIPadding", {PaddingTop=UDim.new(0,12), PaddingBottom=UDim.new(0,12), PaddingLeft=UDim.new(0,13), PaddingRight=UDim.new(0,13)}, box)
    make("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, box)
    label(box, title, 16, PURPLE, 25).Font = Enum.Font.GothamBold
    return box
end

local function button(parent, text, callback)
    local b = make("TextButton", {
        Size=UDim2.new(1,0,0,40), BackgroundColor3=PANEL2, BorderSizePixel=0,
        Text=text, TextColor3=TEXT, Font=Enum.Font.GothamSemibold, TextSize=14,
        AutoButtonColor=true,
    }, parent)
    corner(b, 9)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function textbox(parent, placeholder, initial, callback)
    local t = make("TextBox", {
        Size=UDim2.new(1,0,0,42), BackgroundColor3=Color3.fromRGB(18,13,27),
        BorderSizePixel=0, Text=initial or "", PlaceholderText=placeholder,
        PlaceholderColor3=MUTED, TextColor3=TEXT, Font=Enum.Font.Gotham,
        TextSize=14, ClearTextOnFocus=false, TextXAlignment=Enum.TextXAlignment.Left,
    }, parent)
    corner(t, 9)
    t.FocusLost:Connect(function() callback(t.Text) end)
    return t
end

local function detectGame()
    local id = game.PlaceId
    if id == 14954975425 then return "Game 4 • Summon Anime RNG" end
    -- Game 1 and Game 3 IDs are intentionally left unverified.
    return "Unknown / not verified (PlaceId: " .. tostring(id) .. ")"
end

local function homePage()
    clearContent()
    label(content, "PURPLE APOCALYPSE ONLINE", 18, PURPLE, 30).Font = Enum.Font.GothamBlack
    local s = section(content, "SESSION STATUS")
    label(s, "Detected experience: " .. detectGame(), 14)
    label(s, "Player: " .. player.Name .. "   •   PlaceId: " .. tostring(game.PlaceId), 13, MUTED)
    label(s, "Access: local dashboard only. No admin permissions are granted.", 13, GREEN, 36)
    local g = section(content, "CHOOSE A MODULE")
    button(g, "GAME 1  •  PLS DONATE X", function() state.page="PLS DONATE X"; render() end)
    button(g, "GAME 3  •  ULTRA LIFTING SIMULATOR", function() state.page="Ultra Lifting"; render() end)
    button(g, "GAME 4  •  SUMMON ANIME RNG", function() state.page="Anime RNG"; render() end)
    button(g, "VISUAL LAB", function() state.page="Visual Lab"; render() end)
    button(g, "SETTINGS & ABOUT", function() state.page="Settings"; render() end)
    local n = section(content, "IMPORTANT")
    label(n, "Game-specific PlaceIds for Game 1 and Game 3 still need confirmation. Their modules can be opened manually for now.", 13, MUTED, 42)
    label(n, "All counters, notes, previews and logs in this build are local to this client session.", 13, MUTED, 38)
end

local function plsPage()
    clearContent()
    label(content, "GAME 1  /  PLS DONATE X", 18, PURPLE, 30).Font = Enum.Font.GothamBlack
    local booth = section(content, "BOOTH STUDIO • LOCAL PREVIEW")
    label(booth, "Draft booth text here. This does not publish a booth or create a donation.", 13, MUTED, 38)
    textbox(booth, "Write your booth message...", state.boothDraft, function(v) state.boothDraft=v end)
    button(booth, "PREVIEW BOOTH MESSAGE", function()
        local msg = state.boothDraft
        label(booth, "Preview: " .. (msg ~= "" and msg or "(empty message)"), 14, GREEN, 42)
    end)
    local stats = section(content, "DONATION & GOAL TRACKER")
    label(stats, "Track amounts manually. These values are not Robux balances or verified donations.", 12, MUTED, 38)
    local amount = textbox(stats, "Enter amount / goal note (e.g. 250 / 1000)", "", function(v) state.donationNote=v end)
    button(stats, "SAVE TRACKER NOTE", function()
        state.donationNote = amount.Text
        label(stats, "Saved locally: " .. (state.donationNote or ""), 13, GREEN, 30)
    end)
    local tips = section(content, "BOOTH CHECKLIST")
    for _, item in ipairs({"Keep booth text short and readable","State the purpose of your goal honestly","Check your game pass prices in Roblox","Never share passwords or account cookies"}) do
        label(tips, "• " .. item, 13, TEXT, 25)
    end
    local tools = section(content, "CREATOR UTILITIES")
    button(tools, "COPY BOOTH DRAFT", function()
        -- Clipboard APIs are not assumed; show the text inside the panel.
        label(tools, state.boothDraft ~= "" and state.boothDraft or "No draft to show.", 13, GREEN, 38)
    end)
end

local function liftingPage()
    clearContent()
    label(content, "GAME 3  /  ULTRA LIFTING SIMULATOR", 18, PURPLE, 30).Font = Enum.Font.GothamBlack
    local tracker = section(content, "WORKOUT TRACKER • LOCAL")
    local countLabel = label(tracker, "Tracked reps: " .. state.liftCount, 16, GREEN, 30)
    local goalLabel = label(tracker, "Personal target: " .. state.liftGoal, 13, MUTED, 25)
    local progress = make("Frame", {Size=UDim2.new(1,0,0,12), BackgroundColor3=Color3.fromRGB(15,11,22), BorderSizePixel=0}, tracker)
    corner(progress, 8)
    local fill = make("Frame", {Size=UDim2.new(math.clamp(state.liftCount/math.max(state.liftGoal,1),0,1),0,1,0), BackgroundColor3=PURPLE, BorderSizePixel=0}, progress)
    corner(fill, 8)
    local function refresh()
        countLabel.Text = "Tracked reps: " .. state.liftCount
        goalLabel.Text = "Personal target: " .. state.liftGoal
        fill.Size = UDim2.new(math.clamp(state.liftCount/math.max(state.liftGoal,1),0,1),0,1,0)
    end
    button(tracker, "+1 TRACKED REP", function() state.liftCount += 1; refresh() end)
    button(tracker, "+10 TRACKED REPS", function() state.liftCount += 10; refresh() end)
    button(tracker, "RESET COUNTER", function() state.liftCount=0; refresh() end)
    textbox(tracker, "Set personal target (number)", tostring(state.liftGoal), function(v)
        local n = tonumber(v); if n and n > 0 then state.liftGoal=math.floor(n); refresh() end
    end)
    local planner = section(content, "SESSION PLANNER")
    label(planner, "Use this to plan your own play session; it does not auto-train, auto-click or change in-game strength.", 13, MUTED, 42)
    textbox(planner, "Session note (e.g. 3 sets, rest 60 sec)", "", function(v) state.liftingNote=v end)
    button(planner, "SAVE SESSION NOTE", function()
        label(planner, "Saved: " .. (state.liftingNote or ""), 13, GREEN, 30)
    end)
    local visuals = section(content, "VISUAL PREFERENCES")
    button(visuals, "TOGGLE PURPLE AURA", function()
        local char = player.Character
        if not char then return end
        local h = char:FindFirstChild("UT4_LocalAura")
        if h then h:Destroy() else
            h = Instance.new("Highlight"); h.Name="UT4_LocalAura"
            h.FillColor=PURPLE; h.OutlineColor=TEXT; h.FillTransparency=0.72
            h.DepthMode=Enum.HighlightDepthMode.Occluded; h.Parent=char
        end
    end)
end

local function rngPage()
    clearContent()
    label(content, "GAME 4  /  SUMMON ANIME RNG", 18, PURPLE, 30).Font = Enum.Font.GothamBlack
    local log = section(content, "SUMMON LOG • MANUAL ENTRY")
    label(log, "Record outcomes you actually receive. This does not change RNG, odds, pity or summon results.", 13, MUTED, 42)
    local rarityBox = textbox(log, "Character / rarity / result", "", function(v) state.lastSummon=v end)
    button(log, "ADD RESULT TO LOG", function()
        if rarityBox.Text ~= "" then
            table.insert(state.summonLog, 1, os.date("%H:%M:%S") .. " — " .. rarityBox.Text)
            rarityBox.Text = ""
            label(log, "Added. Total recorded: " .. #state.summonLog, 13, GREEN, 26)
        end
    end)
    button(log, "SHOW RECENT RESULTS", function()
        local summary = section(content, "RECENT SUMMONS")
        if #state.summonLog == 0 then label(summary, "No results recorded yet.", 13, MUTED)
        else
            for i=1, math.min(12,#state.summonLog) do label(summary, state.summonLog[i], 12, TEXT, 24) end
        end
    end)
    local calc = section(content, "PROBABILITY EXPLAINER")
    label(calc, "For a single independent attempt with probability p, chance of at least one success in n attempts is 1 - (1 - p)^n.", 13, MUTED, 55)
    local pBox = textbox(calc, "Chance per attempt (%)", "1", function(v) state.pct=tonumber(v) end)
    local nBox = textbox(calc, "Number of attempts", "100", function(v) state.attempts=tonumber(v) end)
    button(calc, "CALCULATE ESTIMATED CHANCE", function()
        local p=tonumber(pBox.Text); local n=tonumber(nBox.Text)
        if p and n and p>=0 and p<=100 and n>=1 and n<=100000 then
            local chance = 1 - (1-p/100)^math.floor(n)
            label(calc, string.format("Estimated chance: %.2f%% (assuming independent rolls and fixed odds)", chance*100), 13, GREEN, 40)
        else
            label(calc, "Enter chance 0–100 and attempts 1–100000.", 13, MUTED, 28)
        end
    end)
    local note = section(content, "COLLECTION NOTES")
    textbox(note, "Write a wish list or collection note...", "", function(v) state.collectionNote=v end)
end

local function visualPage()
    clearContent()
    label(content, "VISUAL LAB", 18, PURPLE, 30).Font = Enum.Font.GothamBlack
    local v = section(content, "LOCAL VISUALS")
    button(v, "TOGGLE LOCAL CHARACTER HIGHLIGHT", function()
        local char=player.Character; if not char then return end
        local h=char:FindFirstChild("UT4_LocalAura")
        if h then h:Destroy() else
            h=Instance.new("Highlight"); h.Name="UT4_LocalAura"
            h.FillColor=PURPLE; h.OutlineColor=TEXT; h.FillTransparency=0.7
            h.Parent=char
        end
    end)
    button(v, "CINEMATIC CAMERA FOV", function()
        local cam=workspace.CurrentCamera
        if cam then
            local target = cam.FieldOfView > 75 and 70 or 85
            TweenService:Create(cam, TweenInfo.new(0.35), {FieldOfView=target}):Play()
        end
    end)
    button(v, "RESET CAMERA FOV", function()
        local cam=workspace.CurrentCamera
        if cam then TweenService:Create(cam, TweenInfo.new(0.3), {FieldOfView=70}):Play() end
    end)
    label(v, "Visual effects are local and may be reset when your character respawns.", 12, MUTED, 34)
end

local function settingsPage()
    clearContent()
    label(content, "SETTINGS & ABOUT", 18, PURPLE, 30).Font = Enum.Font.GothamBlack
    local s=section(content, "SESSION")
    label(s, "Player: " .. player.Name, 13)
    label(s, "PlaceId: " .. tostring(game.PlaceId), 13)
    label(s, "Experience detection: " .. detectGame(), 13, MUTED, 42)
    button(s, "MINIMIZE WINDOW", function() main.Visible=false end)
    label(s, "To reopen after minimizing, use the small reopen button.", 12, MUTED, 28)
    local a=section(content, "ABOUT & SAFETY")
    label(a, "V4 is a client-side dashboard. It does not grant HD Admin/Kohl's Admin, bypass permissions, manipulate server data, send game remotes, create Robux, or alter summon odds.", 13, MUTED, 76)
    label(a, "Game 1 and Game 3 PlaceIds are not verified in this build. Manual module buttons remain available.", 13, MUTED, 48)
    button(a, "EXPORT SESSION SUMMARY (DISPLAY)", function()
        local summary = "Ultimate Tool V4\nPlaceId: "..tostring(game.PlaceId).."\nTracked reps: "..state.liftCount.."\nSummon log entries: "..#state.summonLog
        label(a, summary, 12, GREEN, 65)
    end)
end

local pages = {
    ["Home"]=homePage, ["PLS DONATE X"]=plsPage, ["Ultra Lifting"]=liftingPage,
    ["Anime RNG"]=rngPage, ["Visual Lab"]=visualPage, ["Settings"]=settingsPage,
}
function render()
    local fn=pages[state.page] or homePage
    fn()
end

local navItems = {"Home","PLS DONATE X","Ultra Lifting","Anime RNG","Visual Lab","Settings"}
for i, name in ipairs(navItems) do
    local b=make("TextButton", {
        Name="Nav_"..i, LayoutOrder=i, Size=UDim2.new(1,0,0,43),
        BackgroundColor3=(name=="Home" and PANEL2 or PANEL),
        BorderSizePixel=0, Text=name, TextColor3=TEXT,
        Font=Enum.Font.GothamSemibold, TextSize=13,
    }, side)
    corner(b, 10)
    b.MouseButton1Click:Connect(function()
        state.page=name
        for _, item in ipairs(side:GetChildren()) do
            if item:IsA("TextButton") then item.BackgroundColor3=(item.Text==name and PANEL2 or PANEL) end
        end
        render()
    end)
end

local reopen = make("TextButton", {
    Name="Reopen", Position=UDim2.new(0,12,0,120), Size=UDim2.new(0,52,0,42),
    BackgroundColor3=Color3.fromRGB(55,28,78), Text="UT4", TextColor3=TEXT,
    Font=Enum.Font.GothamBlack, TextSize=14, Visible=false, BorderSizePixel=0,
}, gui)
corner(reopen, 12); stroke(reopen, PURPLE, 1)
reopen.MouseButton1Click:Connect(function() main.Visible=true; reopen.Visible=false end)

local minimize = make("TextButton", {
    Position=UDim2.new(1,-105,0,16), Size=UDim2.new(0,38,0,40),
    BackgroundColor3=PANEL2, Text="—", TextColor3=TEXT, Font=Enum.Font.GothamBold,
    TextSize=20, BorderSizePixel=0,
}, top)
corner(minimize, 10)
minimize.MouseButton1Click:Connect(function() main.Visible=false; reopen.Visible=true end)

-- Mobile-friendly sizing adjustment.
local function resize()
    local cam=workspace.CurrentCamera
    if cam then
        local vp=cam.ViewportSize
        main.Size=UDim2.new(0, math.max(300, math.min(900, vp.X-20)), 0, math.max(360, math.min(590, vp.Y-50)))
        if vp.X < 600 then
            side.Size=UDim2.new(0,132,1,-106)
            content.Position=UDim2.new(0,150,0,94)
            content.Size=UDim2.new(1,-162,1,-106)
        else
            side.Size=UDim2.new(0,190,1,-106)
            content.Position=UDim2.new(0,214,0,94)
            content.Size=UDim2.new(1,-226,1,-106)
        end
    end
end
resize()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end

render()
