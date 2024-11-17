OSSystem = sasl.getOS()

function OpenLink(url)
    if OSSystem == "Windows" then
        os.execute(string.format("start %s", url))
    elseif OSSystem == "Linux" then
        os.execute(string.format("open %s", url))
    elseif OSSystem == "Mac" then
        os.execute(string.format("xdg-open %s", url))
    end
end