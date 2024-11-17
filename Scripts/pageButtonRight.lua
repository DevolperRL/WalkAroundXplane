local fnt =  sasl.gl.loadFont(getXPlanePath() .. "Resources/fonts/DejaVuSansMono.ttf")

local button = sasl.gl.loadImage("Images/ArrowRight_btn.png")

local white = {1, 1, 1, 1}

function onMouseDown(component, x, y, button, parentX, parentY)
    get(action)
    return true
end

function draw()
    sasl.gl.drawTexture (button , 0, 0, size[1], size[2], white)
end