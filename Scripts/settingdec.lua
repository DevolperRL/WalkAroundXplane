--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]

include "button"

local black	    = {0, 0, 0, 1}
local cyan	    = {0, 1, 1, 1}
local magenta	= {1, 0, 1, 1}
local yellow	= {1, 1, 0, 1}
local red       = {1, 0, 0, 1}
local white     = {1, 1, 1, 1}

local backGround = sasl.gl.loadImage("Images/BackGround.png")

local fnt =  sasl.gl.loadFont(getXPlanePath() .. "Resources/fonts/DejaVuSansMono.ttf")

function draw()
    sasl.gl.drawTexture(backGround, -375, -90, 680, 430)
    sasl.gl.drawTexture(backGround, -230, -90, 870, 430)

    drawText(fnt, 70, -80, "Page " .. tostring(pages.page) .. "/" .. tostring(pages.maxPages), 15, false, false, TEXT_ALIGN_CENTER, white)

    drawText(fnt, 205, 250, "Description", 30, false, false, TEXT_ALIGN_CENTER, white)
    local info = ""

    drawText(fnt, 90, 340, "Settings", 50, false, false, TEXT_ALIGN_CENTER, white)
    drawText(fnt, -35, 40, "Reboot plugin", 15, false, false, TEXT_ALIGN_CENTER, white)
    drawText(fnt, -30, -10, "BEFORE REBOOT PLUGIN \nSAVE YOUR SETTINGS, \nNOT SAVE YOU WILL \nLOSE ALL YOUR SETTINGS!", 10, false, false, TEXT_ALIGN_CENTER, red)
    drawText(fnt, -35, 100, "Save", 15, false, false, TEXT_ALIGN_CENTER, white)

    if pages.page == 1 then
        drawText(fnt, -35, 275, "Up/Down", 15, false, false, TEXT_ALIGN_CENTER, white)
        drawText(fnt, -35, 215, "Sound", 15, false, false, TEXT_ALIGN_CENTER, white)
        drawText(fnt, -35, 158, "Open Window Button", 15, false, false, TEXT_ALIGN_CENTER, white)

        if generalSettings.settings.walk_movement == true then
            info = info .. "Walk is ON"
        else
            info = info .. "Walk is OFF"
        end
    
        if generalSettings.settings.sound == true then
            info = info .. "\nSound is ON"
        else
            info = info .. "\nSound is OFF"
        end
    
        if generalSettings.settings.window_button == true then
            info = info .. "\nwindows button is ON"
        else
            info = info .. "\nwindows button is OFF"
        end
    elseif pages.page == 2 then
        drawText(fnt, -35, 275, "Human", 15, false, false, TEXT_ALIGN_CENTER, white)
        drawText(fnt, -35, 215, "Start outside on start", 15, false, false, TEXT_ALIGN_CENTER, white)
        drawText(fnt, -35, 158, "Show main win on start", 15, false, false, TEXT_ALIGN_CENTER, white)

        if generalSettings.settings.show_human == true then
            info = info .. "Show human is ON"
        else
            info = info .. "Show human is OFF"
        end
    
        if generalSettings.settings.start_outside == true then
            info = info .. "\nStart Outside is ON"
        else
            info = info .. "\nStart Outside is OFF"
        end
    
        if generalSettings.settings.show_main_win == true then
            info = info .. "\nShow main win is ON"
        else
            info = info .. "\nShow main win is OFF"
        end
    end
    drawText(fnt, 205, 210, info, 17, false, false, TEXT_ALIGN_CENTER, white)
end