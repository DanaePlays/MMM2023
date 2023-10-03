local toggleDistantLandConfig
do
    local enabled

    local drawDistance
    local aboveWaterFogStart
    local aboveWaterFogEnd

    local nearStaticEnd
    local farStaticEnd
    local veryFarStaticEnd

    local farStaticMinSize
    local veryFarStaticMinSize

    toggleDistantLandConfig = function(enabled)
        local c = mge.distantLandRenderConfig
        if enabled then
            drawDistance, c.drawDistance = c.drawDistance, 12.0
            aboveWaterFogStart, c.aboveWaterFogStart = c.aboveWaterFogStart, 3.3
            aboveWaterFogEnd, c.aboveWaterFogEnd = c.aboveWaterFogEnd, 12.0
            nearStaticEnd, c.nearStaticEnd = c.nearStaticEnd, 4.0
            farStaticEnd, c.farStaticEnd = c.farStaticEnd, 8.0
            veryFarStaticEnd, c.veryFarStaticEnd = c.veryFarStaticEnd, 11.8
            farStaticMinSize, c.farStaticMinSize = c.farStaticMinSize, 600.00
            veryFarStaticMinSize, c.veryFarStaticMinSize = c.veryFarStaticMinSize, 800.00
        else
            c.drawDistance = drawDistance or c.drawDistance
            c.aboveWaterFogStart = aboveWaterFogStart or c.aboveWaterFogStart
            c.aboveWaterFogEnd = aboveWaterFogEnd or c.aboveWaterFogEnd
            c.nearStaticEnd = nearStaticEnd or c.nearStaticEnd
            c.farStaticEnd = farStaticEnd or c.farStaticEnd
            c.veryFarStaticEnd = veryFarStaticEnd or c.veryFarStaticEnd
            c.farStaticMinSize = farStaticMinSize or c.farStaticMinSize
            c.veryFarStaticMinSize = veryFarStaticMinSize or c.veryFarStaticMinSize
        end
        mwse.log("[Colossus] toggleDistantLandConfig(enabled=%s)", enabled)
    end
end


local function isCellElsweyr(cell)
    return cell and cell.id == "Elsweyr"
end

local function onCellChanged(e)
    local isElsweyr = e.cell and e.cell.id == "Elsweyr"
    local wasElsweyr = e.previousCell and e.previousCell.id == "Elsweyr"
    if isElsweyr and not wasElsweyr then
        toggleDistantLandConfig(true)
    elseif wasElsweyr and not isElsweyr then
        toggleDistantLandConfig(false)
    end
    -- TODO: Do we handle the case where PC enters the cell, then reloads to a different save?
end
event.register("cellChanged", onCellChanged)
