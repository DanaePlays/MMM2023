local log = require("colossus.log")

local this = {}

---@type mwseTimer?
local glitchTimer

---@param ref tes3reference
function this.start(ref)
    log:debug("Start glitch: %s", ref)

    local shader = mge.shaders.load({ name = "ggw_glitch" })
    if shader == nil then
        log:error("Failed to load shader: ggw_glitch")
        return
    end

    ---@diagnostic disable

    shader.enabled = true
    shader.intensity = 0.01
    shader.sphereCenter = ref.sceneNode.worldBoundOrigin
    shader.sphereRadius = ref.sceneNode.worldBoundRadius * 20

    local handle = tes3.makeSafeObjectHandle(ref)

    glitchTimer = timer.start({
        iterations = -1,
        duration = 0.1,
        callback = function()
            if not handle:valid() then
                glitchTimer:cancel()
                return
            end

            local ref = handle:getObject()
            local distance = tes3.player.position:distance(ref.position)
            distance = math.clamp(distance, 0, 1600)

            local intensity = math.remap(distance, 1600, 0, 0.02, 0.04)
            shader.intensity = intensity
        end,
    })

    ---@diagnostic enable
end

function this.stop()
    log:debug("Stop glitch")

    local shader = mge.shaders.load({ name = "ggw_glitch" })
    if shader then
        shader.enabled = false
    end

    if glitchTimer then
        glitchTimer:cancel()
        glitchTimer = nil
    end
end

return this
