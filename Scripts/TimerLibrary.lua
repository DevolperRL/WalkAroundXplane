--[[
    Copyright by Raoul Origa
    Delay Library
    If you have any question or problem join the discord server: https://discord.gg/drfsP4jCQH
]]

local times = {}

local timerRun = false

function library.wait(delay, callback)
    local newTimer = {sasl.createPerformanceTimer(), delay, false, callback}
    table.insert(times, newTimer)
end

function update()
   for i, v in ipairs(times) do
        if v[3] == false then
            sasl.startTimer(v[1])
            v[3] = true
        end

        time_ = sasl.getElapsedSeconds(v[1])
        --print(time_)
        if time_ >= v[2] then
            table.remove(times, i)
            if v[4] then
                v[4]()
            end
        end
    end
end
