tes3.claimSpellEffectId("ggwReintegrateArmor", 1702)

event.register("magicEffectsResolved", function()
    tes3.addMagicEffect({
        id = tes3.effect.ggwReintegrateArmor,
        name = "Reintegrate Armor",
        school = tes3.magicSchool.restoration,
        description = "This effect restores the health rating of equipped armor.",
        baseMagickaCost = 6.0,
        icon = "ggw\\s\\tx_reinteg_armo.dds",
        particleTexture = "vfx_bluecloud.tga",
        castSound = "restoration cast",
        castVFX = "VFX_RestorationCast",
        boltSound = "restoration bolt",
        boltVFX = "VFX_RestorationBolt",
        hitSound = "restoration hit",
        hitVFX = "VFX_RestorationHit",
        areaSound = "restoration area",
        areaVFX = "VFX_RestorationArea",
        allowSpellmaking = true,
        allowEnchanting = false,
        appliesOnce = false,
        canCastSelf = true,
        canCastTarget = true,
        canCastTouch = true,
        casterLinked = false,
        hasContinuousVFX = false,
        hasNoDuration = false,
        hasNoMagnitude = false,
        illegalDaedra = false,
        isHarmful = false,
        nonRecastable = false,
        targetsAttributes = false,
        targetsSkills = false,
        unreflectable = false,
        usesNegativeLighting = false,

        onTick = function(e)
            e:trigger()

            local magnitude = e.effectInstance.effectiveMagnitude
            if magnitude == 0 then
                return
            end

            e.effectInstance.state = tes3.spellState.retired

            local target = e.effectInstance.target
            if target == nil then
                return
            end

            for _, stack in pairs(target.object.equipment) do
                if stack.object.objectType == tes3.objectType.armor then
                    local maxCondition = stack.object.maxCondition
                    local condition = stack.itemData.condition

                    if condition < maxCondition then
                        local effect = e.sourceInstance.sourceEffects[e.effectIndex + 1]
                        magnitude = magnitude * math.max(effect.duration, 1)

                        stack.itemData.condition = math.min(condition + magnitude, maxCondition)
                        break
                    end
                end
            end
        end,
    })
end)
