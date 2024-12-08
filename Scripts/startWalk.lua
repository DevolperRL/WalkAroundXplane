local black	    = {0, 0, 0, 1}
local cyan	    = {0, 1, 1, 1}
local magenta	= {1, 0, 1, 1}
local yellow	= {1, 1, 0, 1}
local red       = {1, 0, 0, 1}
local white     = {1, 1, 1, 1}

local afterCall = false

if not generalSettings.settings.start_outside then
    generalSettings.settings.enabled = "Start Walking"
end

local fnt =  sasl.gl.loadFont(getXPlanePath() .. "Resources/fonts/DejaVuSansMono.ttf")

function draw()
    sasl.gl.drawRectangle(0, 0, size[1], size[2], white)
    drawText(fnt, 145, 13, tostring(generalSettings.settings.enabled), 30, false, false, TEXT_ALIGN_CENTER, black)
end

function onMouseDown()
    if get(crash_dataref) == 0 then
        globalClick.runWalk = true
        return true
    end
end