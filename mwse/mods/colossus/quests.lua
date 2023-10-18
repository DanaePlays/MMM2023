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
