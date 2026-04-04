-- Dragon Blox GUI v15 | Fixed kill counter with AncestryChanged

local Players, RunService, UIS, RS, VIM = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("ReplicatedStorage"), game:GetService("VirtualInputManager")
local player, playerGui = Players.LocalPlayer, Players.LocalPlayer.PlayerGui

local cfg = {
    AutoRebirth=false, AutoFarm=false, GodMode=false, AutoHeal=false,
    SpeedBoost=false, JumpBoost=false, AutoLockOn=false, SuperFlight=false,
    SpeedAmount=50, JumpAmount=80, FlightSpeed=50,
    TargetMob="Atom X002 Army", World="3", QuestIndex=1,
    MobsKilled=0, QuestTarget=5
}

local WORLDS = {
    ["1"] = {
        mobs = {
            {name="Bandit",               npc="West City"},
            {name="Evil Thug",            npc="West City"},
            {name="Puriza Minion",        npc="Puriza Area"},
            {name="Puriza",               npc="Puriza Area"},
            {name="Coolest Minion",       npc="Coolest Area"},
            {name="Coolest",              npc="Coolest Area"},
            {name="Droid 18 Minion",      npc="Droid Area"},
            {name="Droid 17 Minion",      npc="Droid Area"},
            {name="Droid 18",             npc="Droid Area"},
            {name="Droid 17",             npc="Droid Area"},
            {name="Atom Minion",          npc="Atom Area"},
            {name="Atom",                 npc="Atom Area"},
            {name="Jinbu Minion",         npc="Jinbu Area"},
            {name="Jinbu",                npc="Jinbu Area"},
            {name="BabyVeggy Minion",     npc="Veggy Area"},
            {name="BlackKarrot Minion",   npc="BlackKarrot Area"},
            {name="Jigray Minion",        npc="Jigray Area"},
            {name="Puriza X003 army",     npc="Puriza Area"},
            {name="Puriza X003",          npc="Puriza Area"},
            {name="Atom X002 Army",       npc="Atom Area"},
            {name="Atom X002",            npc="Atom Area"},
        },
        npcs = {
            {name="West City",        folder="QuestNPCMain1_WestCity",        area="West City"},
            {name="Puriza Area",      folder="QuestNPCMain2_PurizaArea",      area="Puriza Area"},
            {name="Coolest Area",     folder="QuestNPCMain3_CoolestArea",     area="Coolest Area"},
            {name="Droid Area",       folder="QuestNPCMain4_Droid1718Area",   area="Droid1718 Area"},
            {name="Atom Area",        folder="QuestNPCMain5_AtomArea",        area="Atom Area"},
            {name="Jinbu Area",       folder="QuestNPCMain6_JinbuArea",       area="Jinbu Area"},
            {name="Veggy Area",       folder="QuestNPCMain7_VeggyArea",       area="Veggy Area"},
            {name="BlackKarrot Area", folder="QuestNPCMain8_BlackKarrotArea", area="BlackKarrot Area"},
            {name="Brawly Area",      folder="QuestNPCMain9_BrawlyArea",      area="Brawly Area"},
            {name="Jigray Area",      folder="QuestNPCMain10_JigrayArea",     area="Jigray Area"},
        }
    },
    ["3"] = {
        mobs = {
            {name="Puriza X003 army", npc="Capital City"},
            {name="Puriza X003",      npc="Capital City"},
            {name="Atom X002 Army",   npc="Tribe Village"},
            {name="Atom X002",        npc="Tribe Village"},
            {name="BrawlyX01 Army",   npc="Volcanic Island"},
            {name="BrawlyX01",        npc="Volcanic Island"},
            {name="JigrayX Army",     npc="Misty Lake"},
            {name="JigrayX",          npc="Misty Lake"},
            {name="Zero Army",        npc="Droid Waste Island"},
            {name="Zero",             npc="Droid Waste Island"},
        },
        npcs = {
            {name="Capital City",       folder="QuestNPCDroid1_PurizaX003", area="Capital City"},
            {name="Tribe Village",      folder="QuestNPCDroid2_AtomX002",   area="Tribe Village"},
            {name="Volcanic Island",    folder="QuestNPCDroid3_BrawlyX01",  area="Volcanic Island"},
            {name="Misty Lake",         folder="QuestNPCDroid4_JigrayX",    area="Misty Lake"},
            {name="Droid Waste Island", folder="QuestNPCDroid5_Zero",       area="Droid Waste Island"},
        }
    }
}

local rebirthRemote = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PlayerLevelService"):WaitForChild("RF"):WaitForChild("RequestRebirth")
local flightRemote  = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("FlightService"):WaitForChild("RE"):WaitForChild("SuperFlight")
local answerRemote  = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.4.7"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("DialogService"):WaitForChild("RF"):WaitForChild("Answer")

local function rebirth() pcall(function() rebirthRemote:InvokeServer(true) end) end
local function pressQ()
    VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    wait(0.05)
    VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end
local function punch()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

local function getNPCForMob(mobName)
    for _, m in pairs(WORLDS[cfg.World].mobs) do
        if m.name == mobName then
            for _, n in pairs(WORLDS[cfg.World].npcs) do
                if n.name == m.npc then return n end
            end
        end
    end
    return WORLDS[cfg.World].npcs[1]
end

local function teleportToPos(pos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(3,0,0)) end
end

local function getTarget()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local worldMobs = workspace:FindFirstChild("World Mobs")
    if not worldMobs then return nil end
    local closest, closestDist = nil, math.huge
    for _, folderName in pairs({"Mobs","Boss Mobs","Entities","Event Mobs"}) do
        local folder = worldMobs:FindFirstChild(folderName)
        if folder then
            for _, mob in pairs(folder:GetChildren()) do
                if mob.Name == cfg.TargetMob then
                    local mHRP = mob:FindFirstChild("HumanoidRootPart")
                    local mHum = mob:FindFirstChildOfClass("Humanoid")
                    if mHRP and mHum and mHum.Health > 0 then
                        local d = (hrp.Position - mHRP.Position).Magnitude
                        if d < closestDist then closestDist = d; closest = mob end
                    end
                end
            end
        end
    end
    return closest
end

local function teleportToNPC(npc)
    local questFolder = workspace:FindFirstChild("Misc")
        and workspace.Misc:FindFirstChild("NPC")
        and workspace.Misc.NPC:FindFirstChild("Quest")
    if questFolder then
        local npcModel = questFolder:FindFirstChild(npc.folder)
        if npcModel then
            local npcHRP = npcModel:FindFirstChild("HumanoidRootPart", true)
            if npcHRP then
                teleportToPos(npcHRP.Position)
                wait(0.5)
            end
        end
    end
end

local function doQuest(npc)
    pcall(function()
        answerRemote:InvokeServer("NPCQuest_"..npc.area, cfg.QuestIndex, npc.folder)
        wait(0.4)
        answerRemote:InvokeServer("NPCQuest_"..npc.area, 2, npc.folder)
    end)
end

-- Kill tracking using AncestryChanged (instant, no missed kills)
local trackedMobs = {}

local function trackTarget(mob)
    local id = tostring(mob)
    if trackedMobs[id] then return end
    trackedMobs[id] = true
    mob.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            trackedMobs[id] = nil
            if cfg.AutoFarm and mob.Name == cfg.TargetMob then
                cfg.MobsKilled = cfg.MobsKilled + 1
            end
        end
    end)
end

-- GUI
if playerGui:FindFirstChild("DragonBloxGUI") then playerGui.DragonBloxGUI:Destroy() end
local sg = Instance.new("ScreenGui"); sg.Name="DragonBloxGUI"; sg.ResetOnSpawn=false; sg.Parent=playerGui

local ACCENT = Color3.fromRGB(220,60,20)
local BG     = Color3.fromRGB(18,18,28)
local BTN    = Color3.fromRGB(35,35,50)
local BTN_H  = Color3.fromRGB(50,50,70)
local TEXT   = Color3.fromRGB(200,200,220)
local DIM    = Color3.fromRGB(150,150,170)
local GREEN  = Color3.fromRGB(30,110,70)
local DOT_ON = Color3.fromRGB(80,230,130)
local DOT_OFF= Color3.fromRGB(180,50,50)

local PANEL_W = 260
local main = Instance.new("Frame")
main.Size = UDim2.new(0,PANEL_W,0,520)
main.Position = UDim2.new(0,15,0.05,0)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Parent = sg
Instance.new("UICorner",main).CornerRadius = UDim.new(0,12)

local shadow = Instance.new("Frame"); shadow.Size=UDim2.new(1,10,1,10); shadow.Position=UDim2.new(0,-5,0,-5); shadow.BackgroundColor3=Color3.new(0,0,0); shadow.BackgroundTransparency=0.6; shadow.ZIndex=0; shadow.Parent=main
Instance.new("UICorner",shadow).CornerRadius=UDim.new(0,14)

local titleBar = Instance.new("Frame"); titleBar.Size=UDim2.new(1,0,0,44); titleBar.BackgroundColor3=ACCENT; titleBar.BorderSizePixel=0; titleBar.ZIndex=2; titleBar.Parent=main
Instance.new("UICorner",titleBar).CornerRadius=UDim.new(0,12)
local tFix = Instance.new("Frame"); tFix.Size=UDim2.new(1,0,0.5,0); tFix.Position=UDim2.new(0,0,0.5,0); tFix.BackgroundColor3=ACCENT; tFix.BorderSizePixel=0; tFix.ZIndex=2; tFix.Parent=titleBar
local tText = Instance.new("TextLabel"); tText.Size=UDim2.new(1,0,1,0); tText.BackgroundTransparency=1; tText.Text="🐉  Dragon Blox  v15"; tText.TextColor3=Color3.new(1,1,1); tText.Font=Enum.Font.GothamBold; tText.TextSize=15; tText.ZIndex=3; tText.Parent=titleBar

local tabBar = Instance.new("Frame"); tabBar.Size=UDim2.new(1,0,0,36); tabBar.Position=UDim2.new(0,0,0,44); tabBar.BackgroundColor3=Color3.fromRGB(12,12,20); tabBar.BorderSizePixel=0; tabBar.Parent=main
Instance.new("UIListLayout",tabBar).FillDirection=Enum.FillDirection.Horizontal

local tabs, tabPages = {}, {}
local contentFrame = Instance.new("Frame"); contentFrame.Size=UDim2.new(1,0,1,-80); contentFrame.Position=UDim2.new(0,0,0,80); contentFrame.BackgroundTransparency=1; contentFrame.Parent=main

local statusLabel = Instance.new("TextLabel"); statusLabel.Size=UDim2.new(1,-20,0,18); statusLabel.Position=UDim2.new(0,10,1,-24); statusLabel.BackgroundTransparency=1; statusLabel.TextColor3=Color3.fromRGB(100,200,100); statusLabel.Font=Enum.Font.Gotham; statusLabel.TextSize=11; statusLabel.TextXAlignment=Enum.TextXAlignment.Left; statusLabel.Text="✅ Loaded!"; statusLabel.Parent=main
local function setStatus(t) statusLabel.Text=t end

for i=1,3 do
    local page = Instance.new("ScrollingFrame")
    page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.BorderSizePixel=0
    page.ScrollBarThickness=3; page.ScrollBarImageColor3=ACCENT
    page.CanvasSize=UDim2.new(0,0,0,0); page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.Visible=(i==1); page.Parent=contentFrame
    tabPages[i]=page
    local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.PaddingTop=UDim.new(0,10); pad.PaddingBottom=UDim.new(0,10); pad.Parent=page
    Instance.new("UIListLayout",page).SortOrder=Enum.SortOrder.LayoutOrder
end

local function switchTab(idx)
    for i,t in pairs(tabs) do
        t.BackgroundColor3 = i==idx and ACCENT or Color3.fromRGB(12,12,20)
        t.TextColor3 = i==idx and Color3.new(1,1,1) or DIM
        tabPages[i].Visible=(i==idx)
    end
end

for i,name in pairs({"⚔️ Farm","🤖 Auto","✈️ Move"}) do
    local tb=Instance.new("TextButton")
    tb.Size=UDim2.new(0,PANEL_W/3,1,0); tb.BackgroundColor3=i==1 and ACCENT or Color3.fromRGB(12,12,20)
    tb.TextColor3=i==1 and Color3.new(1,1,1) or DIM; tb.Text=name
    tb.Font=Enum.Font.GothamBold; tb.TextSize=11; tb.BorderSizePixel=0; tb.AutoButtonColor=false
    tb.LayoutOrder=i; tb.Parent=tabBar
    tb.MouseButton1Click:Connect(function() switchTab(i) end)
    tabs[i]=tb
end

local function makeToggle(page, name, icon, key, onEnable, onDisable)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,40); btn.BackgroundColor3=BTN; btn.TextColor3=TEXT
    btn.Text=icon.."  "..name; btn.Font=Enum.Font.Gotham; btn.TextSize=13
    btn.AutoButtonColor=false; btn.BorderSizePixel=0; btn.Parent=page
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,8,0,8); dot.Position=UDim2.new(1,-14,0.5,-4); dot.BackgroundColor3=DOT_OFF; dot.BorderSizePixel=0; dot.Parent=btn
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    btn.MouseButton1Click:Connect(function()
        cfg[key]=not cfg[key]
        if cfg[key] then
            btn.BackgroundColor3=GREEN; dot.BackgroundColor3=DOT_ON; btn.TextColor3=Color3.new(1,1,1)
            if onEnable then onEnable() end
        else
            btn.BackgroundColor3=BTN; dot.BackgroundColor3=DOT_OFF; btn.TextColor3=TEXT
            if onDisable then onDisable() end
        end
    end)
    btn.MouseEnter:Connect(function() if not cfg[key] then btn.BackgroundColor3=BTN_H end end)
    btn.MouseLeave:Connect(function() if not cfg[key] then btn.BackgroundColor3=BTN end end)
    return btn
end

local function makeLabel(page, text)
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,18); lbl.BackgroundTransparency=1
    lbl.TextColor3=DIM; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Text=text; lbl.Parent=page
    return lbl
end

local function makeDivider(page)
    local d=Instance.new("Frame"); d.Size=UDim2.new(1,0,0,1); d.BackgroundColor3=Color3.fromRGB(40,40,60); d.BorderSizePixel=0; d.Parent=page
end

local function makeDualBtn(page, labelA, labelB, onA, onB)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,34); row.BackgroundTransparency=1; row.Parent=page
    local bA=Instance.new("TextButton"); bA.Size=UDim2.new(0.48,0,1,0); bA.BackgroundColor3=ACCENT; bA.TextColor3=Color3.new(1,1,1); bA.Text=labelA; bA.Font=Enum.Font.GothamBold; bA.TextSize=12; bA.BorderSizePixel=0; bA.Parent=row
    Instance.new("UICorner",bA).CornerRadius=UDim.new(0,8)
    local bB=Instance.new("TextButton"); bB.Size=UDim2.new(0.48,0,1,0); bB.Position=UDim2.new(0.52,0,0,0); bB.BackgroundColor3=BTN; bB.TextColor3=TEXT; bB.Text=labelB; bB.Font=Enum.Font.GothamBold; bB.TextSize=12; bB.BorderSizePixel=0; bB.Parent=row
    Instance.new("UICorner",bB).CornerRadius=UDim.new(0,8)
    bA.MouseButton1Click:Connect(function() bA.BackgroundColor3=ACCENT; bA.TextColor3=Color3.new(1,1,1); bB.BackgroundColor3=BTN; bB.TextColor3=TEXT; onA() end)
    bB.MouseButton1Click:Connect(function() bB.BackgroundColor3=ACCENT; bB.TextColor3=Color3.new(1,1,1); bA.BackgroundColor3=BTN; bA.TextColor3=TEXT; onB() end)
    return bA, bB
end

-- ============================================================
-- TAB 1: FARM
-- ============================================================
local p1 = tabPages[1]
makeToggle(p1,"Auto Farm","⚔️","AutoFarm",
    function() cfg.MobsKilled=0; trackedMobs={} end,
    function() cfg.MobsKilled=0; trackedMobs={} end
)
makeDivider(p1)
makeLabel(p1,"  🌍  World")

local worldRow=Instance.new("Frame"); worldRow.Size=UDim2.new(1,0,0,34); worldRow.BackgroundTransparency=1; worldRow.Parent=p1
local wbA=Instance.new("TextButton"); wbA.Size=UDim2.new(0.48,0,1,0); wbA.BackgroundColor3=BTN; wbA.TextColor3=TEXT; wbA.Text="World 1"; wbA.Font=Enum.Font.GothamBold; wbA.TextSize=12; wbA.BorderSizePixel=0; wbA.Parent=worldRow
Instance.new("UICorner",wbA).CornerRadius=UDim.new(0,8)
local wbB=Instance.new("TextButton"); wbB.Size=UDim2.new(0.48,0,1,0); wbB.Position=UDim2.new(0.52,0,0,0); wbB.BackgroundColor3=ACCENT; wbB.TextColor3=Color3.new(1,1,1); wbB.Text="World 3"; wbB.Font=Enum.Font.GothamBold; wbB.TextSize=12; wbB.BorderSizePixel=0; wbB.Parent=worldRow
Instance.new("UICorner",wbB).CornerRadius=UDim.new(0,8)

makeDivider(p1)
makeLabel(p1,"  ⚔️  Select Mob  →  Quest Auto-Handled")

local mobListFrame=Instance.new("Frame"); mobListFrame.Size=UDim2.new(1,0,0,10); mobListFrame.AutomaticSize=Enum.AutomaticSize.Y; mobListFrame.BackgroundTransparency=1; mobListFrame.Parent=p1
Instance.new("UIListLayout",mobListFrame).Padding=UDim.new(0,4)
local mobRows={}

local function buildMobList()
    for _,r in pairs(mobRows) do r:Destroy() end
    mobRows={}
    for i,mob in pairs(WORLDS[cfg.World].mobs) do
        local row=Instance.new("TextButton")
        row.Size=UDim2.new(1,0,0,38); row.BackgroundColor3=mob.name==cfg.TargetMob and GREEN or BTN
        row.BorderSizePixel=0; row.AutoButtonColor=false; row.LayoutOrder=i; row.Parent=mobListFrame
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local mName=Instance.new("TextLabel"); mName.Size=UDim2.new(1,-10,0.5,0); mName.Position=UDim2.new(0,10,0,0); mName.BackgroundTransparency=1; mName.TextColor3=Color3.new(1,1,1); mName.Font=Enum.Font.GothamBold; mName.TextSize=12; mName.TextXAlignment=Enum.TextXAlignment.Left; mName.Text=mob.name; mName.Parent=row
        local mNPC=Instance.new("TextLabel"); mNPC.Size=UDim2.new(1,-10,0.5,0); mNPC.Position=UDim2.new(0,10,0.5,0); mNPC.BackgroundTransparency=1; mNPC.TextColor3=DIM; mNPC.Font=Enum.Font.Gotham; mNPC.TextSize=10; mNPC.TextXAlignment=Enum.TextXAlignment.Left; mNPC.Text="📍 "..mob.npc; mNPC.Parent=row
        local capturedMob=mob
        row.MouseButton1Click:Connect(function()
            cfg.TargetMob=capturedMob.name; cfg.MobsKilled=0
            trackedMobs={}
            setStatus("Target: "..capturedMob.name.." → "..capturedMob.npc)
            buildMobList()
        end)
        row.MouseEnter:Connect(function() if capturedMob.name~=cfg.TargetMob then row.BackgroundColor3=BTN_H end end)
        row.MouseLeave:Connect(function() if capturedMob.name~=cfg.TargetMob then row.BackgroundColor3=BTN end end)
        table.insert(mobRows,row)
    end
end

local function switchWorld(w, btnOn, btnOff)
    cfg.World=w; cfg.TargetMob=WORLDS[w].mobs[1].name; cfg.MobsKilled=0
    trackedMobs={}
    btnOn.BackgroundColor3=ACCENT; btnOn.TextColor3=Color3.new(1,1,1)
    btnOff.BackgroundColor3=BTN; btnOff.TextColor3=TEXT
    buildMobList(); setStatus("Switched to World "..w)
end

wbA.MouseButton1Click:Connect(function() switchWorld("1",wbA,wbB) end)
wbB.MouseButton1Click:Connect(function() switchWorld("3",wbB,wbA) end)
buildMobList()

-- ============================================================
-- TAB 2: AUTO
-- ============================================================
local p2=tabPages[2]
makeToggle(p2,"Auto Rebirth","🔄","AutoRebirth")
makeToggle(p2,"Auto Lock-On","🎯","AutoLockOn")
makeToggle(p2,"God Mode","💀","GodMode")
makeToggle(p2,"Auto Heal (press V first)","💚","AutoHeal")
makeDivider(p2)
makeLabel(p2,"  📜  Quest Type")
makeDualBtn(p2,"Army (5 kills)","Boss (1 kill)",
    function() cfg.QuestIndex=1; cfg.QuestTarget=5; cfg.MobsKilled=0; setStatus("Quest: Army (5 kills)") end,
    function() cfg.QuestIndex=2; cfg.QuestTarget=1; cfg.MobsKilled=0; setStatus("Quest: Boss (1 kill)") end
)

-- ============================================================
-- TAB 3: MOVE
-- ============================================================
local p3=tabPages[3]
makeToggle(p3,"Speed Boost","💨","SpeedBoost",nil,function()
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed=16 end
end)
makeToggle(p3,"Jump Boost","🦘","JumpBoost",nil,function()
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower=50 end
end)
makeToggle(p3,"Super Flight","✈️","SuperFlight",
    function() pcall(function() flightRemote:FireServer(false) end) end,
    function() cfg.SuperFlight=false end
)
makeDivider(p3)
makeLabel(p3,"  ✈️  Flight Speed")

local sliderRow=Instance.new("Frame"); sliderRow.Size=UDim2.new(1,0,0,40); sliderRow.BackgroundTransparency=1; sliderRow.Parent=p3
local fsVal=Instance.new("TextLabel"); fsVal.Size=UDim2.new(1,0,0,18); fsVal.BackgroundTransparency=1; fsVal.TextColor3=Color3.new(1,1,1); fsVal.Font=Enum.Font.GothamBold; fsVal.TextSize=13; fsVal.Text="50"; fsVal.Parent=sliderRow
local track=Instance.new("Frame"); track.Size=UDim2.new(1,0,0,8); track.Position=UDim2.new(0,0,0,24); track.BackgroundColor3=BTN_H; track.BorderSizePixel=0; track.Parent=sliderRow
Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
local fill=Instance.new("Frame"); fill.Size=UDim2.new(0.042,0,1,0); fill.BackgroundColor3=ACCENT; fill.BorderSizePixel=0; fill.Parent=track
Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
local knob=Instance.new("TextButton"); knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0.042,-9,0.5,-9); knob.BackgroundColor3=Color3.new(1,1,1); knob.Text=""; knob.BorderSizePixel=0; knob.ZIndex=5; knob.Parent=track
Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

local sliding=false
local function updateSlider(x)
    local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
    cfg.FlightSpeed=math.floor(10+990*rel)
    fill.Size=UDim2.new(rel,0,1,0); knob.Position=UDim2.new(rel,-9,0.5,-9)
    fsVal.Text=tostring(cfg.FlightSpeed)
end
knob.MouseButton1Down:Connect(function() sliding=true end)
track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; updateSlider(i.Position.X) end end)
UIS.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then updateSlider(i.Position.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)

makeLabel(p3,"  💨  Walk Speed")
local wsRow=Instance.new("Frame"); wsRow.Size=UDim2.new(1,0,0,28); wsRow.BackgroundTransparency=1; wsRow.Parent=p3
local wsDisp=Instance.new("TextLabel"); wsDisp.Size=UDim2.new(0.3,0,1,0); wsDisp.BackgroundTransparency=1; wsDisp.TextColor3=Color3.new(1,1,1); wsDisp.Font=Enum.Font.GothamBold; wsDisp.TextSize=13; wsDisp.Text="50"; wsDisp.Parent=wsRow
local wsMinus=Instance.new("TextButton"); wsMinus.Size=UDim2.new(0,28,0,28); wsMinus.Position=UDim2.new(0.3,0,0,0); wsMinus.BackgroundColor3=BTN; wsMinus.TextColor3=Color3.new(1,1,1); wsMinus.Text="-"; wsMinus.Font=Enum.Font.GothamBold; wsMinus.TextSize=16; wsMinus.BorderSizePixel=0; wsMinus.Parent=wsRow
Instance.new("UICorner",wsMinus).CornerRadius=UDim.new(0,6)
local wsPlus=Instance.new("TextButton"); wsPlus.Size=UDim2.new(0,28,0,28); wsPlus.Position=UDim2.new(0.3,32,0,0); wsPlus.BackgroundColor3=BTN; wsPlus.TextColor3=Color3.new(1,1,1); wsPlus.Text="+"; wsPlus.Font=Enum.Font.GothamBold; wsPlus.TextSize=16; wsPlus.BorderSizePixel=0; wsPlus.Parent=wsRow
Instance.new("UICorner",wsPlus).CornerRadius=UDim.new(0,6)
wsMinus.MouseButton1Click:Connect(function() cfg.SpeedAmount=math.max(16,cfg.SpeedAmount-10); wsDisp.Text=tostring(cfg.SpeedAmount) end)
wsPlus.MouseButton1Click:Connect(function() cfg.SpeedAmount=math.min(500,cfg.SpeedAmount+10); wsDisp.Text=tostring(cfg.SpeedAmount) end)

makeLabel(p3,"  🦘  Jump Power")
local jpRow=Instance.new("Frame"); jpRow.Size=UDim2.new(1,0,0,28); jpRow.BackgroundTransparency=1; jpRow.Parent=p3
local jpDisp=Instance.new("TextLabel"); jpDisp.Size=UDim2.new(0.3,0,1,0); jpDisp.BackgroundTransparency=1; jpDisp.TextColor3=Color3.new(1,1,1); jpDisp.Font=Enum.Font.GothamBold; jpDisp.TextSize=13; jpDisp.Text="80"; jpDisp.Parent=jpRow
local jpMinus=Instance.new("TextButton"); jpMinus.Size=UDim2.new(0,28,0,28); jpMinus.Position=UDim2.new(0.3,0,0,0); jpMinus.BackgroundColor3=BTN; jpMinus.TextColor3=Color3.new(1,1,1); jpMinus.Text="-"; jpMinus.Font=Enum.Font.GothamBold; jpMinus.TextSize=16; jpMinus.BorderSizePixel=0; jpMinus.Parent=jpRow
Instance.new("UICorner",jpMinus).CornerRadius=UDim.new(0,6)
local jpPlus=Instance.new("TextButton"); jpPlus.Size=UDim2.new(0,28,0,28); jpPlus.Position=UDim2.new(0.3,32,0,0); jpPlus.BackgroundColor3=BTN; jpPlus.TextColor3=Color3.new(1,1,1); jpPlus.Text="+"; jpPlus.Font=Enum.Font.GothamBold; jpPlus.TextSize=16; jpPlus.BorderSizePixel=0; jpPlus.Parent=jpRow
Instance.new("UICorner",jpPlus).CornerRadius=UDim.new(0,6)
jpMinus.MouseButton1Click:Connect(function() cfg.JumpAmount=math.max(50,cfg.JumpAmount-10); jpDisp.Text=tostring(cfg.JumpAmount) end)
jpPlus.MouseButton1Click:Connect(function() cfg.JumpAmount=math.min(500,cfg.JumpAmount+10); jpDisp.Text=tostring(cfg.JumpAmount) end)

-- Drag
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=i.Position; startPos=main.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
    end
end)
titleBar.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then dragInput=i end end)
UIS.InputChanged:Connect(function(i)
    if i==dragInput and dragging then
        local d=i.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

-- ============================================================
-- LOOPS
-- ============================================================

RunService.Heartbeat:Connect(function()
    local char=player.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if cfg.SpeedBoost then hum.WalkSpeed=cfg.SpeedAmount end
    if cfg.JumpBoost then hum.JumpPower=cfg.JumpAmount end
    if cfg.GodMode then hum.Health=hum.MaxHealth end
    if cfg.SuperFlight then
        local bv=hrp:FindFirstChild("FLIGHT_MOVING_BODYVELOCITY")
        if bv and bv.Velocity.Magnitude>1 then
            bv.Velocity=bv.Velocity.Unit*cfg.FlightSpeed
            bv.MaxForce=Vector3.new(1e9,1e9,1e9)
        end
    end
end)

spawn(function()
    while true do wait(1)
        if cfg.AutoRebirth then rebirth() end
    end
end)

-- Auto Heal spam (press V once to activate, then toggle in GUI)
spawn(function()
    while true do wait(0.1)
        if cfg.AutoHeal then
            VIM:SendKeyEvent(true, Enum.KeyCode.V, false, game)
            wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.V, false, game)
        end
    end
end)

local lockOnActive=false
spawn(function()
    while true do wait(0.1)
        if cfg.AutoLockOn and not lockOnActive then
            lockOnActive=true; pressQ()
        elseif not cfg.AutoLockOn and lockOnActive then
            lockOnActive=false; pressQ()
        end
    end
end)

local questInProgress=false
spawn(function()
    while true do wait(0.15)
        if not cfg.AutoFarm then questInProgress=false; continue end
        local char=player.Character; if not char then continue end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end

        if cfg.MobsKilled >= cfg.QuestTarget and not questInProgress then
            questInProgress=true
            local npc=getNPCForMob(cfg.TargetMob)
            if npc then
                setStatus("📜 "..cfg.MobsKilled.." kills! Going to "..npc.name.."...")
                teleportToNPC(npc)
                doQuest(npc)
                cfg.MobsKilled=0
                trackedMobs={}
                setStatus("✅ Quest done! Farming again...")
                wait(0.5)
            end
            questInProgress=false
            continue
        end

        local target=getTarget()
        if not target then
            setStatus("⏳ Waiting for mobs... ("..cfg.MobsKilled.."/"..cfg.QuestTarget.." killed)")
            continue
        end
        local tHRP=target:FindFirstChild("HumanoidRootPart"); if not tHRP then continue end
        local dist=(hrp.Position-tHRP.Position).Magnitude
        if dist > 8 then
            hrp.CFrame=CFrame.new(tHRP.Position+Vector3.new(3,0,0))
        else
            hrp.CFrame=CFrame.lookAt(hrp.Position, tHRP.Position)
            trackTarget(target)
            pressQ(); wait(0.05); punch()
        end
    end
end)

print("✅ Dragon Blox GUI v15 Loaded!")
