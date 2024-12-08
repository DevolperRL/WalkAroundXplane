-- main.lua
--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]

include("col.lua")
include("updater.lua")
include("Log.lua")

print("--------------------------------------------------------")
print("-----------------THIS IS BETA VERSION!------------------")
print("--------------------------------------------------------")
local view_id = 1

include("openlinks_lib.lua")

defineProperty("action", function() logInfo "Default action" end)

sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)
sasl.options.set3DRendering(true)
--sasl.options.setPanelRenderingMode(SASL_RENDER_PANEL_DEFAULT)

include "keyboard_handler"

OSSystem = sasl.getOS()
version = sasl.getXPVersion()
print(version)

public = {}

pg_version = "3.0"
public.online_version = ""
git.CheckUpdate("https://raw.githubusercontent.com/DevolperRL/WalkAroundXplane/refs/heads/main/updaterData.txt", getMyPluginPath():sub(1, -3) .. "data/modules/version.txt")

public.updateLog = {
	
}

for i = 1, 16 do
    table.insert(public.updateLog, " ")
end

--[[XCamera = false

for _, k in pairs(sasl.listFiles (sasl.getXPlanePath () .."/Resources/plugins/")) do
	if k.name == "X-Camera" then
		XCamera = true
	end
end]]

globalClick = {}
globalClick.runWalk = false

--Datarefs
--[[xCamera_acf_peX = 0
xCamera_acf_peY = 0
xCamera_acf_peZ = 0]]
--acf_peX = 0
--acf_peY = 0
--acf_peZ = 0

--Int Values
elevation = 0
walk = 0
angle = 0
sinX = 0
sinY = 0
sinZ = 0
sinWalk = 0
public.currentHeight = 0
statusHeight = 1
initialPilotHeight = 0
realMinHeight = 0
realMidHeight = 0
realMaxHeight = 0
leftUpArm = 0
leftDoArm = 0
rightUpArm = 0
rightDoArm = 0
leftUpLeg = 0
leftDoLeg = 0
rightUpLeg = 0
rightDoLeg = 0


--Float Variables
public.maxHeight = 1.75
public.minHeight = 0.7
public.middleHeight = (public.maxHeight + public.minHeight) / 2
public.height = public.maxHeight
distance = .04
animationSpeed = .055 -- CHANGE THIS FOR CHANGING THE ANIMATION SPEED ONLY XP12
step1 = 0
step2 = 0
step3 = 0
step4 = 0
step5 = 0
step6 = 0
step7 = 0
step8 = 0
speed = 0
x_door = 0
z_door = 0
y_door = 0
plHdg = 0

crash_dataref = globalPropertyi("sim/flightmodel2/misc/has_crashed")
theta = globalPropertyf("sim/graphics/view/pilots_head_the")
phi = globalPropertyf("sim/graphics/view/pilots_head_phi")
--acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
--acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")
--acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
heading = globalPropertyf("sim/graphics/view/pilots_head_psi")
trueHeading = globalPropertyf("sim/graphics/view/view_heading")
roll = globalPropertyf("sim/graphics/view/field_of_view_roll_deg")
frame = globalPropertyf("sim/time/framerate_period")
acf_doorX = globalPropertyf("sim/aircraft/view/acf_door_x")
acf_doorZ = globalPropertyf("sim/aircraft/view/acf_door_z")
acf_doorY = globalPropertyf("sim/aircraft/view/acf_door_y")
planeTheta = globalPropertyf("sim/flightmodel2/position/true_theta")
planeHeading = globalPropertyf("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")

if version >= 12000 then
	meter = globalPropertyf("sim/graphics/view/view_elevation_agl_mtrs")
else
	y_agl =  globalPropertyf("sim/flightmodel/position/local_y")
	x_agl = globalPropertyf("sim/flightmodel/position/local_x")
	z_agl = globalPropertyf("sim/flightmodel/position/local_z")
end

--Custom Datarefs
createGlobalPropertyf("Human/Body/Torso", 0, true, true, false)
createProperty("Human/Body/Torso", "float", 0)

createGlobalPropertyf("Human/Body/Arms/UpperArmLeft", 0, true, true, false)
createProperty("Human/Body/Arms/UpperArmLeft", "float", 0)

createGlobalPropertyf("Human/Body/Arms/DownArmLeft", 0, true, true, false)
createProperty("Human/Body/Arms/DownArmLeft", "float", 0)

createGlobalPropertyf("Human/Body/Arms/UpperArmRight", 0, true, true, false)
createProperty("Human/Body/Arms/UpperArmRight", "float", 0)

createGlobalPropertyf("Human/Body/Arms/DownArmRight", 0, true, true, false)
createProperty("Human/Body/Arms/DownArmRight", "float", 0)

createGlobalPropertyf("Human/Body/Leg/UpperLegLeft", 0, true, true, false)
createProperty("Human/Body/Leg/UpperLegLeft", "float", 0)

createGlobalPropertyf("Human/Body/Leg/DownLegLeft", 0, true, true, false)
createProperty("Human/Body/Leg/DownLegLeft", "float", 0)

createGlobalPropertyf("Human/Body/Leg/UpperLegRight", 0, true, true, false)
createProperty("Human/Body/Leg/UpperLegRight", "float", 0)

createGlobalPropertyf("Human/Body/Leg/DownLegRight", 0, true, true, false)
createProperty("Human/Body/Leg/DownLegRight", "float", 0)

createGlobalPropertyi("Human/Body/ShowHide", 0, true, true, false)
createProperty("Human/Body/ShowHide", "int", 0)

createGlobalPropertyf("Walkaround/Building/X_build_pos", 0, true, true, false)
createProperty("Walkaround/Building/X_build_pos", "float", 0)

defineProperty("torso", globalPropertyf("Human/Body/Torso"))

defineProperty("armsUpLeft", globalPropertyf("Human/Body/Arms/UpperArmLeft"))
defineProperty("armsDoLeft", globalPropertyf("Human/Body/Arms/DownArmLeft"))

defineProperty("armsUpRight", globalPropertyf("Human/Body/Arms/UpperArmRight"))
defineProperty("armsDoRight", globalPropertyf("Human/Body/Arms/DownArmRight"))

defineProperty("legsUpLeft", globalPropertyf("Human/Body/Leg/UpperLegLeft"))
defineProperty("legsDoLeft", globalPropertyf("Human/Body/Leg/DownLegLeft"))

defineProperty("legsUpRight", globalPropertyf("Human/Body/Leg/UpperLegRight"))
defineProperty("legsDoRight", globalPropertyf("Human/Body/Leg/DownLegRight"))

defineProperty("showHide", globalPropertyf("Human/Body/ShowHide"))

defineProperty("X_pos_building", globalPropertyf("Walkaround/Building/X_build_pos"))

local window_width = get(globalPropertyf("sim/graphics/view/window_width"))
local window_height = get(globalPropertyf("sim/graphics/view/window_height"))

local popup_width = 500;
local popup_height = 500;

local window_center_x =  window_width / 2
local window_center_y =  window_height / 2

public.houseStart = {-9.255476, 101.0562, -15.042489}
public.inHouse = false
public.houseExist = true

allKeys = {
	["A"] = SASL_VK_A,
	["B"] = SASL_VK_B,
	["C"] = SASL_VK_C,
	["D"] = SASL_VK_D,
	["E"] = SASL_VK_E,
	["F"] = SASL_VK_F,
	["G"] = SASL_VK_G,
	["H"] = SASL_VK_H,
	["I"] = SASL_VK_I,
	["J"] = SASL_VK_J,
	["K"] = SASL_VK_K,
	["L"] = SASL_VK_L,
	["M"] = SASL_VK_M,
	["N"] = SASL_VK_N,
	["O"] = SASL_VK_O,
	["P"] = SASL_VK_P,
	["Q"] = SASL_VK_Q,
	["R"] = SASL_VK_R,
	["S"] = SASL_VK_S,
	["T"] = SASL_VK_T,
	["U"] = SASL_VK_U,
	["V"] = SASL_VK_V,
	["W"] = SASL_VK_W,
	["X"] = SASL_VK_X,
	["Y"] = SASL_VK_Y,
	["Z"] = SASL_VK_Z,
	["0"] = SASL_VK_NUMPAD0,
	["1"] = SASL_VK_NUMPAD1,
	["2"] = SASL_VK_NUMPAD2,
	["3"] = SASL_VK_NUMPAD3,
	["4"] = SASL_VK_NUMPAD4,
	["5"] = SASL_VK_NUMPAD5,
	["6"] = SASL_VK_NUMPAD6,
	["7"] = SASL_VK_NUMPAD7,
	["8"] = SASL_VK_NUMPAD8,
	["9"] = SASL_VK_NUMPAD9,
}

generalSettings = {}

generalSettings.currentKeys = {
	forward = {
		cvkey = SASL_VK_W, 
		ckey = "W", 
		ctype = "Foward", 
		cpos = 400
	}, --Forward
	backwards = {
		cvkey =SASL_VK_S, 
		ckey = "S", 
		ctype ="Backwards",
		cpos =  360
	}, --Backwards
	leftwards = {
		cvkey =SASL_VK_A, 
		ckey = "A", 
		ctype ="Leftwards", 
		cpos = 320
	}, --Leftwards
	rightwards = {
		cvkey =SASL_VK_D, 
		ckey = "D", 
		ctype ="Rightwards", 
		cpos = 280
	}, --Rightwards
	sprint = {
		cvkey =SASL_VK_C, 
		ckey = "C", 
		ctype ="Sprint", 
		cpos = 240
	}, --Sprint
	crouchUp = {
		cvkey =SASL_VK_R, 
		ckey = "R",  
		ctype ="Crouch Up",
		cpos = 200
	}, --Crouch Up
	crouchDown = {
		cvkey =SASL_VK_F, 
		ckey = "F", 
		ctype ="Crouch Down", 
		cpos = 160
	}, --Crouch Down
	changeLoc = {
		cvkey = SASL_VK_Q, 
		ckey = "Q",
		ctype ="Change Loc", 
		cpos = 120
	}, --Change Loc

	savedLoc = {
		cvkey = SASL_VK_H,
		ckey = "H",
		ctype = "Save Loc",
		cpos = 80
	},
}

library = {}


--[[
	Settings to add:
	- Show main window on start true/false
	- Start outside when loaded flight true/false
	- Show human true/false
	- Resiveable window true/false
]]

generalSettings.settings = {
	sound = true,
	walk_movement = true,
	window_button = true,
	sprinting = false,
	startedWalk = false,
	show_human = true,
	start_outside = false,
	show_main_win = false,
	enabled = "Start Walking",
}

--Bool Variables
iswalking = false
both = false
firstCall = false
sprint = false
public.locStatus = generalSettings.settings.start_outside -- FALSE = INSIDE 		TRUE = OUTSIDE
public.insideWalkComp = false
jump = false

savedPos = {
	vector = {0, 0, 0}
}

walkLoc = {
	compText = "Click Q for go outside",
}

pages = {
	page = 1,
	maxPages = 2
}

if not isFileExists("WalkAround.json") then
	--library.Notify("Created Settings File")
	sasl.writeConfig ("WalkAround.json", "JSON", generalSettings)
else
	generalSettings = sasl.readConfig ("WalkAround.json" , "json")
end

----------------------------------------
include "input"
----------------------------------------

setting = contextWindow {
	name		= "Settings",
	position	= { window_center_x - ( popup_width / 2), window_center_y - ( popup_height / 2), popup_width, popup_height},
	visible		= false,
	noResize	= true,
	vrAuto		= true,
	components	= {
        settingdec {position = { 150, 100, 100, 100}, bg = {1,0,0,1} },
		button { position={-90, 100, 1000, 1000}, bg = {1,0,0,1} },
	},
}

win = contextWindow {
	name		= "WalkAround",
	position	= { window_center_x - ( popup_width / 2), window_center_y - ( popup_height / 2), popup_width, popup_height},
	visible		= generalSettings.settings.show_main_win, ------------------------------CHANGE THIS TO FALSE IF YOU WONT SHOW THIS ON FLIGHT START------------------------------
	noResize	= true, ------------------------------CHANGE THIS TO FALSE IF YOU WANT RESIZE THE WINDOW------------------------------
	vrAuto		= true,
	components	= {
		input {position = { 150, 100, 100, 100}, bg = {1,0,0,1} },
        settingbtn {position = { 445, 440, 50, 50}, bg = {1,0,0,1} },
		startWalk {position = {90, 125, 300, 50}, bg = {1, 0, 0, 1},},
		invisible_button {
			position = {55, 70, 370, 40},
			click = function()
				OpenLink("https://www.paypal.com/paypalme/kikkus")
			end,
		},
	},
}

input_settings = contextWindow {
	name		= "Input Settings",
	position	= { window_center_x - ( popup_width / 2), window_center_y - ( popup_height / 2), popup_width, popup_height},
	visible		= false,
	noResize	= true,
	vrAuto		= true,
	components	= {
		input_settings {position={0, 0, 500, 500}}
	},
}

xupdater = contextWindow {
	name		= "X-Updater",
	position	= { window_center_x - ( popup_width / 2), window_center_y - ( popup_height / 2), popup_width+200, popup_height},
	visible		= false,
	noResize	= true,
	vrAuto		= true,
	components	= {
		xupdater {position={0, 0, 700, 500}}
	},
}



menuwin = subpanel {
    position     = { -130, 170, 200, 170 },
    noBackground = true,
    noResize     = true,
    noMove       = true,
    noClose      = true,
    visible      = generalSettings.settings.window_button,
    components = {
        menu { position = {150, 100, 100, 100} },
    },
}

notification = subpanel {
    position     = {window_width/2-(300/2), 100, 1, 1 },
    noBackground = true,
    noResize     = true,
    noMove       = true,
    noClose      = true,
    visible      = true,
    components = {
		Notification_lib {position = {0, 0, 300, 100}},
        --menu { position = {150, 100, 100, 100} },
    },
}

local status = true

function change_menu()
	status = not status
	sasl.enableMenuItem(menu_main, menu_action, status and 1 or 0)
	sasl.setMenuItemName(menu_main, menu_option, status and "Disable show/hide" or "Enable show/hide")
	sasl.setMenuItemState(menu_main, menu_option, status and MENU_CHECKED or MENU_UNCHECKED)
end

function show_hide_gndservice() 
    win:setIsVisible(not win:isVisible())
end

function show_hide_inputSettings() 
    input_settings:setIsVisible(not input_settings:isVisible())
end

function SaveAll()
	library.Notify("Settings Saved")
    sasl.writeConfig ( "WalkAround.json" , "JSON" , generalSettings)
end

function OpenUpdater()
	xupdater:setIsVisible(not win:isVisible())
end

local status = false

loadedObjects = false

function change_menu()
	status = not status
	sasl.enableMenuItem(menu_main, menu_action, status and 1 or 0)
end

components = {
	TimerLibrary {0, 0, 1, 1}
}

function draw()
	drawAll(components)
end

local first = false

if generalSettings.settings.start_outside then
	public.inHouse = true
	public.houseExist = false
	public.locStatus = true
end

collision.drawCollision({-10, 100, -11}, {-8, 105, -1}) --Works with 125°

local function FirstCall()
	if not first and not generalSettings.settings.start_outside then
		first = true
		generalSettings.settings.enabled = "Start Walking"
	end
end
--local newbuildPos = 0
--newbuildPos = get(meter) + 150

local oneTimeChange = false
local oldEnabled = false

local stopUpdate = false

function update()
	updateAll(components)

	plHdg = get(planeHeading)

	if collision.isTouching(1) and public.inHouse then
		public.inHouse = false
	end

	--[[if XCamera then
		if get(globalPropertyi("SRS/X-Camera/integration/X-Camera_enabled")) ~= oldEnabled then
			oneTimeChange = false
		end
	end]]

	if public.online_version ~= nil and public.online_version ~= "" and not stopUpdate then
		stopUpdate = true
		if public.online_version ~= pg_version then
			library.Notify("Update Available " .. public.online_version)
		end
	end

	if not oneTimeChange then
		oneTimeChange = true
		oldEnabled = not oldEnabled
		--[[if XCamera then
			if get(globalPropertyi("SRS/X-Camera/integration/X-Camera_enabled")) == 1 then
				acf_peX = globalPropertyfa("SRS/X-Camera/integration/camera_x")
				acf_peY = globalPropertyfa("SRS/X-Camera/integration/camera_y")
				acf_peZ = globalPropertyfa("SRS/X-Camera/integration/camera_z")
				--print("1")
			else
				acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
				acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
				acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")
				--print("2")
			end
		else]]
			
		--end
	end
	acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
	acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
	acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")

	if version >= 12000 and generalSettings.settings.show_human and not loadedObjects then
		obj = sasl.loadObject("Objects/Person.obj")
		--mani = sasl.createInstance(clickable_obj, {})
		ballInst = sasl.createInstance(obj, {})

		if generalSettings.settings.start_outside then
			house_obj = sasl.loadObject("Objects/House.obj")
			house = sasl.createInstance(house_obj, {})
		end

		loadedObjects = true
	end
	
	if get(crash_dataref) == 1 then
		generalSettings.settings.enabled = "You crashed :("
		walkLoc.compText = "You can't walk when you crashed!"
		--print(walkLoc.compText)
	else
		FirstCall()
	end
	
	x, y, z = sasl.modelToLocal(2, 0, 2)
	if version >= 12000 and generalSettings.settings.show_human and loadedObjects then
		sasl.setInstancePosition(ballInst, x, y, z, 0, 0, 0, {})
		--sasl.setInstancePosition(mani, x, y+50, z, 0, 0, 0, {})

		if generalSettings.settings.start_outside and public.inHouse then
			local _, lX, lY, lZ = sasl.probeTerrain(x, y, z)
			sasl.setInstancePosition(house, lX, lY+101.2, lZ, 0, plHdg-90, 0, {})
			--sasl.setInstancePosition(house, -14600, 752.5, 8990, 0, 0, 0, {})
			--set(X_pos_building, 2)
		elseif not public.inHouse and not public.houseExist then
			public.houseExist = true
			--[[maxHeight = 1.75
			minHeight = 0.7
			middleHeight = (maxHeight + minHeight) / 2]]
			--currentHeight = (initialPilotHeight - elevation) + height
			--SetDataref(acf_peY, currentHeight)
			--realMaxHeight = (initialPilotHeight - elevation) + maxHeight
			--public.height = maxHeight
			--public.locStatus = false
			--public.insideWalkComp = false
			--realMaxHeight = 0
			--public.height = 0
			--SetLocStatus()
			--SetLocStatus()
			sasl.destroyInstance(house)
		end
	end
end

menu_master	= sasl.appendMenuItem (PLUGINS_MENU_ID, "WalkAround")
menu_main	= sasl.createMenu ("", PLUGINS_MENU_ID, menu_master)
menu_action	= sasl.appendMenuItem(menu_main, "Open WalkAround", show_hide_gndservice)
sasl.appendMenuSeparator(menu_main)
menu_action	= sasl.appendMenuItem(menu_main, "Input Settings", show_hide_inputSettings)
save_ation	= sasl.appendMenuItem(menu_main, "Save All", SaveAll)
sasl.appendMenuSeparator(menu_main)
save_ation	= sasl.appendMenuItem(menu_main, "X-Updater", OpenUpdater)
change_menu()
