-- made by @kppl. with the help of ai (100% ai)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PF = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local PhysicsService = game:GetService("PhysicsService")
local LP = Players.LocalPlayer
local LOGO_ID = "130015817289840"
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local function notify(title, text, dur)
	pcall(function()
		WindUI:Notify({ Title = title, Content = text, Duration = dur or 4 })
	end)
end
local KEY_LIST_URL = "https://pastebin.com/raw/DgJy7H9A"
local KILL_SWITCH_URL = "https://raw.githubusercontent.com/xJakeTzyx/Script/refs/heads/main/ok" -- must return "on" to run; "off"/down = kill; "" skips the check
local LOCAL_KEYS = { "imongmama" }
local DISCORD_INVITE = "https://discord.gg/rHDbekfmNg" -- <-- put your real invite here
local function httpGet(url)
	local ok, body = pcall(function() return game:HttpGet(url, true) end)
	if ok and type(body) == "string" then return body end
	return nil
end
local function trim(s) return (s:gsub("%s+$", ""):gsub("^%s+", "")) end
local function buildKeyList()
	local keys = {}
	for _, k in ipairs(LOCAL_KEYS) do keys[#keys + 1] = k end
	if KEY_LIST_URL ~= "" then
		local body = httpGet(KEY_LIST_URL)
		if body then
			for line in body:gmatch("[^\r\n]+") do
				line = trim(line)
				if #line > 0 then keys[#keys + 1] = line end
			end
		end
	end
	return keys
end
-- fail-safe kill switch. Returns true ONLY if the switch says "on". Down/off/blank body = false.
local function killSwitchAllows()
	if KILL_SWITCH_URL == "" then return true end -- no switch configured -> allow (testing)
	local body = httpGet(KILL_SWITCH_URL)
	if not body then return false end -- link down/unreachable -> kill
	if trim(body):lower():find("on") then return true end
	return false -- "off" or anything without "on" -> kill
end
if not killSwitchAllows() then
	notify("DweeybzSCRPT", "Hub is currently disabled. Check back later.", 8)
	return
end
local VALID_KEYS = buildKeyList()
-- Get Key -> copy the Discord invite to clipboard and notify.
local function copyDiscordToClipboard()
	if typeof(setclipboard) == "function" then
		pcall(function() setclipboard(DISCORD_INVITE) end)
		notify("Copied Discord Server", "get a key on server", 6)
	end
end
local SYSTEM_ENABLED = false
local DELIVERY_RUNNING = false
local MOOD_ACTIVE = false
local DRIVE_ACTIVE = false
local driveConn = nil
local AUTO_MOOD_ENABLED = true
local MOOD_METHOD = 2
local FUN_OK = false
_G.PIZZA_SPEED = 64
_G.PIZZA_MOOD_THRESH = 30 -- legacy (house method now uses per-mood triggers below)
_G.PIZZA_FOOD = "Pear"
_G.FOOD_DIST = 45
_G.HYGIENE_DIST = 180
_G.SHOW_MOOD_VIS = false
_G.HUNGER_TRIGGER = 75
_G.HYGIENE_TRIGGER = 68
_G.FUN_TRIGGER = 99
_G.ENERGY_TRIGGER = 30
local Y_OFFSET = 3
local WAYPOINT_REACH = 6
local BOX_POS = Vector3.new(-50.19, 4.46, -39.95)
local BOX_REACH = 4
local CUST_REACH = 6
local SHOW_PATH = false
local FOOD_TARGET = Vector3.new(-64.95, 4.46, -72.35)
local HYGIENE_TARGET = Vector3.new(-263.98, -0.81, -336.07)
local FOOD_ORIGIN_NEAR = Vector3.new(-61.9116211, 3.9343996, -71.4394989)
local SHOWER_POS = Vector3.new(-259.851074, 0.044932276, -336.881439)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- GUIDING ARROW HOOK
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local customerTarget = nil
local customerConfirmed = false
local arrowHooked = false
local function hookGuidingArrow()
	if arrowHooked then return end
	local GAS = nil
	if getgc then
		for _, obj in ipairs(getgc(true)) do
			if type(obj) == "table" and rawget(obj, "StartGuiding") and rawget(obj, "StopGuiding") and rawget(obj, "CreateArrow") then
				GAS = obj; break
			end
		end
	end
	if not GAS then pcall(function() GAS = require(RS.Modules.GuidingArrowService) end) end
	if not GAS then return end
	local origStart = GAS.StartGuiding
	GAS.StartGuiding = function(self, source, target, ...)
		local args = {...}
		local foundKey, foundTarget = nil, nil
		if typeof(target) == "Vector3" then foundTarget = target
		elseif typeof(target) == "CFrame" then foundTarget = target.Position end
		for _, v in ipairs(args) do
			if type(v) == "string" and v:find("PizzaDelivery") then foundKey = v; break end
		end
		if foundKey and foundTarget then
			customerTarget = foundTarget
			customerConfirmed = false
		end
		return origStart(self, source, target, ...)
	end
	local origStop = GAS.StopGuiding
	GAS.StopGuiding = function(self, key, ...)
		if type(key) == "string" and key:find("PizzaDelivery") then
			customerConfirmed = true
		end
		return origStop(self, key, ...)
	end
	arrowHooked = true
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- MODULES
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local handler
pcall(function() handler = require(LP.PlayerScripts.Modules.InteractionHandler) end)
if not (handler and handler.ShowMenu) and getgc then
	for _, o in ipairs(getgc(true)) do
		if type(o) == "table" and rawget(o, "ShowMenu") and rawget(o, "IsInitialized") then handler = o; break end
	end
end
assert(handler and handler.ShowMenu, "InteractionHandler not found")
local ID = require(RS.Modules.InteractionData)
local SG = require(RS.Modules._Utilities.StatGetter)
local INTERACT_DIST = ID.INTERACTION_DISTANCE or 10
local function openMenu(obj)
	local origin = ID:GetOrigin(obj, 6); if not origin then return nil end
	local radius = obj:GetAttribute("OverrideInteractRadius") or INTERACT_DIST
	return handler:ShowMenu(obj, origin.Position, origin, nil, nil, radius)
end
local function clickByText(menu, text, pages)
	text = text:lower()
	for _ = 1, (pages or 12) do
		task.wait(0.1); if not menu:IsOpen() then return false end
		local more
		for _, b in pairs(menu.Buttons) do
			if b.Text then local lt = b.Text:lower()
				if lt:find(text, 1, true) then menu:ClickData(b); return true end
				if lt:find("more") then more = b end
			end
		end
		if more then menu:ClickData(more) else break end
	end; return false
end
local function interact(obj, ...)
	local menu = openMenu(obj); if not menu then return false end
	task.wait(0.15); if not menu:IsOpen() then return false end
	for _, step in ipairs({...}) do if not clickByText(menu, step) then return false end; task.wait(0.25) end
	return true
end
local function interactSelf(...)
	local root = LP.Character and (LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character.PrimaryPart)
	if not root then return false end
	local menu = handler:ShowMenu(LP, root.CFrame)
	if not menu then return false end
	task.wait(0.15)
	if not menu:IsOpen() then return false end
	for _, step in ipairs({...}) do if not clickByText(menu, step) then return false end; task.wait(0.2) end
	return true
end
local function fireBtn(btn)
	if not btn then return false end; local fired = false
	if getconnections then
		for _, sig in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down"}) do
			pcall(function() for _, c in ipairs(getconnections(btn[sig])) do c:Fire(); fired=true end end)
		end
	end
	if not fired and firesignal then pcall(function() firesignal(btn.Activated); fired=true end) end
	return fired
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- REFS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function getPizzaENV() local e=workspace:FindFirstChild("Environment");if not e then return nil end;local l=e:FindFirstChild("Locations");if not l then return nil end;local c=l:FindFirstChild("City");if not c then return nil end;return c:FindFirstChild("PizzaPlanet") end
local function getDeliveryMoped() local e=getPizzaENV();if not e then return nil end;local g=e:FindFirstChild("Geometry");if not g then return nil end;return g:FindFirstChild("DeliveryMoped") end
local function getConveyorBoxes() local e=getPizzaENV();if not e then return nil end;local i=e:FindFirstChild("Interior");if not i then return nil end;local v=i:FindFirstChild("Conveyor");if not v then return nil end;return v:FindFirstChild("MovingBoxes") end
local function getSpawnedChars() local g=workspace:FindFirstChild("_game");if not g then return nil end;return g:FindFirstChild("SpawnedCharacters") end
local function waitForPizzaEnv(timeout) local deadline=tick()+(timeout or 20);while tick()<deadline do if getConveyorBoxes() then return true end;task.wait(0.5) end;return false end
local function getMoped() local m=workspace:FindFirstChild(LP.Name);return m and m:FindFirstChild("Vehicle_Delivery Moped") end
local function getMopedBody() local moped=getMoped();return moped and moped:FindFirstChild("Body") end
local function getParkedMoped()
	local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
	local plot=plots:FindFirstChild("Plot_"..LP.Name); if not plot then return nil end
	local sv=plot:FindFirstChild("SpawnedVehicles"); if not sv then return nil end
	return sv:FindFirstChild("Vehicle_Delivery Moped")
end
local function mopedPos() local b=getMopedBody();return b and b.Position end
local function charRoot() local c=LP.Character;return c and c:FindFirstChild("HumanoidRootPart") end
local function getHumanoid() local c=LP.Character;return c and c:FindFirstChildOfClass("Humanoid") end
local function objWorldPos(o)
	if not o then return nil end
	if o:IsA("BasePart") then return o.Position end
	if o:IsA("Model") then return o:GetPivot().Position end
	local part=o:FindFirstChildWhichIsA("BasePart",true)
	return part and part.Position
end
local function getFoodOrigin()
	local env=getPizzaENV();if not env then return nil end
	local oo=env:FindFirstChild("OrderOrigins");if not oo then return nil end
	local best,bestD=nil,math.huge
	for _,c in ipairs(oo:GetChildren()) do
		local pos=objWorldPos(c)
		if pos then local d=(pos-FOOD_ORIGIN_NEAR).Magnitude;if d<bestD then best,bestD=c,d end end
	end
	return best
end
local function getShower()
	local env=workspace:FindFirstChild("Environment")
	local loc=env and env:FindFirstChild("Locations")
	local beach=loc and loc:FindFirstChild("Beach")
	local city=beach and beach:FindFirstChild("CityBeach")
	if not city then return nil end
	local best,bestD=nil,8
	for _,c in ipairs(city:GetChildren()) do
		local set=c:FindFirstChild("Basic Shower Set")
		if set then
			local part=set:IsA("BasePart") and set or set:FindFirstChildWhichIsA("BasePart",true)
			if part then local d=(part.Position-SHOWER_POS).Magnitude;if d<bestD then best,bestD=set,d end end
		end
	end
	return best
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- EQUIP / UNEQUIP
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local RATTLE_EQUIPPED = false
local PLATE_EQUIPPED = false
local hotbarRef = nil
local function getHotbar()
	if hotbarRef and hotbarRef.Parent then return hotbarRef end
	local ok,hb=pcall(function() return LP.PlayerGui.HUDGui.Hotbar end)
	if ok then hotbarRef=hb end
	return hotbarRef
end
local function hasEquippedTool() return RATTLE_EQUIPPED end
local function hasEquippedPlate() return PLATE_EQUIPPED end
local function equipSlot1()
	local hb=getHotbar();if not hb then return end
	local b=hb:FindFirstChild("Baby Rattle",true)
	if b then fireBtn(b);RATTLE_EQUIPPED=true end
end
local function findVisibleUnequipButton()
	local hb=getHotbar(); if not hb then return nil end
	for _,b in ipairs(hb:GetDescendants()) do
		if b.Name=="UnequipButton" and (b:IsA("ImageButton") or b:IsA("TextButton")) and b.Visible then
			return b
		end
	end
	return nil
end
local function unequipTools()
	for _=1,8 do
		local btn=findVisibleUnequipButton()
		if not btn then break end
		fireBtn(btn)
		task.wait(0.15)
	end
	RATTLE_EQUIPPED=false
	PLATE_EQUIPPED=false
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- NOCLIP (collision-group based)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local NOCLIP_GROUP = "OpusMopedNoclip"
local groupReady = false
do
	pcall(function()
		if typeof(PhysicsService.RegisterCollisionGroup) == "function" then
			pcall(function() PhysicsService:RegisterCollisionGroup(NOCLIP_GROUP) end)
			pcall(function() PhysicsService:CollisionGroupSetCollidable(NOCLIP_GROUP, "Default", false) end)
			pcall(function() PhysicsService:CollisionGroupSetCollidable(NOCLIP_GROUP, NOCLIP_GROUP, false) end)
			groupReady = true
		end
	end)
end
local function setPartGroup(pt, groupName)
	if not (pt and pt:IsA("BasePart")) then return end
	pcall(function() pt.CollisionGroup = groupName end)
end
local noclipConn=nil
local mopedAddedConn=nil
local function worldNoclip(_) end
local function forEachManagedPart(fn)
	local mp = getMoped(); if mp then for _,pt in ipairs(mp:GetDescendants()) do if pt:IsA("BasePart") then fn(pt) end end end
	local pk = getParkedMoped(); if pk then for _,pt in ipairs(pk:GetDescendants()) do if pt:IsA("BasePart") then fn(pt) end end end
	local ch = LP.Character; if ch then for _,pt in ipairs(ch:GetDescendants()) do if pt:IsA("BasePart") then fn(pt) end end end
end
local function reassertNoclip()
	forEachManagedPart(function(pt)
		if groupReady then setPartGroup(pt, NOCLIP_GROUP) end
		pcall(function() pt.CanCollide=false end)
	end)
end
local function isMopedPart(part)
	if not part:IsA("BasePart") then return false end
	local a = part
	while a and a ~= workspace do
		if a.Name == "Vehicle_Delivery Moped" then return true end
		a = a.Parent
	end
	return false
end
local function setNoclip(active)
	if noclipConn then noclipConn:Disconnect();noclipConn=nil end
	if mopedAddedConn then mopedAddedConn:Disconnect();mopedAddedConn=nil end
	if not active then
		forEachManagedPart(function(pt)
			if groupReady then setPartGroup(pt, "Default") end
			pt.CanCollide = true
		end)
		return
	end
	forEachManagedPart(function(pt)
		if groupReady then setPartGroup(pt, NOCLIP_GROUP) end
		pt.CanCollide = false
	end)
	noclipConn=RunService.Stepped:Connect(function()
		forEachManagedPart(function(pt)
			if groupReady and pt.CollisionGroup ~= NOCLIP_GROUP then setPartGroup(pt, NOCLIP_GROUP) end
			if pt.CanCollide then pt.CanCollide=false end
		end)
	end)
	mopedAddedConn=workspace.DescendantAdded:Connect(function(d)
		if isMopedPart(d) then
			task.defer(function()
				if d and d.Parent and d:IsA("BasePart") then
					if groupReady then setPartGroup(d, NOCLIP_GROUP) end
					pcall(function() d.CanCollide=false end)
				end
			end)
		end
	end)
end
local function enterPathPhase() worldNoclip(false);setNoclip(false) end
local function enterRidePhase() setNoclip(true);worldNoclip(true) end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- DRIVE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local driveTarget=nil
local function enableDrive()
	if DRIVE_ACTIVE then return end;DRIVE_ACTIVE=true;enterRidePhase()
	driveConn=RunService.Heartbeat:Connect(function(dt)
		if not DRIVE_ACTIVE or not driveTarget then return end
		local body=getMopedBody();if not body then return end
		local target=driveTarget+Vector3.new(0,Y_OFFSET,0)
		local pos=body.Position;local diff=target-pos
		if diff.Magnitude<1 then return end
		local speed=_G.PIZZA_SPEED or 50
		local moveDir=diff.Unit;local step=speed*dt
		local newPos=pos+moveDir*math.min(step,diff.Magnitude)
		local flatDir=(diff*Vector3.new(1,0,1))
		if flatDir.Magnitude>0.1 then body.CFrame=CFrame.lookAt(newPos,newPos+flatDir.Unit)
		else body.CFrame=CFrame.new(newPos)*(body.CFrame-body.CFrame.Position) end
		body.AssemblyLinearVelocity=Vector3.new(0,0,0)
		body.AssemblyAngularVelocity=Vector3.new(0,0,0)
	end)
end
local function disableDrive()
	if not DRIVE_ACTIVE then return end;DRIVE_ACTIVE=false
	if driveConn then driveConn:Disconnect();driveConn=nil end
	driveTarget=nil;enterPathPhase()
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- PATH MODIFIERS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function Add_Modifiers(Folder,Label)
	if not Folder then return end
	local function Apply(obj) if obj:IsA("BasePart") then local m=obj:FindFirstChildOfClass("PathfindingModifier");if not m then m=Instance.new("PathfindingModifier");m.Parent=obj end;m.Label=Label end end
	for _,obj in ipairs(Folder:GetDescendants()) do Apply(obj) end
	Folder.DescendantAdded:Connect(function(obj) Apply(obj) end)
end
task.spawn(function() pcall(function()
	local Env=workspace.Environment;local PP=Env.Locations.City.PizzaPlanet;local Ent=PP.Exterior.Entrance;local Int=PP.Interior
	local Tables=Env.DetailObjects["Outdoor Perforated Metal Table"]
	if Tables then for _,o in ipairs(Tables:GetChildren()) do local m=o:FindFirstChild("ObjectModel");if m then Add_Modifiers(m,"Pizza_Table") end end end
	for _,o in ipairs(Int:GetDescendants()) do if string.find(o.Name,"Counter") then Add_Modifiers(o,"Pizza_Counter") end end
	Add_Modifiers(Ent:FindFirstChild("Model-M"),"Pizza_Entrance");Add_Modifiers(Ent:FindFirstChild("Model"),"Pizza_Entrance")
	pcall(function() Add_Modifiers(Env.TaxiStands,"Taxi_Stands") end)
	pcall(function() Add_Modifiers(Env.RoadsNetwork.Network.Roads,"Roads") end)
	pcall(function() Add_Modifiers(Env.RoadsNetwork.Sidewalk,"Side_Walk") end)
	pcall(function() Add_Modifiers(Env["World Lights"],"World_Lights") end)
	pcall(function() Add_Modifiers(Env.Foliage.Trees,"Trees") end)
	pcall(function() Add_Modifiers(Env.RentalVehicles,"Rental_Vehicles") end)
	pcall(function() Add_Modifiers(Env.DetailObjects["Fire Hydrant"],"Fire_Hydrant") end)
	pcall(function() Add_Modifiers(Int.Seats,"Pizza_Seats") end)
	pcall(function() Add_Modifiers(Env.Details.HillsideBlock.Handrail,"Wall") end)
end) end)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- PATHFINDING
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function createPath(r,h) return PF:CreatePath({AgentRadius=r,AgentHeight=h,AgentCanJump=false,AgentCanClimb=false,WaypointSpacing=4,Costs={Roads=1,Side_Walk=2,Wall=5,Pizza_Entrance=3,Pizza_Counter=3,Pizza_Seats=3,Taxi_Stands=3,Pizza_Table=3,World_Lights=3,Trees=4,Rental_Vehicles=3,Fire_Hydrant=3}}) end
local function onePath(from,to,r,h)
	local path=createPath(r,h)
	local ok=pcall(function() path:ComputeAsync(from,to) end)
	if ok and path.Status==Enum.PathStatus.Success then
		local wps=path:GetWaypoints()
		if #wps>1 then local out={};for _,wp in ipairs(wps) do out[#out+1]=wp.Position end;return out end
	end
	return nil
end
local function computeWaypoints(from,to)
	for _,cfg in ipairs({{2.5,4},{2,4},{3,5},{1.5,3}}) do
		local out=onePath(from,to,cfg[1],cfg[2]);if out then return out end
	end
	local mid=from:Lerp(to,0.5)
	local a=onePath(from,mid,2,4)
	local b=onePath(mid,to,2,4)
	if a and b then for i=2,#b do a[#a+1]=b[i] end;return a end
	return a or b
end
local function computePathRetry(from,to,log)
	local wps=computeWaypoints(from,to);local tries=0
	while not wps and DELIVERY_RUNNING and tries<8 do tries=tries+1;log("no path, retry "..tries);task.wait(0.5);local p=mopedPos();if not p then return nil end;wps=computeWaypoints(p,to) end
	return wps
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- WALK-TO
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function walkToPos(targetPos, reach, log)
	local root = charRoot(); local hum = getHumanoid()
	if not root or not hum then return false end
	local wps = computeWaypoints(root.Position, targetPos)
	if not wps then
		hum:MoveTo(targetPos)
		local t0 = tick()
		repeat task.wait(0.3)
		until not DELIVERY_RUNNING or tick()-t0 > 30
			or (charRoot() and (charRoot().Position - targetPos).Magnitude <= reach)
		return charRoot() and (charRoot().Position - targetPos).Magnitude <= reach
	end
	for i = 2, #wps do
		if not DELIVERY_RUNNING then return false end
		hum:MoveTo(wps[i])
		local done = false
		local conn = hum.MoveToFinished:Connect(function() done = true end)
		local t0 = tick()
		repeat task.wait(0.1) until done or tick()-t0 > 8
		conn:Disconnect()
		local r = charRoot()
		if r and (r.Position - targetPos).Magnitude <= reach then return true end
	end
	return charRoot() and (charRoot().Position - targetPos).Magnitude <= reach
end
-- PATH VIS
local pathFolder=workspace:FindFirstChild("_AutoDeliveryPath") or Instance.new("Folder",workspace);pathFolder.Name="_AutoDeliveryPath"
local function clearPath() for _,c in ipairs(pathFolder:GetChildren()) do c:Destroy() end end
local function drawPath(positions) clearPath();if not SHOW_PATH or not positions then return end;for _,pos in ipairs(positions) do local p=Instance.new("Part");p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.Size=Vector3.new(1,1,1);p.Shape=Enum.PartType.Ball;p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(0,200,255);p.Position=pos+Vector3.new(0,1,0);p.Parent=pathFolder end end
-- DRIVE TO (anti-stuck safety net)
local function driveTo(targetPos,reach,log)
	local from=mopedPos();if not from then log("no moped");return false end
	disableDrive();task.wait(0.15)
	from=mopedPos();if not from then return false end
	local wps=computePathRetry(from,targetPos,log);if not wps then log("path failed");return false end
	drawPath(wps);enableDrive()
	local idx=2
	local lastCheckPos = mopedPos() or from
	local lastProgressTime = tick()
	while DELIVERY_RUNNING do
		if FORCE_HYGIENE then driveTarget=nil;return false end
		if FUN_OK and FH_PENDING then driveTarget=nil;return false end
		local pos=mopedPos();if not pos then return false end
		local flatDist=((targetPos-pos)*Vector3.new(1,0,1)).Magnitude
		if flatDist<=reach then driveTarget=nil;return true end
		if wps[idx] then local wpFlat=((wps[idx]-pos)*Vector3.new(1,0,1)).Magnitude;if wpFlat<=WAYPOINT_REACH then idx=idx+1 end end
		driveTarget=wps[idx] or targetPos
		if (pos - lastCheckPos).Magnitude > 1.5 then
			lastCheckPos = pos
			lastProgressTime = tick()
		elseif tick() - lastProgressTime > 0.6 then
			reassertNoclip()
			local body = getMopedBody()
			local goal = wps[idx] or targetPos
			if body and goal then
				local dir = (goal - pos)
				if dir.Magnitude > 0.1 then
					dir = dir.Unit
					local jumpPos = pos + dir * 8 + Vector3.new(0, Y_OFFSET, 0)
					local flat = (dir * Vector3.new(1,0,1))
					if flat.Magnitude > 0.1 then
						body.CFrame = CFrame.lookAt(jumpPos, jumpPos + flat.Unit)
					else
						body.CFrame = CFrame.new(jumpPos) * (body.CFrame - body.CFrame.Position)
					end
					body.AssemblyLinearVelocity = Vector3.new(0,0,0)
					body.AssemblyAngularVelocity = Vector3.new(0,0,0)
				end
			end
			lastCheckPos = mopedPos() or pos
			lastProgressTime = tick()
		end
		RunService.Heartbeat:Wait()
	end;return false
end
-- FIND CUSTOMER NPC
local function findCustomerNPC(targetPos)
	local closest,closestDist=nil,25
	for _,c in ipairs(CollectionService:GetTagged("PizzaPlanetDeliveryCustomer")) do
		local h=c:FindFirstChild("HumanoidRootPart");if h then local d=(h.Position-targetPos).Magnitude;if d<closestDist then closest=c;closestDist=d end end
	end
	local sc=getSpawnedChars()
	if sc then for _,c in ipairs(sc:GetChildren()) do if c.Name:find("PizzaPlanetDeliveryCustomer") then
		local h=c:FindFirstChild("HumanoidRootPart");if h then local d=(h.Position-targetPos).Magnitude;if d<closestDist then closest=c;closestDist=d end end
	end end end
	return closest
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- MOODS (read) â€” cached read (TTL 0.12s)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local MOOD_CACHE_TTL = 0.12
local _moodCache, _moodCacheAt = nil, 0
local function getMoods()
	local now = tick()
	if _moodCache and (now - _moodCacheAt) < MOOD_CACHE_TTL then return _moodCache end
	local out={}
	for _,name in ipairs({"Fun","Energy","Hunger","Hygiene"}) do
		local ok,node=pcall(function() return SG:GetStat(LP,"MoodData",name) end)
		out[name]=(ok and node) and tonumber(node.Value) or 0
	end
	_moodCache, _moodCacheAt = out, now
	return out
end
local function moodsAreReadable() local ok,node=pcall(function() return SG:GetStat(LP,"MoodData","Fun") end);return ok and node~=nil end
local function doEatAll()
	local root=LP.Character and (LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character.PrimaryPart);if not root then return false end
	local menu=handler:ShowMenu(LP,root.CFrame);if not menu then return false end;task.wait(0.15);if not menu:IsOpen() then return false end
	return clickByText(menu,"Eat All")
end
local function isIdleWindow() return customerTarget==nil end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- priority helpers + flags
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function canTriggerFood()
	if getMoods().Hunger >= (_G.HUNGER_TRIGGER or 65) then return false end
	local fo = getFoodOrigin(); if not fo then return false end
	local here = mopedPos() or (charRoot() and charRoot().Position); if not here then return false end
	local opos = objWorldPos(fo); if not opos then return false end
	return (here - opos).Magnitude <= (_G.FOOD_DIST or 45)
end
local function canTriggerHygiene()
	if getMoods().Hygiene >= (_G.HYGIENE_TRIGGER or 65) then return false end
	local here = mopedPos() or (charRoot() and charRoot().Position); if not here then return false end
	return (here - HYGIENE_TARGET).Magnitude <= (_G.HYGIENE_DIST or 180)
end
local FH_PENDING = false
local FUN_USE_COUNT = 0
local FORCE_HYGIENE = false
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- DELIVERY PIECES
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function hasPizzaBox()
	local char=LP.Character
	if char then for _,c in ipairs(char:GetChildren()) do if c.Name=="Pizza Box Model" then return true end end end
	local bp=LP:FindFirstChild("Backpack")
	if bp then for _,c in ipairs(bp:GetChildren()) do if c.Name=="Pizza Box Model" then return true end end end
	return false
end
local function ensureRiding(log)
	if getMoped() then return true end;log("mounting")
	local hrp=charRoot();local dm=getDeliveryMoped();if not dm then log("no moped");return false end
	local base=dm:IsA("Model") and dm.PrimaryPart or dm
	if hrp and base then hrp.CFrame=base.CFrame*CFrame.new(0,3,4) end
	task.wait(0.4);interact(dm,"Use")
	local t0=tick();repeat task.wait(0.1) until getMoped() or tick()-t0>5
	return getMoped()~=nil
end
local function tryTakeBox(log)
	local cb=getConveyorBoxes();if not cb then return end
	local boxes={}
	for _,c in ipairs(cb:GetChildren()) do if c.Name:find("PizzaBox") then boxes[#boxes+1]=c end end
	if #boxes==0 then return end
	for _,box in ipairs(boxes) do interact(box,"Take");task.wait(0.3) end
end
local function dismountMoped(log)
	local moped=getMoped()
	if moped then if interact(moped,"Leave") or interact(moped,"Exit") or interact(moped,"Get Off") then task.wait(0.4);return true end end
	local hum=getHumanoid()
	if hum then hum.Jump=true;hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	task.wait(0.6);return true
end
local function remountMoped(log)
	local parked = getParkedMoped()
	if parked then
		local body = parked:FindFirstChild("Body")
		if body then
			log("remount: walking near parked moped in SpawnedVehicles")
			walkToPos(body.Position, 10, log)
			task.wait(0.3)
			interact(parked, "Use")
			local t0 = tick()
			repeat task.wait(0.1) until getMoped() and getMopedBody() or tick()-t0 > 5
			if getMoped() then
				setNoclip(false)
				return true
			end
			log("remount: walk+interact failed, trying fallback")
		end
	end
	local moped = getMoped()
	if not moped then log("moped gone, re-summon"); return ensureRiding(log) end
	local base = moped.PrimaryPart or moped:FindFirstChild("Body")
	local hrp = charRoot()
	if hrp and base then hrp.CFrame = base.CFrame * CFrame.new(0, 3, 2) end
	task.wait(0.3); interact(moped, "Use")
	local t0 = tick(); repeat task.wait(0.1) until getMoped() and getMopedBody() or tick()-t0 > 4
	setNoclip(false)
	return true
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- ON-JOB MOOD: FOOD
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function doOnJobFood(log)
	if getMoods().Hunger >= (_G.HUNGER_TRIGGER or 65) then return end
	if not isIdleWindow() then return end
	local origin=getFoodOrigin();if not origin then return end
	local here=mopedPos() or (charRoot() and charRoot().Position);if not here then return end
	local opos=objWorldPos(origin);if not opos then return end
	if (here-opos).Magnitude>(_G.FOOD_DIST or 45) then return end
	log("mood: food")
	MOOD_ACTIVE=true
	disableDrive()
	if not driveTo(FOOD_TARGET,6,log) then MOOD_ACTIVE=false;return end
	disableDrive()
	local guard=0
	while DELIVERY_RUNNING and AUTO_MOOD_ENABLED do
		if getMoods().Hunger>=100 then
			if hasEquippedTool() or hasEquippedPlate() then unequipTools();task.wait(0.2) end
			break
		end
		guard=guard+1;if guard>12 then break end
		interact(origin,"Order Food","Pizza Slice")
		task.wait(1)
		doEatAll()
		PLATE_EQUIPPED=true
		task.wait(1.5)
	end
	if hasEquippedTool() or hasEquippedPlate() then unequipTools();task.wait(0.3) end
	MOOD_ACTIVE=false
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- ON-JOB MOOD: HYGIENE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function doOnJobHygiene(log, skipDistanceCheck)
	if getMoods().Hygiene >= (_G.HYGIENE_TRIGGER or 65) then return end
	if not isIdleWindow() then return end
	if hasPizzaBox() then return end
	if not skipDistanceCheck then
		local here=mopedPos() or (charRoot() and charRoot().Position);if not here then return end
		if (here-HYGIENE_TARGET).Magnitude>(_G.HYGIENE_DIST or 180) then return end
	end
	log("mood: hygiene")
	MOOD_ACTIVE=true
	disableDrive()
	if not driveTo(HYGIENE_TARGET,6,log) then MOOD_ACTIVE=false;return end
	disableDrive()
	dismountMoped(log)
	task.wait(0.5)
	local shower=getShower()
	if shower then
		local spos = objWorldPos(shower)
		if spos then
			log("walking to shower")
			walkToPos(spos, 6, log)
			task.wait(0.2)
		end
		local tries=0
		repeat
			local y0=charRoot() and charRoot().Position.Y or 0
			interact(shower,"Use")
			task.wait(1)
			local y1=charRoot() and charRoot().Position.Y or 0
			tries=tries+1
			if y1>y0+0.75 then break end
		until tries>=5 or not (DELIVERY_RUNNING and AUTO_MOOD_ENABLED)
		while DELIVERY_RUNNING and AUTO_MOOD_ENABLED do
			if getMoods().Hygiene>=100 then break end
			task.wait(1)
		end
	else
		log("shower not found at target, waiting 5s")
		task.wait(5)
	end
	do
		local hum=getHumanoid()
		if hum then
			hum.Jump=true
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
			task.wait(0.6)
		end
	end
	remountMoped(log)
	MOOD_ACTIVE=false
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- ON-JOB MOOD: FUN (background)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
task.spawn(function()
	while true do
		task.wait(0.4)
		if not (AUTO_MOOD_ENABLED and MOOD_METHOD==2 and DELIVERY_RUNNING) then continue end
		if MOOD_ACTIVE then continue end
		if getMoods().Hygiene < (_G.HYGIENE_TRIGGER or 65) and not hasPizzaBox() and customerTarget == nil then
			FORCE_HYGIENE = true
		end
		if not FUN_OK or not isIdleWindow() then
			if hasEquippedTool() then unequipTools() end
			continue
		end
		if canTriggerFood() or canTriggerHygiene() then
			if hasEquippedTool() then unequipTools();task.wait(0.2) end
			FH_PENDING = true
			continue
		end
		local fun=getMoods().Fun
		if fun < (_G.FUN_TRIGGER or 99) then
			if FUN_USE_COUNT < 3 then
				if not hasEquippedTool() then equipSlot1();task.wait(0.3) end
				interactSelf("Use")
				FUN_USE_COUNT = FUN_USE_COUNT + 1
			end
		else
			if hasEquippedTool() then unequipTools() end
		end
	end
end)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- MAIN DELIVERY LOOP
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function deliveryLoop(log)
	hookGuidingArrow()
	while DELIVERY_RUNNING do
		if not getConveyorBoxes() then log("waiting for env...");task.wait(2);continue end
		if not ensureRiding(log) then task.wait(1);continue end
		customerTarget=nil
		customerConfirmed=false
		if AUTO_MOOD_ENABLED and MOOD_METHOD==2 then
			doOnJobHygiene(log)
			doOnJobFood(log)
		end
		FUN_OK = false
		if hasEquippedTool() or hasEquippedPlate() then unequipTools();task.wait(0.2) end
		log("-> box")
		local arrived=driveTo(BOX_POS,BOX_REACH,log)
		if not arrived then
			if FORCE_HYGIENE then
				FORCE_HYGIENE=false; FUN_OK=false
				if hasEquippedTool() or hasEquippedPlate() then unequipTools();task.wait(0.2) end
				doOnJobHygiene(log, true)
				doOnJobFood(log)
			end
			task.wait(0.5);continue
		end
		disableDrive()
		tryTakeBox(log)
		log("waiting for customer...")
		local arrowWait=tick()
		while not customerTarget and DELIVERY_RUNNING and tick()-arrowWait<8 do
			task.wait(0.1)
		end
		if not customerTarget then
			log("no box (retrying)")
			task.wait(0.5)
			continue
		end
		log("-> customer")
		local custArrived=driveTo(customerTarget,CUST_REACH,log)
		if custArrived then
			disableDrive()
			local cust=findCustomerNPC(customerTarget)
			if cust then
				local delivered=false
				for attempt=1,5 do
					if not DELIVERY_RUNNING then break end
					interact(cust,"Give");task.wait(0.5)
					if customerConfirmed then delivered=true;break end
					log("retry give ("..attempt..")")
				end
				log(delivered and "delivered" or "failed")
			else
				log("NPC not found, waiting...")
				task.wait(2)
				cust=findCustomerNPC(customerTarget)
				if cust then interact(cust,"Give");task.wait(0.5) end
			end
		end
		customerTarget=nil
		FUN_OK=true
		FUN_USE_COUNT=0
		if AUTO_MOOD_ENABLED and MOOD_METHOD==2
			and not hasPizzaBox()
			and (FORCE_HYGIENE or getMoods().Hygiene < (_G.HYGIENE_TRIGGER or 65)) then
			log("hygiene priority -> shower before returning to box")
			FUN_OK=false
			FH_PENDING=false; FORCE_HYGIENE=false
			if hasEquippedTool() or hasEquippedPlate() then unequipTools();task.wait(0.2) end
			doOnJobHygiene(log, true)
			doOnJobFood(log)
		end
		log("<- box")
		driveTo(BOX_POS,BOX_REACH,log)
		disableDrive()
		if AUTO_MOOD_ENABLED and MOOD_METHOD==2 then
			if FH_PENDING or FORCE_HYGIENE or canTriggerFood() or canTriggerHygiene() then
				local pendingHygiene = FH_PENDING or FORCE_HYGIENE
				FH_PENDING=false; FORCE_HYGIENE=false
				FUN_OK=false
				if hasEquippedTool() then unequipTools();task.wait(0.2) end
				doOnJobHygiene(log, pendingHygiene)
				doOnJobFood(log)
			end
		end
		FH_PENDING=false; FORCE_HYGIENE=false
		task.wait(0.3)
	end
	FUN_OK=false
	FH_PENDING=false
	FORCE_HYGIENE=false
	disableDrive();clearPath()
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- METHOD 1 (house) MOOD
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local O={}
local function ensureMoodObjects()
	local plot=workspace.Plots:FindFirstChild("Plot_"..LP.Name);if not plot then return false end
	local house=plot:FindFirstChild("House");if not house then return false end
	local objects=house:FindFirstChild("Objects");if not objects then return false end
	local counters=house:FindFirstChild("Counters")
	O.shower=objects:FindFirstChild("The Barrel") or objects:FindFirstChild("Basic Shower")
	O.bed=objects:FindFirstChild("Standard Single Bed")
	local et=objects:FindFirstChild("Simplicity End Table");local ih=et and et:FindFirstChild("ItemHolder")
	O.tv=ih and ih:FindFirstChild("Old Television")
	O.fridge=counters and counters:FindFirstChild("Icebox Fridge")
	return O.shower~=nil and O.bed~=nil
end
local function takeQuickMeal(foodName,timeout) foodName=foodName:lower();local deadline=tick()+(timeout or 5);while tick()<deadline do for _,d in ipairs(LP.PlayerGui:GetDescendants()) do if d:IsA("TextLabel") and d.Text and d.Text:lower():gsub("%s","")==foodName:gsub("%s","") then local row=d.Parent;for _=1,4 do if not row then break end;local take;for _,b in ipairs(row:GetDescendants()) do if (b:IsA("TextButton") or b:IsA("ImageButton")) and ((b:IsA("TextButton") and b.Text:lower():find("take")) or b.Name:lower():find("take")) then take=b;break end end;if take and fireBtn(take) then return true end;row=row.Parent end end end;task.wait(0.15) end;return false end
local function doShower() return interact(O.shower,"Use") end
local function doSleep() return interact(O.bed,"Sleep") end
local function doWatchTV() if not interact(O.tv,"Turn On","Watch") then interact(O.tv,"Watch") end;return true end
local function doEat(food) if not interact(O.fridge,"Take Quick Meal") then return false end;task.wait(0.4);return takeQuickMeal(food or "Water") end
local function tpTo(cf) local char=LP.Character;local root=char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart);if root then root.CFrame=cf end end
local function objCF(obj) if not obj then return nil end;local origin=ID:GetOrigin(obj,6);return origin and origin.CFrame or (obj:IsA("BasePart") and obj.CFrame) end
local function jumpOnce() local hum=getHumanoid();if hum then hum.Jump=true;hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
local function autoMoodHouse(log)
	log("mood(house): start");if not ensureMoodObjects() then return end
	local a,b=objCF(O.shower),objCF(O.tv)
	if a and b then tpTo(CFrame.new((a.Position+b.Position)/2+Vector3.new(0,3,0))) elseif a then tpTo(a*CFrame.new(0,3,3)) end
	task.wait(0.5);doShower();task.wait(0.8);doWatchTV()
	while SYSTEM_ENABLED do local m=getMoods();log(("Hyg %d|Fun %d"):format(m.Hygiene,m.Fun));if m.Hygiene>=100 and m.Fun>=100 then break end;local bef=getMoods();task.wait(1.5);local aft=getMoods();if m.Hygiene<100 and aft.Hygiene<=bef.Hygiene then doShower();task.wait(0.4) end;if m.Fun<100 and aft.Fun<=bef.Fun then doWatchTV();task.wait(0.4) end end
	interact(O.tv,"Turn Off");task.wait(0.4)
	jumpOnce();task.wait(0.4)
	if not SYSTEM_ENABLED then return end
	tpTo(objCF(O.fridge) or LP.Character.HumanoidRootPart.CFrame);task.wait(0.4)
	while SYSTEM_ENABLED do local m=getMoods();log(("Hunger %d"):format(m.Hunger));if m.Hunger>=100 then break end;doEat(_G.PIZZA_FOOD);task.wait(0.6);doEatAll();task.wait(3) end
	if not SYSTEM_ENABLED then return end
	tpTo(objCF(O.bed) or LP.Character.HumanoidRootPart.CFrame);task.wait(0.4);doSleep()
	while SYSTEM_ENABLED do local m=getMoods();log(("Energy %d"):format(m.Energy));if m.Energy>=100 then break end;task.wait(1.5) end
	log("mood(house): done")
end
-- NAVIGATION
local function goToHouse()
	local ok,CG=pcall(function() return LP.PlayerGui.HUDGui.Phone.PhoneVertical.CanvasGroup end);if not ok or not CG then return false end
	local function notInApp(v) local p=v.Parent;while p and p~=CG do if p.Name=="AppContainer" then return false end;p=p.Parent end;return true end
	local NAMES={"Home","House","Plot","MyHome","MyPlot","HouseApp","PlotApp","Tab1","HomeTab","PlotTab","App1","TabHome","Habitat","Residence","HouseButton","HomeButton"}
	local tab;for _,name in ipairs(NAMES) do local f=CG:FindFirstChild(name,true);if f and (f:IsA("ImageButton") or f:IsA("TextButton")) and notInApp(f) then tab=f;break end end
	if not tab then for _,v in ipairs(CG:GetDescendants()) do if (v:IsA("ImageButton") or v:IsA("TextButton")) and notInApp(v) then tab=v;break end end end
	if tab then fireBtn(tab);task.wait(0.3) end
	local ac=CG:FindFirstChild("AppContainer");local pc=ac and ac:FindFirstChild("MyPlotContent",true)
	local body=pc and pc:FindFirstChild("Body");local goBtn=body and body:FindFirstChild("GoToPlotButton")
	if goBtn then if getconnections then for _,c in ipairs(getconnections(goBtn.Activated)) do c:Fire() end elseif firesignal then pcall(function() firesignal(goBtn.Activated) end) end;return true end;return false
end
local function goToPizzaJob() if not getgc then return false end;local JH;for _,m in ipairs(getgc(true)) do if type(m)=="table" and rawget(m,"GoToWork") and rawget(m,"StartWorking") then JH=m;break end end;if JH then JH:GoToWork("PizzaPlanetDelivery");return true end;return false end
local function waitForTeleport(_,maxWait)
	maxWait=maxWait or 25;task.wait(1.5)
	local found=false;local t0=tick()+5
	while tick()<t0 do for _,g in ipairs(LP.PlayerGui:GetChildren()) do if g:IsA("ScreenGui") and g.Enabled then local n=g.Name:lower();if n:find("load") or n:find("fade") or n:find("transit") or n:find("black") then found=true;break end end end;if found then break end;task.wait(0.15) end
	if found then local t1=tick()+maxWait;while tick()<t1 do local still=false;for _,g in ipairs(LP.PlayerGui:GetChildren()) do if g:IsA("ScreenGui") and g.Enabled then local n=g.Name:lower();if n:find("load") or n:find("fade") or n:find("transit") or n:find("black") then still=true;break end end end;if not still then break end;task.wait(0.2) end end
	local t2=tick()+maxWait;while tick()<t2 do local c=LP.Character;if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Humanoid") then break end;task.wait(0.2) end;task.wait(2)
end
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- CONTROL
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local sharedLog=function(_) end
local function stopDelivery()
	if not DELIVERY_RUNNING then return end
	DELIVERY_RUNNING=false; FUN_OK=false; FH_PENDING=false; FORCE_HYGIENE=false
	task.wait(1); disableDrive(); clearPath()
end
local function startDelivery() if DELIVERY_RUNNING then return end;DELIVERY_RUNNING=true;task.spawn(function() pcall(deliveryLoop,function(msg) sharedLog(msg) end) end) end
local function startAtPizza()
	task.spawn(function()
		pcall(goToPizzaJob); pcall(waitForTeleport,"pizza",30)
		waitForPizzaEnv(20); task.wait(1)
		if SYSTEM_ENABLED and not MOOD_ACTIVE then startDelivery() end
	end)
end
task.spawn(function()
	while true do task.wait(2)
		if not (SYSTEM_ENABLED and AUTO_MOOD_ENABLED and MOOD_METHOD==1) then continue end
		if MOOD_ACTIVE or not moodsAreReadable() then continue end
		local m=getMoods()
		if not (m.Fun<(_G.FUN_TRIGGER or 99) and m.Energy<(_G.ENERGY_TRIGGER or 30) and m.Hunger<(_G.HUNGER_TRIGGER or 65) and m.Hygiene<(_G.HYGIENE_TRIGGER or 65)) then continue end
		MOOD_ACTIVE=true;stopDelivery()
		pcall(goToHouse);pcall(waitForTeleport,"house",30)
		pcall(autoMoodHouse,function(msg) sharedLog(msg) end)
		pcall(goToPizzaJob);pcall(waitForTeleport,"pizza",30)
		waitForPizzaEnv(20);task.wait(1)
		MOOD_ACTIVE=false;if SYSTEM_ENABLED then startDelivery() end
	end
end)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- PROXIMITY VISUALS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local visFolder=workspace:FindFirstChild("_MoodVis") or Instance.new("Folder",workspace)
visFolder.Name="_MoodVis"
local function makeSphere(name,color)
	local p=Instance.new("Part")
	p.Name=name;p.Anchored=true;p.CanCollide=false;p.CanQuery=false
	p.Shape=Enum.PartType.Ball;p.Material=Enum.Material.ForceField
	p.Color=color;p.Transparency=0.6;p.Parent=visFolder
	return p
end
local foodSphere,hygSphere
task.spawn(function()
	while true do
		task.wait(0.5)
		if not _G.SHOW_MOOD_VIS then
			if foodSphere then foodSphere:Destroy();foodSphere=nil end
			if hygSphere then hygSphere:Destroy();hygSphere=nil end
			continue
		end
		local fo=getFoodOrigin();local fpos=fo and objWorldPos(fo)
		if fpos then
			if not foodSphere then foodSphere=makeSphere("FoodRadius",Color3.fromRGB(255,180,60)) end
			foodSphere.Size=Vector3.new(1,1,1)*(_G.FOOD_DIST*2);foodSphere.Position=fpos
		elseif foodSphere then foodSphere:Destroy();foodSphere=nil end
		if _G.HYGIENE_DIST and _G.HYGIENE_DIST > 0 then
			if not hygSphere then hygSphere=makeSphere("HygieneRadius",Color3.fromRGB(60,180,255)) end
			hygSphere.Size=Vector3.new(1,1,1)*(_G.HYGIENE_DIST*2);hygSphere.Position=HYGIENE_TARGET
		elseif hygSphere then hygSphere:Destroy();hygSphere=nil end
	end
end)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- CONFIG â€” DweeybzSCRPT/config.txt
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local CONFIG_FOLDER = "DweeybzSCRPT"
local CONFIG_FILE = "DweeybzSCRPT/config.txt"
local AUTO_LOAD = false
local SAVED_PIZZA_DELIVER = false
local function fsAvailable()
	return typeof(writefile)=="function" and typeof(readfile)=="function" and typeof(isfile)=="function"
end
local function buildConfigTable()
	return {
		pizzaDeliver = SYSTEM_ENABLED,
		hunger = _G.HUNGER_TRIGGER,
		hygiene = _G.HYGIENE_TRIGGER,
		fun = _G.FUN_TRIGGER,
		autoLoad = AUTO_LOAD,
	}
end
local function saveConfig()
	if not fsAvailable() then return false end
	pcall(function()
		if typeof(makefolder)=="function" and typeof(isfolder)=="function" and not isfolder(CONFIG_FOLDER) then
			makefolder(CONFIG_FOLDER)
		end
	end)
	return (pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(buildConfigTable())) end))
end
local function readConfigRaw()
	if not fsAvailable() then return nil end
	local data
	local ok = pcall(function() if isfile(CONFIG_FILE) then data = HttpService:JSONDecode(readfile(CONFIG_FILE)) end end)
	if ok then return data end
	return nil
end
local function applyConfigTriggers(cfg)
	if type(cfg)~="table" then return end
	if tonumber(cfg.hunger) then _G.HUNGER_TRIGGER = math.clamp(math.floor(cfg.hunger),0,100) end
	if tonumber(cfg.hygiene) then _G.HYGIENE_TRIGGER = math.clamp(math.floor(cfg.hygiene),0,100) end
	if tonumber(cfg.fun) then _G.FUN_TRIGGER = math.clamp(math.floor(cfg.fun),0,100) end
end
local function resetConfig()
	_G.HUNGER_TRIGGER = 75
	_G.HYGIENE_TRIGGER = 68
	_G.FUN_TRIGGER = 99
	AUTO_LOAD = false
	SAVED_PIZZA_DELIVER = false
	if fsAvailable() then
		pcall(function() if typeof(delfile)=="function" and isfile(CONFIG_FILE) then delfile(CONFIG_FILE) end end)
	end
end
do
	local cfg = readConfigRaw()
	if type(cfg)=="table" then
		AUTO_LOAD = cfg.autoLoad == true
		if AUTO_LOAD then
			applyConfigTriggers(cfg)
			SAVED_PIZZA_DELIVER = cfg.pizzaDeliver == true
		end
	end
end
-- ══════════════════════════════════════════════
-- ANTI AFK — resets Roblox's own idle timer so it doesn't auto-kick after ~20min
-- ════════════════════════════════════════
local ANTI_AFK_ENABLED = true
local antiAfkConn = LP.Idled:Connect(function()
	if not ANTI_AFK_ENABLED then return end
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end)
-- ══════════════════════════════════════════
-- GUI — WindUI (github.com/Footagesus/WindUI) — PC + mobile, with key system and mobile open-bubble
-- ════════════════════════════════════════
local Window = WindUI:CreateWindow({
	Title = "DweeybzSCRPT",
	Icon = "pizza",
	Author = "Auto Delivery",
	Folder = "DweeybzSCRPT",
	Size = UDim2.fromOffset(580, 460),
	Theme = "Dark",
	ToggleKey = Enum.KeyCode.RightShift,
	OpenButton = {
		Title = "DweeybzSCRPT",
		Enabled = true,
		Draggable = true,
		OnlyMobile = false, -- shows the floating bubble on PC too, not just mobile
	},
	KeySystem = {
		Key = { "imongmama" },
		Note = "Enter your key to unlock DweeybzSCRPT.",
		SaveKey = true, -- remembers the key so you don't retype it every time
	},
})

local Tab = Window:Tab({ Title = "Main", Icon = "home" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

local moodParagraph = Tab:Paragraph({ Title = "Mood", Desc = "Moods: --" })
local function setLabel(_, text)
	pcall(function() moodParagraph:SetDesc(text) end)
end
local function log(_) end
sharedLog = log

Tab:Section({ Title = "Delivery" })
local deliveryToggle = Tab:Toggle({
	Title = "Pizza Deliver w/ Smart Auto Mood",
	Value = SAVED_PIZZA_DELIVER,
	Callback = function(v)
		SYSTEM_ENABLED = v
		if SYSTEM_ENABLED then
			if not MOOD_ACTIVE then
				startAtPizza()
			end
		else
			stopDelivery()
		end
	end,
})

Tab:Section({ Title = "Mood Triggers" })
local hungerSlider = Tab:Slider({
	Title = "Hunger Trigger",
	Step = 1,
	Value = { Min = 0, Max = 100, Default = _G.HUNGER_TRIGGER },
	Callback = function(v) _G.HUNGER_TRIGGER = v end,
})
local hygieneSlider = Tab:Slider({
	Title = "Hygiene Trigger",
	Step = 1,
	Value = { Min = 0, Max = 100, Default = _G.HYGIENE_TRIGGER },
	Callback = function(v) _G.HYGIENE_TRIGGER = v end,
})
local funSlider = Tab:Slider({
	Title = "Fun Trigger",
	Step = 1,
	Value = { Min = 0, Max = 100, Default = _G.FUN_TRIGGER },
	Callback = function(v) _G.FUN_TRIGGER = v end,
})

SettingsTab:Section({ Title = "Anti AFK" })
local antiAfkToggle = SettingsTab:Toggle({
	Title = "Anti AFK",
	Value = ANTI_AFK_ENABLED,
	Callback = function(v) ANTI_AFK_ENABLED = v end,
})

SettingsTab:Section({ Title = "Config" })
local autoLoadToggle = SettingsTab:Toggle({
	Title = "Auto Load Config",
	Value = AUTO_LOAD,
	Callback = function(v) AUTO_LOAD = v end,
})
SettingsTab:Button({
	Title = "Save Config",
	Callback = function()
		local ok = saveConfig()
		notify("DweeybzSCRPT", ok and "Config saved to DweeybzSCRPT/config.txt" or "Save failed (no file access)")
	end,
})
SettingsTab:Button({
	Title = "Reset Config",
	Callback = function()
		resetConfig()
		pcall(function() hungerSlider:Set(_G.HUNGER_TRIGGER) end)
		pcall(function() hygieneSlider:Set(_G.HYGIENE_TRIGGER) end)
		pcall(function() funSlider:Set(_G.FUN_TRIGGER) end)
		notify("DweeybzSCRPT", "Config reset to defaults")
	end,
})

task.spawn(function()
	while true do
		pcall(function()
			local m=getMoods()
			setLabel(moodParagraph, ("Fun %d | Ene %d | Hun %d | Hyg %d"):format(m.Fun, m.Energy, m.Hunger, m.Hygiene))
		end)
		task.wait(0.5)
	end
end)