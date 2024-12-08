local fnt =  sasl.gl.loadFont(getXPlanePath() .. "Resources/fonts/DejaVuSansMono.ttf")

local functionKeys = {}

function draw( ... )
    drawText(fnt, 250, 450, "Input Settings", 30, false, false, TEXT_ALIGN_CENTER, {1,1,1,1})
    for i, k in pairs(generalSettings.currentKeys) do
        drawText(fnt, 250, generalSettings.currentKeys[i].cpos, "Current " .. generalSettings.currentKeys[i].ctype .. " Key: " .. generalSettings.currentKeys[i].ckey, 20, false, false, TEXT_ALIGN_CENTER, {1,1,1,1})
    end

    drawAll(components)
end

--------------------------------------------------------------------------------------------------------------------------------------
function functionKeys.SetForwardKey(char, vkey, shiftDown, ctrlDown, altOptDown, event)
    if event == KB_DOWN_EVENT then
        if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			return true
		end
        generalSettings.currentKeys.forward.ckey = string.upper(string.char(char))
        generalSettings.currentKeys.forward.cvkey = vkey
        return true
    end
end
--------------------------------------------------------------------------------------------------------------------------------------
function functionKeys.SetBackwardsKey(char, vkey, shiftDown, ctrlDown, altOptDown, event)
    if event == KB_DOWN_EVENT then
        if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			return true
		end
        generalSettings.currentKeys.backwards.ckey  = string.upper(string.char(char))
        generalSettings.currentKeys.backwards.cvkey = vkey
        return true
    end
end
--------------------------------------------------------------------------------------------------------------------------------------
function functionKeys.SetLeftwardsKey(char, vkey, shiftDown, ctrlDown, altOptDown, event)
    if event == KB_DOWN_EVENT then
        if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			return true
		end
        generalSettings.currentKeys.leftwards.ckey  = string.upper(string.char(char))
        generalSettings.currentKeys.leftwards.cvkey = vkey
        return true
    end
end
--------------------------------------------------------------------------------------------------------------------------------------
function functionKeys.SetRightwardsKey(char, vkey, shiftDown, ctrlDown, altOptDown, event)
    if event == KB_DOWN_EVENT then
        if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			return true
		end
        generalSettings.currentKeys.rightwards.ckey  = string.upper(string.char(char))
        generalSettings.currentKeys.rightwards.cvkey = vkey
        return true
    end
end
--------------------------------------------------------------------------------------------------------------------------------------
function functionKeys.SetSprintKey(char, vkey, shiftDown, ctrlDown, altOptDown, event)
    if event == KB_DOWN_EVENT then
        if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			return true
		end
        generalSettings.currentKeys.sprint.ckey  = string.upper(string.char(char))
        generalSettings.currentKeys.sprint.cvkey = vkey
        return true
    end
end
--------------------------------------------------------------------------------------------------------------------------------------
function functionKeys.SetCrouchUpKey(char, vkey, shiftDown, ctrlDown, altOptDown, event)
    if event == KB_DOWN_EVENT then
        if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			return true
		end
        generalSettings.currentKeys.crouchUp.ckey  = string.upper(string.char(char))
        generalSettings.currentKeys.crouchUp.cvkey = vkey
        return true
    end
end
--------------------------------------------------------------------------------------------------------------------------------------
function functionKeys.SetCrouchDownKey(char, vkey, shiftDown, ctrlDown, altOptDown, event)
    if event == KB_DOWN_EVENT then
        if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			return true
		end
        generalSettings.currentKeys.crouchDown.ckey  = string.upper(string.char(char))
        generalSettings.currentKeys.crouchDown.cvkey = vkey
        return true
    end
end
--------------------------------------------------------------------------------------------------------------------------------------
function functionKeys.SetChangeLocKey(char, vkey, shiftDown, ctrlDown, altOptDown, event)
    if event == KB_DOWN_EVENT then
        if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			return true
		end
        generalSettings.currentKeys.changeLoc.ckey  = string.upper(string.char(char))
        generalSettings.currentKeys.changeLoc.cvkey = vkey
        return true
    end
end
--------------------------------------------------------------------------------------------------------------------------------------
function functionKeys.SaveLocKey(char, vkey, shiftDown, ctrlDown, altOptDown, event)
    if event == KB_DOWN_EVENT then
        if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			return true
		end
        generalSettings.currentKeys.savedLoc.ckey  = string.upper(string.char(char))
        generalSettings.currentKeys.savedLoc.cvkey = vkey
        return true
    end
end
--------------------------------------------------------------------------------------------------------------------------------------

local function CallOther(func)
    registerHandler(functionKeys[func])
end

components = {
    invisible_button {
        position = {100, 400, 280, 20},--generalSettings.currentKeys.forward.cpos
        click = function()
            CallOther("SetForwardKey")
        end
    },

    invisible_button {
        position = {100, 360, 280, 20},--generalSettings.currentKeys.backwards.cpos
        click = function()
            CallOther("SetBackwardsKey")
        end
    },

    invisible_button {
        position = {100, 320, 280, 20},--generalSettings.currentKeys.leftwards.cpos
        click = function()
            CallOther("SetLeftwardsKey")
        end
    },

    invisible_button {
        position = {100, 280, 280, 20},--generalSettings.currentKeys.rightwards.cpos
        click = function()
            CallOther("SetRightwardsKey")
        end
    },

    invisible_button {
        position = {100, 240, 280, 20},--generalSettings.currentKeys.sprint.cpos
        click = function()
            CallOther("SetSprintKey")
        end
    },

    invisible_button {
        position = {100, 200, 280, 20},--generalSettings.currentKeys.crouchUp.cpos
        click = function()
            CallOther("SetCrouchUpKey")
        end
    },

    invisible_button {
        position = {100, 160, 280, 20},--generalSettings.currentKeys.crouchDown.cpos
        click = function()
            CallOther("SetCrouchDownKey")
        end
    },
    
    invisible_button {
        position = {100, 120, 280, 20},--generalSettings.currentKeys.changeLoc.cpos
        click = function()
            CallOther("SetChangeLocKey")
        end
    },

    invisible_button {
        position = {100, 80, 280, 20},--generalSettings.currentKeys.savedLoc.cpos
        click = function()
            CallOther("SaveLocKey")
        end
    },
}