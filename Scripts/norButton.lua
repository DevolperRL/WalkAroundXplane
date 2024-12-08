function onMouseDown()
    get(click)
    return true
end

function draw()
    drawRectangle(0, 0, size[1], size[2], get(color))
    drawText(get(font), size[1]/2, size[2]/2-5, get(text), get(fontSize), false, false, TEXT_ALIGN_CENTER, {1,1,1,1})
end