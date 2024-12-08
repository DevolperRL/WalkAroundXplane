---@meta Log
---@class log

log = {}

---Add Log
---@param text string
function log.AddLog(text)
    local added = false
    for i, v in ipairs(public.updateLog) do
        if v == " " then
            public.updateLog[i] = text
            added = true
            break
        end
    end

    -- If no empty slot, overwrite the oldest value
    if not added then
        -- Shift all values up by one position
        for i = 1, #public.updateLog - 1 do
            public.updateLog[i] = public.updateLog[i + 1]
        end

        -- Add the new value at the last position
        public.updateLog[#public.updateLog] = text
    end
end