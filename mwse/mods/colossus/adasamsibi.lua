local distantLandConfig = require("colossus.distantLandConfig")
local cameraShake = require("colossus.effects.cameraShake")
local heartBeat = require("colossus.effects.heartBeat")

local glitch = require("colossus.shaders.glitch")
local flash = require("colossus.shaders.flash")
local blackout = require("colossus.shaders.blackout")

local log = require("colossus.log")
local utils = require("colossus.utils")

timer.register("colossus:jailArrival", function()
    tes3.mobilePlayer.fatigue.current = 1

    local evidenceChest = tes3.getReference("ggw_evidence_chest")
    for _, stack in pairs(tes3.player.object.inventory) do
        if stack.object.canCarry ~= false then
            tes3.transferItem({
                from = tes3.player,
                to = evidenceChest,
                item = stack.object,
                count = stack.count,
                playSound = false,
            })
        end
    end
    tes3.updateInventoryGUI({ reference = tes3.player })

    tes3.setJournalIndex({ id = "ggw_02_tg", index = 5, showMessage = true })
end)

timer.register("colossus:teleportJail", function()
    blackout.stop()
    cameraShake.stop()

    tes3.positionCell({
        cell = "Elsweyr, Imperial Outpost",
        position = { 508.01, -67.72, -628.55 },
        orientation = { 0.00, 0.00, 0.02 },
    })

    tes3.fadeIn({ duration = 6.0 })
    timer.start({ duration = 6.0, callback = "colossus:jailArrival" })
end)

timer.register("colossus:collapse", function()
    tes3.mobilePlayer.fatigue.current = -10000

    tes3.fadeOut({ duration = 1.0 })
    timer.start({ duration = 6.0, callback = "colossus:teleportJail" })
end)

--- Trigger effects when activating the artifact.
---
---@param e activateEventData
local function onActivate(e)
    if e.target.id ~= "ggw_artifact" then
        return
    end

    -- Trigger a white flash and sound effect.

    flash.trigger({ duration = 1.5 })

    tes3.playSound({
        reference = tes3.player,
        sound = "ggw_teleport",
        mixChannel = tes3.soundMix.master,
    })

    -- Teleport to desert and do additional effects.
    timer.delayOneFrame(function()
        local offset = tes3vector3.new(1024, 0, 128) * 100
        tes3.player.position = tes3.player.position + offset

        -- Skip to 7 am for pretty sunrise lighting.
        utils.setCurrentHour(7)

        -- Stop the artifact effects.
        glitch.stop()
        heartBeat.stop()

        cameraShake.start({
            intensity = 2.0,
            duration = 15.0,
        })

        blackout.start({
            leadup = 4.0,
            duration = 15.0,
            delayMin = 1.5,
            delayMax = 3.0,
        })

        timer.start({
            duration = 15.0,
            callback = "colossus:collapse",
        })
    end)

    return false
end
event.register("activate", onActivate)


local function enteredAdasamsibi()
    local ref = tes3.getReference("ggw_artifact")
    if ref == nil then
        log:error("getReference Failed: 'ggw_artifact'")
        return
    end

    glitch.start(ref)
    heartBeat.start(ref)
    distantLandConfig.setEnabled(true)
end


local function exitedAdasamsibi()
    glitch.stop()
    heartBeat.stop()
    distantLandConfig.setEnabled(false)
end


local function onCellChanged(e)
    local isAdasamsibi = e.cell.id == "Adasamsibi"
    local wasAdasamsibi = e.previousCell and e.previousCell.id == "Adasamsibi"
    if isAdasamsibi and not wasAdasamsibi then
        enteredAdasamsibi()
    elseif wasAdasamsibi and not isAdasamsibi then
        exitedAdasamsibi()
    end
end
event.register("cellChanged", onCellChanged, { priority = 1 })
