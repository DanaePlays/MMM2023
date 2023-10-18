local log = require("colossus.log")

local this = {}

---@class flashParams
---@field duration number

---@param params flashParams
function this.trigger(params)
    local shader = mge.shaders.load({ name = "ggw_flash" })
    if shader == nil then
        log:error("Failed to load shader: ggw_flash")
        return
    end

    ---@diagnostic disable

    local duration = params.duration
    local elapsed = 0.0

    shader.enabled = true
    shader.elapsed = elapsed
    shader.duration = duration

    local function update(e)
        ---@cast e simulateEventData
        elapsed = elapsed + e.delta
        if elapsed <= duration then
            shader.elapsed = elapsed
        else
            shader.enabled = false
            event.unregister("simulate", update)
        end
    end
    event.register("simulate", update)

    ---@diagnostic enable
end

return this
