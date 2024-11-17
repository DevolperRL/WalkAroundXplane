--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]

--[[require("bit")

local band = bit.band

local view_id = 7

local CAMERA_STATUS_TRANSISION_IN_PROGRESS = 16 -- bit 5 indicates that a transition is in progress
local CAMERA_STATUS_CONTROL_PANEL_OPEN = 8 -- Bit 4 indicates that the control panel is open
local AIRPORT_CAMERA = 4		-- Bit 3 of the camera status indicates it is an airport camera
local CAMERA_SELECTED = 2		-- Bit 2 indicates the camera is selected
local CAMERA_PRESENT = 1		-- Bit 1 indicates camera is present
local CAMERA_PRESENT_AND_SELECTED = CAMERA_SELECTED + CAMERA_PRESENT

local CAMERA_X = globalPropertyf("SRS/X-Camera/integration/effect_script_x_offset")
local CAMERA_Y = globalPropertyf("SRS/X-Camera/integration/effect_script_y_offset")
local CAMERA_Z = globalPropertyf("SRS/X-Camera/integration/effect_script_z_offset")
local CAMERA_ROLL = globalPropertyf("SRS/X-Camera/integration/effect_script_roll_offset")
local CAMERA_HEADING = globalPropertyf("SRS/X-Camera/integration/effect_script_heading_offset")
local CAMERA_PITCH = globalPropertyf("SRS/X-Camera/integration/effect_script_pitch_offset")
local CAMERA_STATUS = globalPropertyf("SRS/X-Camera/integration/effect_script_id")
local Key_W = globalPropertyf("sim/general/right")

local GLOBAL_STATUS = globalPropertyf("SRS/X-Camera/integration/overall_status")]]

xp_pilot_head_y = globalPropertyf("sim/graphics/view/pilots_head_y")

--defineProperty("crouchTest", globalPropertyf("Human/Body/Crouch_Test"))

if version >= 12000 then
	obj = sasl.loadObject("Objects/Person.obj")
	set(showHide, 0)
end

--------------------------------------------------------------------------------------------------------------------------------------

--Tables
local keys = {
	false, -- Key W 1
	false, -- Key S 2
	false, -- Key A 3
	false, -- Key D 4
	false, -- Key F 5
	false, -- Key R 6
}
--------------------------------------------------------------------------------------------------------------------------------------
---


local currentCrouch = 2
--------------------------------------------------------------------------------------------------------------------------------------

generalSettings.settings.startedWalk = false
--------------------------------------------------------------------------------------------------------------------------------------

result, locationX , locationY , locationZ , normalX , normalY , normalZ , velocityX , velocityY , velocityZ , isWet = 0
--------------------------------------------------------------------------------------------------------------------------------------

--String Variables
--------------------------------------------------------------------------------------------------------------------------------------

--Colors
local black	    = {0, 0, 0, 1}
local cyan	    = {0, 1, 1, 1}
local magenta	= {1, 0, 1, 1}
local yellow	= {1, 1, 0, 1}
local red       = {1, 0, 0, 1}
local white     = {1, 1, 1, 1}
--------------------------------------------------------------------------------------------------------------------------------------

--Font
local fnt =  sasl.gl.loadFont(getXPlanePath() .. "Resources/fonts/DejaVuSansMono.ttf")
--------------------------------------------------------------------------------------------------------------------------------------

--Sound
local walkSound = sasl.al.loadSample("Sounds/WalkSound.wav")

--------------------------------------------------------------------------------------------------------------------------------------

--Images

--------------------------------------------------------------------------------------------------------------------------------------

--Path
--local path = sasl.findPluginByPath("Resources/plugins/X-Camera")
--------------------------------------------------------------------------------------------------------------------------------------

function draw()
	sasl.gl.drawRectangle ( -95, -30, 370, 40, white)
	sasl.gl.drawRectangle ( -100, 90, 390, 200, white)
	drawText(fnt, 90, -8, "Donation: \nhttps://www.paypal.com/paypalme/kikkus", 15, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 100, 320, "WalkAround", 50, false, false, TEXT_ALIGN_CENTER, white)
	drawText(fnt, 85, 260, "Description", 20, false, false, TEXT_ALIGN_CENTER, red)
	drawText(fnt, 95, 230, "W, S, A, D is for movement", 20, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 27, 200, "F/R is for crouch", 20, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 80, 170, "Esc for disable the walk", 20, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 93, 140, "For start click start walk", 20, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 93, 110, "C for sprinting: " .. tostring(generalSettings.settings.sprinting), 20, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 300, -75, "Version: " .. pg_version, 10, false, false, TEXT_ALIGN_CENTER, white)
	drawText(fnt, 300, -90, "12.11.2024", 10, false, false, TEXT_ALIGN_CENTER, white)
	drawText(fnt, -100, -90, "by Raoul Origa", 10, false, false, TEXT_ALIGN_CENTER, white)
	drawText(fnt, 90, -60, walkLoc.compText, 20, false, false, TEXT_ALIGN_CENTER, white)
end

function SetDataref(dataref, value)
	--[[if XCamera then
		if get(globalPropertyi("SRS/X-Camera/integration/X-Camera_enabled")) >= 1 then
			set(dataref, value, 2)
		else
			--print("Xcamera disabled")
			set(dataref, value)
		end
	else]]
		--print("No Xcamera")
		set(dataref, value)
	--end
end

function StartLoc()
	if public.insideWalkComp then
		SetDataref(acf_peX, x_door+1.5)
		SetDataref(acf_peZ, z_door)
		--set(acf_peX, x_door+1.5)
		--set(acf_peZ, z_door)
	
		if version >= 12000 then
			realMaxHeight = y_door + public.maxHeight
			SetDataref(acf_peY, realMaxHeight)
			--set(acf_peY, realMaxHeight)
		else
			realMaxHeight = y_door +  public.maxHeight
			SetDataref(acf_peY, realMaxHeight)
			--set(acf_peY, realMaxHeight)
		end
		public.locStatus = false
	else
		SetDataref(acf_peX, x_door-2)
		SetDataref(acf_peZ, z_door)
		--set(acf_peX, x_door-2)
		--set(acf_peZ, z_door)
	end
end

function SetLocStatus()
	x_door = get(acf_doorX)
	z_door = get(acf_doorZ)
	y_door = get(acf_doorY)
	
	if savedPos.vector[1] == 0 and savedPos.vector[2] == 0 and savedPos.vector[3] == 0 then
		if not public.locStatus or not public.insideWalkComp then
			public.locStatus = true
			SetDataref(acf_peX, x_door-2)
			SetDataref(acf_peZ, z_door)
			--set(acf_peX, x_door-2)
			--set(acf_peZ, z_door)

			if version >= 12000 then
				public.height = public.maxHeight
				realMaxHeight = (initialPilotHeight - elevation) + public.maxHeight
				SetDataref(acf_peY, realMaxHeight)
				--set(acf_peY, realMaxHeight)
			else
				public.height = public.maxHeight
				realMaxHeight = (locationY - elevation) +  public.maxHeight
				SetDataref(acf_peY, realMaxHeight)
				--set(acf_peY, realMaxHeight)
			end
		else
			public.locStatus = false

			SetDataref(acf_peX, x_door+1)
			SetDataref(acf_peZ, z_door)
			--set(acf_peX, x_door+1)
			--set(acf_peZ, z_door)
			
			if version >= 12000 then
				realMaxHeight = y_door + public.maxHeight
				SetDataref(acf_peY, realMaxHeight)
				--set(acf_peY, realMaxHeight)
			else
				realMaxHeight = y_door +  public.maxHeight
				SetDataref(acf_peY, realMaxHeight)
				--set(acf_peY, realMaxHeight)
			end
		end
	else
		SetDataref(acf_peX, savedPos.vector[1])
		SetDataref(acf_peY, savedPos.vector[2])
		SetDataref(acf_peZ, savedPos.vector[3])
		--set(acf_peX, savedPos.vector[1])
		--set(acf_peY, savedPos.vector[2])
		--set(acf_peZ, savedPos.vector[3])
	end
end

function ResetCameras()
	generalSettings.settings.startedWalk = true
	generalSettings.settings.enabled = "Stop Walking"
	StartLoc()
	callKeys()
end

function SaveLoc()
	print(savedPos.vector[1], savedPos.vector[2], savedPos.vector[3])
	if savedPos.vector[1] == 0 and savedPos.vector[2] == 0 and savedPos.vector[2] == 0 then
		library.Notify("Saved Position")
		savedPos.vector = {get(acf_peX), get(acf_peY), get(acf_peZ)}
	else
		print("efaj")
		library.Notify("Removed Position (Click again H to set the new position)")
		savedPos.vector = {0, 0, 0}
	end

			--[[if XCamera then
			if get(globalPropertyi("SRS/X-Camera/integration/X-Camera_enabled")) == 1 then
				savedPos.vector = {get(acf_peX, 2), get(acf_peY, 2), get(acf_peZ, 2)}
			else
				savedPos.vector = {get(acf_peX), get(acf_peY), get(acf_peZ)}
			end
		else
			savedPos.vector = {get(acf_peX), get(acf_peY), get(acf_peZ)}
		end
	else]]
end

local oneTime = false
	

local function process_key(char, vkey, shiftDown, ctrlDown, altOptDown, event)
	if event == KB_DOWN_EVENT then
		if vkey == generalSettings.currentKeys.sprint.cvkey then
			sprint = not sprint
		end

		if vkey == generalSettings.currentKeys.changeLoc.cvkey and not public.inHouse then
			SetLocStatus()
		end

		if vkey == generalSettings.currentKeys.savedLoc.cvkey then
			SaveLoc()
		end

		if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			generalSettings.settings.enabled = "Start Walking"
			generalSettings.settings.startedWalk = false
			return true
		end
	end

	if shiftDown then
		if vkey == generalSettings.currentKeys.forward.cvkey then
			keys[1] = true
		end
	
		if vkey == generalSettings.currentKeys.backwards.cvkey then
			keys[2] = true
		end

		if vkey == generalSettings.currentKeys.leftwards.cvkey then
			keys[3] = true
		end

		if vkey == generalSettings.currentKeys.rightwards.cvkey then
			keys[4] = true
		end

		if vkey == generalSettings.currentKeys.crouchDown.cvkey then
			keys[5] = true
		end

		if vkey == generalSettings.currentKeys.crouchUp.cvkey then
			keys[6] = true
		end
	end

	if event == KB_UP_EVENT then
		iswalking = false
		walk = 0
		both = false
		if vkey == generalSettings.currentKeys.forward.cvkey then
			keys[1] = false -- Key W
		end
	
		if vkey == generalSettings.currentKeys.backwards.cvkey then
			keys[2] = false -- Key S
		end

		if vkey == generalSettings.currentKeys.leftwards.cvkey then
			keys[3] = false -- Key A
		end
	
		if vkey == generalSettings.currentKeys.rightwards.cvkey then
			keys[4] = false -- Key D
		end

		if vkey == generalSettings.currentKeys.crouchDown.cvkey then
			keys[5] = false --F
		end

		if vkey == generalSettings.currentKeys.crouchUp.cvkey then
			keys[6] = false --R
		end
	end

	return false
end

function callKeys()
	registerHandler(process_key)
end

function onModuleInit()
	leftUpArm = 0
	leftDoArm = 0

	rightUpArm = 0
	rightDoArm = 0

	leftUpLeg = 0
	leftDoLeg = 0

	rightUpLeg = 0
	rightDoLeg = 0

	step1 = .5
	step2 = .5
	step3 = .5
	step4 = .5
	step5 = .5
	step6 = .5
	step7 = .5
	step8 = .5
end

function FirstCall()
	if not firstCall then
		firstCall = true
	end
end

local afterCall = false

function AfterCall()
	if not afterCall then
		afterCall = true
		--library.Notify("Test!!")
		--[[if generalSettings.settings.start_outside then
			--if not oneTime then
				--oneTime = true
				ResetCameras()
				--print(public.inHouse, oneTime_house)
				if public.inHouse then
					--if not oneTime_house then
						public.height = maxHeight
						public.locStatus = true
						public.insideWalkComp = false
						SetLocStatus()
						-- -7.3144536	-14.3543215
						public.houseStart = {x_door-3, 102.0562,  z_door+5}
						SetDataref(acf_peX, public.houseStart[1])
						SetDataref(acf_peY, public.houseStart[2])
						SetDataref(acf_peZ, public.houseStart[3])
						--library.Notify("Note this is a beta version there could be bugs!")
						library.wait(.5, function()
							oneTime_house = true
						end)
					--end
				end
			--end]]
		--end
	--	generalSettings.settings.startedWalk = true
	--	generalSettings.settings.enabled = "Stop Walking"
	--	StartLoc()
	--	callKeys()
	end
end

local moveCamera = false

x = 0
z = 0
y = 0

local oneTime_cam = false
local oneTime_house = false
local oneTime_newCam = false
local oneTime_oldCam = false

local planeLoad = false

function onPlaneLoaded()
	--library.wait(2, function()
		planeLoad = true
	--end)
end

function update()	
	x_door = get(acf_doorX)
	z_door = get(acf_doorZ)
	y_door = get(acf_doorY)

	--[[if XCamera then
		if get(globalPropertyi("SRS/X-Camera/integration/X-Camera_enabled")) == 1 then
			x = get(acf_peX)[2]
			z = get(acf_peZ)[2]
			y = get(acf_peY)[2]
		else
			x = get(acf_peX)
			z = get(acf_peZ)
			y = get(acf_peY)
		end
	else]]
		x = get(acf_peX)
		z = get(acf_peZ)
		y = get(acf_peY)
	--end

	hdg = get(heading)
	rol = get(roll)
	tHeading = get(trueHeading)
	p = get(phi)
	the = get(theta)
	modelTthehta = get(planeTheta)

	FirstCall()
	

	if get(crash_dataref) == 0 then
		if x_door == 0 or z_door == 0 then
			public.insideWalkComp = false
			walkLoc.compText = "Can't enter"
		else
			public.insideWalkComp = true
		end

		if public.insideWalkComp then
			if not public.locStatus then
				walkLoc.compText = "Click Q to exit"
			else
				walkLoc.compText = "Click Q for entering"
			end

			if not generalSettings.settings.startedWalk then
				walkLoc.compText = ""
			end
		end
	end

	--if x > 5.5 then
	--	print("Went outside of room!")
	--end

	if sprint then
		speed = .08
	else
		speed = .04
	end

	generalSettings.settings.sprinting = sprint

	if version >= 12000 then
		if not meter then
			meter = globalPropertyf("sim/graphics/view/view_elevation_agl_mtrs")
		else
			elevation = get(meter)
		end
	else
		if not y_agl then
			y_agl =  globalPropertyf("sim/flightmodel/position/local_y")
		elseif not x_agl then
			x_agl = globalPropertyf("sim/flightmodel/position/local_x")
		elseif not z_agl then
			z_agl = globalPropertyf("sim/flightmodel/position/local_z")
		else
			elevation = get(y_agl)
			int_x_agl = get(x_agl)
			int_z_agl = get(z_agl)
			result , locationX , locationY , locationZ , normalX , normalY , normalZ , velocityX , velocityY , velocityZ , isWet = sasl.probeTerrain( int_x_agl, elevation , int_z_agl )
		end
	end

	AfterCall()

	if not planeLoad then
		if public.inHouse then
			if not oneTime_house then
				public.maxHeight = 103.1
				public.middleHeight = (public.maxHeight + public.minHeight) / 2
				public.minHeight = 101.5
				public.height = public.maxHeight
				public.locStatus = true
				public.insideWalkComp = false
				SetLocStatus()
				-- -7.3144536	-14.3543215
				public.houseStart = {x_door-3, 102.0562,  z_door+5}
				SetDataref(acf_peX, public.houseStart[1])
				SetDataref(acf_peY, public.houseStart[2])
				SetDataref(acf_peZ, public.houseStart[3])
				--library.Notify("Note this is a beta version there could be bugs!")
				library.wait(.5, function()
					oneTime_house = true
				end)
			end
		end
	end

	--------------------------------------------------------------------------------------------------------------------------------------
	
	--ROLL SYSTEM
	if generalSettings.settings.startedWalk  then
		set(phi, modelTthehta * math.sin(math.rad(hdg)) * -1)
	end

	--------------------------------------------------------------------------------------------------------------------------------------

	if iswalking == true and generalSettings.settings.sound == true then
		if not isSamplePlaying(walkSound) then playSample(walkSound) end
	else
		stopSample(walkSound)
	end

	--CROUCH SYSTEM

	if not xp_pilot_head_y then
		xp_pilot_head_y = globalPropertyf("sim/graphics/view/pilots_head_y")
	end

	if xp_pilot_head_y then
		initialPilotHeight = get(xp_pilot_head_y)
	end

	if version >= 12000 then
		--[[if not inHouse then

			if not oneTime_cam then
				oneTime_cam = true
				height = maxHeight
			end
		end]]

		if public.inHouse then
			public.maxHeight = 103.1
			public.minHeight = 101.5
			public.middleHeight = (public.maxHeight + public.minHeight) / 2
			if not oneTime_newCam then
				oneTime_newCam = true
				public.height = public.maxHeight
			end
		else
			public.maxHeight = 1.75
			public.minHeight = 0.7
			public.middleHeight = (public.maxHeight + public.minHeight) / 2
			if not oneTime_oldCam then
				oneTime_oldCam = true
				public.locStatus = true
				public.insideWalkComp = false
				public.height = public.maxHeight
				SetLocStatus()
			end
			--
		end
		
		--currentCrouch = public.maxHeight - 1.05 * (public.height - 2)
		if public.locStatus or not public.insideWalkComp then
			--print(maxHeight, minHeight, middleHeight, public.height)
			--SetDataref(acf_peY, currentHeight)
			realMaxHeight = (initialPilotHeight - elevation) +  public.maxHeight
			realMidHeight = (initialPilotHeight - elevation) + public.middleHeight
			realMinHeight = (initialPilotHeight - elevation) +  public.minHeight
			
			--print(initialPilotHeight, elevation, initialPilotHeight - elevation, height)
			--print(public.height)
			public.currentHeight = (initialPilotHeight - elevation) + public.height
			--print(height)

			if keys[5] then
				if public.currentHeight >= realMinHeight then
					public.currentHeight = public.currentHeight - .04
					public.height = public.height - .04
					SetDataref(acf_peY, public.currentHeight)
					--set(acf_peY, currentHeight)
				end
			end

			if keys[6] then
				if public.currentHeight <= realMaxHeight then
					public.currentHeight = public.currentHeight + .04
					public.height = public.height + .04
					SetDataref(acf_peY, public.currentHeight)
					--set(acf_peY, currentHeight)
				end
			end
		else
			realMaxHeight = y_door +  public.maxHeight
			realMidHeight = y_door + public.middleHeight
			realMinHeight = y_door +  public.minHeight

			public.currentHeight = y_door + public.height

			if keys[5] then
				if public.currentHeight >= realMinHeight then
					public.currentHeight = public.currentHeight - .04
					public.height = public.height - .04
					SetDataref(acf_peY, public.currentHeight)
					--set(acf_peY, currentHeight)
				end
			end

			if keys[6] then
				if public.currentHeight <= realMaxHeight then
					public.currentHeight = public.currentHeight + .04
					public.height = public.height + .04
					SetDataref(acf_peY, public.currentHeight)
					--set(acf_peY, currentHeight)
				end
			end
		end
	else
		if public.locStatus or not public.insideWalkComp then
			realMaxHeight = (locationY - elevation) +  public.maxHeight
			realMidHeight = (locationY - elevation) + public.middleHeight
			realMinHeight = (locationY - elevation) +  public.minHeight

			if keys[5] then
				if public.currentHeight >= realMinHeight then
					public.currentHeight = public.currentHeight - .04
					public.height = public.height - .04
					SetDataref(acf_peY, public.currentHeight)
					--set(acf_peY, currentHeight)
				end
			end

			if keys[6] then
				if public.currentHeight <= realMaxHeight then
					public.currentHeight = public.currentHeight + .04
					public.height = public.height + .04
					SetDataref(acf_peY, public.currentHeight)
					--set(acf_peY, currentHeight)
				end
			end
		else
			realMaxHeight = y_door +  public.maxHeight
			realMidHeight = y_door + public.middleHeight
			realMinHeight = y_door +  public.minHeight

			public.currentHeight = y_door + public.height

			if keys[5] then
				if public.currentHeight >= realMinHeight then
					public.currentHeight = public.currentHeight - .04
					public.height = public.height - .04
					SetDataref(acf_peY, public.currentHeight)
					--set(acf_peY, currentHeight)
				end
			end

			if keys[6] then
				if public.currentHeight <= realMaxHeight then
					public.currentHeight = public.currentHeight + .04
					public.height = public.height + .04
					SetDataref(acf_peY, public.currentHeight)
					--set(acf_peY, currentHeight)
				end
			end
		end
		--[[realMaxHeight = (locationY - elevation) +  maxHeight
		realMidHeight = (locationY - elevation) + middleHeight
		realMinHeight = (locationY - elevation) +  minHeight

		currentHeight = (locationY - elevation) + height

		if keys[5] then
			if currentHeight >= realMinHeight then
				currentHeight = currentHeight - .04
				height = height - .04
				set(acf_peY, currentHeight)
			end
		end

		if keys[6] then
			if currentHeight <= realMaxHeight then
				currentHeight = currentHeight + .04
				height = height + .04
				set(acf_peY, currentHeight)
			end
		end]]
	end

	--WALK SYSTEM
	walk = walk + .5

	if keys[1] and not both then
		angle = math.rad( hdg - 90 )
		sinX = x + speed * math.cos( angle )
		sinZ = z + speed * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)

		SetDataref(acf_peZ, sinZ)
		SetDataref(acf_peX, sinX)

		--set(acf_peZ, sinZ)
		--set(acf_peX, sinX)
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[2] and not both then
		angle = math.rad( hdg - 90 )
		sinX = x - speed * math.cos( angle )
		sinZ = z - speed * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)

		SetDataref(acf_peZ, sinZ)
		SetDataref(acf_peX, sinX)
		--set(acf_peZ, sinZ)
		--set(acf_peX, sinX)
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[3] and not both then
		angle = math.rad( hdg )
		sinX = x - speed * math.cos( angle )
		sinZ = z - speed * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)

		SetDataref(acf_peZ, sinZ)
		SetDataref(acf_peX, sinX)
		--set(acf_peZ, sinZ)
		--set(acf_peX, sinX)
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[4] and not both then
		angle = math.rad( hdg )
		sinX = x + speed * math.cos( angle )
		sinZ = z + speed * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)

		SetDataref(acf_peZ, sinZ)
		SetDataref(acf_peX, sinX)
		--set(acf_peZ, sinZ)
		--set(acf_peX, sinX)
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[1] and keys[4] then
		both = true

		angle = math.rad( hdg + 135 )
		sinX = x - speed * math.cos( angle )
		sinZ = z - speed * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)

		SetDataref(acf_peZ, sinZ)
		SetDataref(acf_peX, sinX)
		--set(acf_peZ, sinZ)
		--set(acf_peX, sinX)
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[1] and keys[3] then
		both = true

		angle = math.rad( hdg - 135 )
		sinX = x + speed * math.cos( angle )
		sinZ = z + speed * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)

		SetDataref(acf_peZ, sinZ)
		SetDataref(acf_peX, sinX)
		--set(acf_peZ, sinZ)
		--set(acf_peX, sinX)
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[2] and keys[3] then
		both = true

		angle = math.rad( hdg - 45 )
		sinX = x - speed * math.cos( angle )
		sinZ = z - speed * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)

		SetDataref(acf_peZ, sinZ)
		SetDataref(acf_peX, sinX)
		--set(acf_peZ, sinZ)
		--set(acf_peX, sinX)
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[2] and keys[4] then
		both = true

		angle = math.rad( hdg - 135 )
		sinX = x - speed * math.cos( angle )
		sinZ = z - speed * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)

		SetDataref(acf_peZ, sinZ)
		SetDataref(acf_peX, sinX)
		--set(acf_peZ, sinZ)
		--set(acf_peX, sinX)
	end

	if iswalking then
		--[[if XCamera then
			if generalSettings.settings.walk_movement == true and get(globalPropertyi("SRS/X-Camera/integration/X-Camera_enabled")) ~= 1 then
				SetDataref(acf_peY, currentHeight + (sinWalk * .015))
				--set(acf_peY, currentHeight + (sinWalk * .015))
			else
				SetDataref(acf_peY, currentHeight)
				--set(acf_peY, currentHeight)
			end
		else]]
			if generalSettings.settings.walk_movement == true then
				SetDataref(acf_peY, public.currentHeight + (sinWalk * .015))
				--set(acf_peY, currentHeight + (sinWalk * .015))
			else
				SetDataref(acf_peY, public.currentHeight)
				--set(acf_peY, currentHeight)
			end
		--end
	else
		leftUpArm = 0
		leftDoArm = 0

		rightUpArm = 0
		rightDoArm = 0

		leftUpLeg = 0
		leftDoLeg = 0

		rightUpLeg = 0
		rightDoLeg = 0

		step1 = .5
		step2 = .5
		step3 = .5
		step4 = .5
		step5 = .5
		step6 = .5
		step7 = .5
		step8 = .5
	end

	--ANIMATION
	if iswalking then
		if leftUpArm >= 1 then
			step1 = -animationSpeed
		elseif leftUpArm <= -1 then
			step1 = animationSpeed
		end
		leftUpArm = leftUpArm + step1
		-------------------------------------------------------------------------------
		if leftDoArm >= 1 then
			step5 = -animationSpeed
		elseif leftDoArm <= -1 then
			step5 = animationSpeed
		end
		leftDoArm = leftDoArm + step5
		-------------------------------------------------------------------------------
		if rightUpArm >= 1 then
			step2 = -animationSpeed
		elseif rightUpArm <= -1 then
			step2 = animationSpeed
		end
		rightUpArm = rightUpArm + step2
		-------------------------------------------------------------------------------
		if rightDoArm >= 1 then
			step6 = -animationSpeed
		elseif rightDoArm <= -1 then
			step6 = animationSpeed
		end
		rightDoArm = rightDoArm + step6
		-------------------------------------------------------------------------------
		if leftUpLeg >= 1 then
			step3 = -animationSpeed
		elseif leftUpLeg <= -1 then
			step3 = animationSpeed
		end
		leftUpLeg = leftUpLeg + step3
		-------------------------------------------------------------------------------
		if leftDoLeg >= 1 then
			step7 = -animationSpeed
		elseif leftDoLeg <= -1 then
			step7 = animationSpeed
		end
		leftDoLeg = leftDoLeg + step7
		-------------------------------------------------------------------------------
		if rightUpLeg >= 1 then
			step4 = -animationSpeed
		elseif rightUpLeg <= -1 then
			step4 = animationSpeed
		end
		rightUpLeg = rightUpLeg + step4
		-------------------------------------------------------------------------------
		if rightDoLeg >= 1 then
			step8 = -animationSpeed
		elseif rightDoLeg <= -1 then
			step8 = animationSpeed
		end
		rightDoLeg = rightDoLeg + step8
		-------------------------------------------------------------------------------
	end

	set(torso, currentCrouch)
	set(armsUpLeft, leftUpArm)
	set(armsDoLeft, leftDoArm)

	set(armsUpRight, rightUpArm)
	set(armsDoRight, rightDoArm)

	set(legsUpLeft,  leftUpLeg)
	set(legsDoLeft,  leftDoLeg)

	set(legsUpRight, rightUpLeg)
	set(legsDoRight, rightDoLeg)
	--------------------------------------------------------------------------------------------------------------------------------------

	if generalSettings.settings.startedWalk and version >= 12000 and generalSettings.settings.show_human and loadedObjects then
		set(showHide, 1)
		--print(get(armsUpLeft))
		local _x, _y, _z = sasl.modelToLocal(-sinX, realMidHeight + .1, -sinZ)
		sasl.setInstancePosition(ballInst, _x, _y, _z, 0, tHeading - 90, 0, {})
	else
		set(showHide, 0)
	end

	if generalSettings.settings.start_outside then
		if not oneTime then
			oneTime = true
			ResetCameras()
			--print(public.inHouse, oneTime_house)
			if public.inHouse then
				if not oneTime_house then
					public.height = public.maxHeight
					public.locStatus = true
					public.insideWalkComp = false
					SetLocStatus()
					-- -7.3144536	-14.3543215
					public.houseStart = {x_door-3, 102.0562,  z_door+5}
					SetDataref(acf_peX, public.houseStart[1])
					SetDataref(acf_peY, public.houseStart[2])
					SetDataref(acf_peZ, public.houseStart[3])
					--library.Notify("Note this is a beta version there could be bugs!")
					library.wait(.5, function()
						oneTime_house = true
					end)
				end
			end
		end
	end

	if globalClick.runWalk then
		globalClick.runWalk = false
		ResetCameras()
	end
end