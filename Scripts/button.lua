--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]

local black	    = {0, 0, 0, 1}
local cyan	    = {0, 1, 1, 1}
local magenta	= {1, 0, 1, 1}
local yellow	= {1, 1, 0, 1}
local red       = {1, 0, 0, 1}
local white     = {1, 1, 1, 1}

local fnt =  sasl.gl.loadFont(getXPlanePath() .. "Resources/fonts/DejaVuSansMono.ttf")

local isVisible = {}
isVisible.button1 = true
isVisible.button2 = true
isVisible.button3 = true
isVisible.button4 = true
isVisible.button5 = true

function WalkMovement()
    generalSettings.settings.walk_movement = not generalSettings.settings.walk_movement
end

function Sound()
    generalSettings.settings.sound = not generalSettings.settings.sound
end

function SaveConfig()
    print("Saved")
    SaveAll()
    --library.Notify("Settings Saved")
    --sasl.writeConfig ( "WalkAround.json" , "JSON" , generalSettings )
end

function Reboot()
    sasl.scheduleProjectReboot()
end

function OpenWindowButton()
    generalSettings.settings.window_button = not generalSettings.settings.window_button
end

function NextPage()
    if pages.page < pages.maxPages then
        pages.page = pages.page + 1
    else
        pages.page = 1
    end
end

function PreviousPage()
    if pages.page > 1 then
        pages.page = pages.page - 1
    else
        pages.page = pages.maxPages
    end
end

function ShowHuman()
    generalSettings.settings.show_human = not generalSettings.settings.show_human
end

function StartOutside()
    generalSettings.settings.start_outside = not generalSettings.settings.start_outside
end

function ShowMainWin()
    generalSettings.settings.show_main_win = not generalSettings.settings.show_main_win
end

function Button1()
    if pages.page == 1 then
        WalkMovement()
    elseif pages.page == 2 then
        ShowHuman()
    end
end

function Button2()
    if pages.page == 1 then
        Sound()
    elseif pages.page == 2 then
        StartOutside()
    end
end

function Button3()
    if pages.page == 1 then
        OpenWindowButton()
    elseif pages.page == 2 then
        ShowMainWin()
    end
end

function Button4()
    SaveConfig()
end

function Button5()
    Reboot()
end

function draw()
    drawAll(components)
end

function update()
    if pages.page == 1 then
        isVisible.button1 = true
    else
        isVisible.button1 = false
    end
end

components = {
    setting {position = {120 ,225, 170, 50}, action = Button1, visible = isVisible.button3, tag = "button1"},
    setting {position = {120, 170, 170, 50}, action = Button2, visible = isVisible.button2, tag = "button2"},
    setting {position = {120, 110, 170, 50}, action = Button3, visible = isVisible.button1, tag = "button3" },
    setting {position = {120, 50, 170, 50}, action = Button4, visible = isVisible.button4, tag = "button4"},
    setting {position = {120, -10, 170, 50}, action = Button5, visible = isVisible.button5, tag = "button5"},
    pageButtonRight {position = {500, 320, 60, 60}, action = NextPage },
    pageButtonLeft {position = {115, 320, 60, 60}, action = PreviousPage },
}