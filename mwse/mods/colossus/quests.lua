--- Swap between living/decaying references depending on quest state.
---
---@param e referenceActivatedEventData
local function updateLivingOrDecayingReferences(e)
    local id = e.reference.id
    if not id:find("^ggw_") then
        return
    end

    local index = tes3.getJournalIndex({ id = "ggw_01_intro" })
    local isDecaying = index < 100

    if id:find("^ggw_L_") then
        if isDecaying then
            e.reference:disable()
        else
            e.reference:enable()
        end
    end

    if id:find("^ggw_D_") then
        if isDecaying then
            e.reference:enable()
        else
            e.reference:disable()
        end
    end
end
event.register("referenceActivated", updateLivingOrDecayingReferences)


---@param e mwseOverrideScriptCallbackData
mwse.overrideScript("ggw_finale_script", function(e)
    if tes3ui.menuMode() then
        return
    end

    tes3.setJournalIndex({
        id = "ggw_01_intro",
        index = 100,
        showMessage = true,
    })

    tes3.positionCell({
        reference = tes3.player,
        cell = "Adasamsibi",
        position = { 10967.27, -941.22, 942.81 },
        orientation = { 0.00, 0.00, -1.60 },
    })

    tes3.playSound({
        reference = tes3.player,
        sound = "ggw_teleport",
        mixChannel = tes3.soundMix.master,
    })

    local flash = require("colossus.shaders.flash")
    flash.trigger({ duration = 1.5 })

    ---@diagnostic disable-next-line: deprecated
    mwscript.stopScript({ script = e.script })
end)
