local fnt =  sasl.gl.loadFont(getXPlanePath() .. "Resources/fonts/DejaVuSansMono.ttf")

local currentText = ""
local r,b,g,a = 0, 0, 0, 0

local fading = false
local alpha = 1
local fadeDuration = 2

function draw()
    if fading then
        alpha = alpha - (1 / (fadeDuration * 30))

        if alpha < 0 then
            alpha = 0
            fading = false
        end
    end

    drawText(fnt, size[1]/2, 0, currentText, 30, false, false, TEXT_ALIGN_CENTER, {1,1,1,alpha})
end

function library.Notify(text)
    r,b,g,alpha = 1, 1, 1, 1
    currentText = text
    library.wait(2, function()
        fading = true
    end)
end