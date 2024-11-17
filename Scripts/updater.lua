---@meta github
---@class git

git = {}

--[[---comment
---@param url string
---@param path string
---@param word string
function git.GetTxt(url, path, word)
    local updaterData = io.open(path)
    if updaterData ~= nil then
        local ver = ""
        print(updaterData:lines())
        for line in updaterData:lines() do
            if string.match(line, word) then
            end
        end
    end
    return false
end
]]
function setUpdateStatus(inUrl , inFilePath , inIsOk , inError )
    if inIsOk then
        local newData = io.open(getMyPluginPath():sub(1, -3) .. "data/modules/version.txt")
        local ver = ""
        for line in newData:lines() do
            if string.match(line, "version") then
                ver = line:sub(10)
                public.online_version = ver
            end
        end
    end
end

---comment
---@param url string
---@param path string
function git.CheckUpdate(url, path)
    sasl.net.downloadFileAsync(url, path, setUpdateStatus)
end

function createTokens(str, separator)
    local tokens = {}
    for token in string.gmatch(str, "[^%"..separator.."]+") do
        table.insert(tokens, token)
    end
    return tokens
end

---comment
---@param url string
---@param path string
function git.UpdateLua(url, path)
    downloadResult , error = sasl.net.downloadFileSync (url, path)
    local succefull = {}
    local failed = {}
    log.AddLog("Download Result: " .. tostring(downloadResult))
    log.AddLog(tostring(error))
    local file = io.open(path)
    if file then
        log.AddLog("Reading File")
        for line in file:lines() do
            if string.match(line, ".lua") then
                local path = getMyPluginPath():sub(1, -3) .. "data/modules/Custom Module/"
                local tk = createTokens(line, ",")
                local fileName = tk[1]
                local n_url = tk[2]
                n_url = n_url:sub(2)
                log.AddLog("Updating: " .. fileName)
                if string.match(line, "main.lua") then
                   path = getMyPluginPath():sub(1, -3) .. "data/modules/"
                   downloadResult , error = sasl.net.downloadFileSync (n_url, path)
                   if not downloadResult then
                    table.insert(failed, fileName)
                else
                    table.insert(succefull, fileName)
                end
                   log.AddLog("Download Result: " .. tostring(downloadResult))
                   log.AddLog(tostring(error))
                else
                    path = path .. fileName
                    downloadResult , error = sasl.net.downloadFileSync (n_url, path)
                    if not downloadResult then
                        table.insert(failed, fileName)
                    else
                        table.insert(succefull, fileName)
                    end
                    log.AddLog("Download Result: " .. tostring(downloadResult))
                    log.AddLog(tostring(error))
                end
            end
        end
        for i, v in pairs(succefull) do
            log.AddLog("Succefull: " .. v)
        end
        
        for i, v in pairs(failed) do
            log.AddLog("[ERROR]: Failed: " .. v)
        end
    else
        log.AddLog("[ERROR]: No file exist")
    end
    --print(downloadResult, error)
end