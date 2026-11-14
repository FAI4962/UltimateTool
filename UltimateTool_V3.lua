-- ULTIMATE TOOL V3 - PURPLE APOCALYPSE
-- Client-side UI and local visual effects only.
-- No admin bypass, fake Robux/donations, server manipulation, or player exploits.
-- Toggle UI: RightShift

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")

local MODULES = {
    [15596356548] = {name="PLS DONATE X", status="Owner module - verify PlaceId"},
    [90023664101369] = {name="Explore as you like!!", status="Owner module - user supplied PlaceId"},
    [13928941253] = {name="Ultra Lifting Simulator", status="Authorized testing - verify PlaceId"},
    [14954975425] = {name="Summon Anime RNG", status="Authorized testing - user supplied PlaceId"},
}

local C = {
    bg=Color3.fromRGB(14,10,22), panel=Color3.fromRGB(27,19,40),
    panel2=Color3.fromRGB(48,31,69), purple=Color3.fromRGB(178,95,255),
    dark=Color3.fromRGB(94,43,151), white=Color3.fromRGB(246,239,255),
    muted=Color3.fromRGB(180,163,198)
}
local old = playerGui:FindFirstChild("UltimateToolV3")
if old then old:Destroy() end

local function make(class, props, parent)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    o.Parent=parent
    return o
end

local gui=make("ScreenGui",{Name="UltimateToolV3",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
local root=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(550,380),BackgroundColor3=C.bg,BorderSizePixel=0},gui)
make("UICorner",{CornerRadius=UDim.new(0,14)},root)
make("UIStroke",{Color=C.purple,Thickness=1.5},root)

local header=make("Frame",{Size=UDim2.new(1,0,0,64),BackgroundColor3=Color3.fromRGB(42,25,63),BorderSizePixel=0},root)
make("UICorner",{CornerRadius=UDim.new(0,14)},header)
make("Frame",{Position=UDim2.new(0,0,1,-12),Size=UDim2.new(1,0,0,12),BackgroundColor3=header.BackgroundColor3,BorderSizePixel=0},header)
make("TextLabel",{Position=UDim2.fromOffset(16,7),Size=UDim2.new(1,-65,0,28),BackgroundTransparency=1,
    Text="ULTIMATE TOOL V3",Font=Enum.Font.GothamBlack,TextSize=20,TextColor3=C.white,TextXAlignment=Enum.TextXAlignment.Left},header)
make("TextLabel",{Position=UDim2.fromOffset(17,36),Size=UDim2.new(1,-65,0,17),BackgroundTransparency=1,
    Text="PURPLE APOCALYPSE  •  MULTI-GAME CLIENT",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.purple,TextXAlignment=Enum.TextXAlignment.Left},header)
local close=make("TextButton",{Position=UDim2.new(1,-43,0,14),Size=UDim2.fromOffset(29,29),Text="×",
    BackgroundColor3=Color3.fromRGB(100,38,78),TextColor3=C.white,TextSize=21,Font=Enum.Font.GothamBold,BorderSizePixel=0},header)
make("UICorner",{CornerRadius=UDim.new(0,8)},close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Drag with mouse or touch.
do
    local drag, start, origin
    header.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            drag=true; start=input.Position; origin=root.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then drag=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if drag and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local d=input.Position-start
            root.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,origin.Y.Scale,origin.Y.Offset+d.Y)
        end
    end)
end

local side=make("Frame",{Position=UDim2.fromOffset(10,74),Size=UDim2.new(0,130,1,-84),BackgroundColor3=C.panel,BorderSizePixel=0},root)
make("UICorner",{CornerRadius=UDim.new(0,9)},side)
make("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},side)
make("UIPadding",{PaddingTop=UDim.new(0,9),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},side)
local body=make("Frame",{Position=UDim2.fromOffset(150,74),Size=UDim2.new(1,-160,1,-84),BackgroundColor3=C.panel,BorderSizePixel=0},root)
make("UICorner",{CornerRadius=UDim.new(0,9)},body)

local pages,tabs={},{}
local function page(name,n)
    local t=make("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.panel2,Text="  "..name,
        TextColor3=C.white,Font=Enum.Font.GothamSemibold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
        BorderSizePixel=0,LayoutOrder=n},side)
    make("UICorner",{CornerRadius=UDim.new(0,7)},t)
    local p=make("ScrollingFrame",{Position=UDim2.fromOffset(10,10),Size=UDim2.new(1,-20,1,-20),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.purple,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false},body)
    make("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},p)
    t.MouseButton1Click:Connect(function()
        for k,v in pairs(pages) do v.Visible=(k==name) end
        for k,v in pairs(tabs) do v.BackgroundColor3=(k==name) and C.dark or C.panel2 end
    end)
    pages[name]=p; tabs[name]=t
    return p
end
local function text(p,s,h,color,bold)
    return make("TextLabel",{Size=UDim2.new(1,-3,0,h or 34),BackgroundTransparency=1,Text=s,
        TextColor3=color or C.muted,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},p)
end
local function button(p,s,fn)
    local b=make("TextButton",{Size=UDim2.new(1,-3,0,35),BackgroundColor3=C.panel2,Text=s,
        TextColor3=C.white,Font=Enum.Font.GothamBold,TextSize=11,BorderSizePixel=0},p)
    make("UICorner",{CornerRadius=UDim.new(0,8)},b)
    b.MouseButton1Click:Connect(fn)
    return b
end

local id=game.PlaceId
local info=MODULES[id]
local home=page("Home",1)
text(home,"PURPLE APOCALYPSE ONLINE",25,C.purple,true)
text(home,"Detected: "..(info and info.name or "Unconfigured experience"),36,C.white,true)
text(home,"PlaceId: "..tostring(id),24)
text(home,info and info.status or "No adapter matched this PlaceId. Check the configured IDs.",40)
text(home,"This is a client UI framework. Server actions require authorized integration in the game's own server scripts.",55)

local modules=page("Game Modules",2)
text(modules,"GAME MODULE STATUS",25,C.purple,true)
for placeId,data in pairs(MODULES) do
    text(modules,data.name.."  |  "..tostring(placeId),24,C.white,true)
    text(modules,data.status,23)
end
text(modules,"These are adapter entries/placeholders, not proof that each game exposes admin features.",45)

local visual=page("Visual Lab",3)
text(visual,"LOCAL VISUAL EFFECTS",25,C.purple,true)
local aura=false
local highlight
local function setAura(on)
    aura=on
    if highlight then highlight:Destroy(); highlight=nil end
    if on and player.Character then
        highlight=Instance.new("Highlight")
        highlight.Name="UltimatePurpleLocalAura"
        highlight.FillColor=C.purple
        highlight.OutlineColor=Color3.fromRGB(235,205,255)
        highlight.FillTransparency=.78
        highlight.OutlineTransparency=.05
        highlight.DepthMode=Enum.HighlightDepthMode.Occluded
        highlight.Parent=player.Character
    end
end
button(visual,"TOGGLE PURPLE AURA",function() setAura(not aura) end)
button(visual,"REMOVE PURPLE AURA",function() setAura(false) end)
local fov=false
local savedFov
button(visual,"TOGGLE CINEMATIC FOV",function()
    local cam=workspace.CurrentCamera
    if not cam then return end
    if not fov then
        savedFov=cam.FieldOfView
        TweenService:Create(cam,TweenInfo.new(.35),{FieldOfView=85}):Play()
        fov=true
    else
        TweenService:Create(cam,TweenInfo.new(.35),{FieldOfView=savedFov or 70}):Play()
        fov=false
    end
end)
text(visual,"Aura and camera FOV are local-only visual changes.",35)

local settings=page("Settings",4)
text(settings,"INTERFACE SETTINGS",25,C.purple,true)
button(settings,"HIDE PANEL  •  RIGHTSHIFT TO SHOW",function() root.Visible=false end)
button(settings,"RESET PANEL POSITION",function() root.Position=UDim2.fromScale(.5,.5) end)
button(settings,"CLOSE TOOL",function() gui:Destroy() end)
text(settings,"V3 Purple Apocalypse • Client-side UI only.",30)

-- Select Home initially.
for k,v in pairs(pages) do v.Visible=(k=="Home") end
for k,v in pairs(tabs) do v.BackgroundColor3=(k=="Home") and C.dark or C.panel2 end

UIS.InputBegan:Connect(function(input,processed)
    if not processed and input.KeyCode==Enum.KeyCode.RightShift and gui.Parent then
        root.Visible=not root.Visible
    end
end)
player.CharacterAdded:Connect(function()
    task.wait(.7)
    if aura then setAura(true) end
end)
print("[Ultimate Tool V3] Loaded | PlaceId:",id,"| Game:",info and info.name or "Unconfigured")
