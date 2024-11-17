--Colors
local black	    = {0, 0, 0, 1}
local cyan	    = {0, 1, 1, 1}
local magenta	= {1, 0, 1, 1}
local yellow	= {1, .7, 0, 1}
local red       = {1, 0, 0, 1}
local white     = {1, 1, 1, 1}

--Font
local fnt =  sasl.gl.loadFont(getXPlanePath() .. "Resources/fonts/DejaVuSansMono.ttf")

function draw()
    drawRectangle(size[1]/2-250, 110, 500, 300, white)
    drawText(fnt, 350, 390, "Update Log", 20, false, false, TEXT_ALIGN_CENTER, black)
    for i, v in ipairs(public.updateLog) do
        if string.match(v, "WARNING") then
            drawText(fnt, 105, 380 - (i*16), "["..i.."] ".. v, 13, false, false, TEXT_ALIGN_LEFT, yellow)
        elseif string.match(v, "ERROR") then
            drawText(fnt, 105, 380 - (i*16), "["..i.."] ".. v, 13, false, false, TEXT_ALIGN_LEFT, red)
        else
            drawText(fnt, 105, 380 - (i*16), "["..i.."] ".. v, 13, false, false, TEXT_ALIGN_LEFT, black)
        end
    end
    drawAll(components)
end

function CheckUpdates()
    git.CheckUpdate("https://raw.githubusercontent.com/DevolperRL/WalkAroundXplane/refs/heads/main/updaterData.txt", getMyPluginPath():sub(1, -3) .. "data/modules/version.txt")
    if pg_version == public.online_version then
        log.AddLog("No Update Available")
    else
        log.AddLog("Update Available: " .. public.online_version)
    end
end

function Update()
    git.UpdateLua("https://raw.githubusercontent.com/DevolperRL/WalkAroundXplane/refs/heads/main/updaterData.txt", getMyPluginPath():sub(1, -3) .. "data/modules/version.txt")
end

components = {
    norButton {
        position = {20, 450, 160, 30},
        color = {.5, .5, .5, 1},
        fontSize = 15,
        font = fnt,
        text = "Check for updates",
        click = function()
            CheckUpdates()
        end
    },
    norButton {
        position = {size[1]/2-80, 30, 160, 40},
        color = {.5, .5, .5, 1},
        fontSize = 20,
        font = fnt,
        text = "Update",
        click = function()
            Update()
        end
    },
}

function update()
    updateAll(components)
end