local distantLandConfig = require("colossus.distantLandConfig")

local function isCellElsweyr(cell)
    return cell and cell.id:endswith("Elsweyr, Oasis")
end

local function onCellChanged(e)
    local isElsweyr = isCellElsweyr(e.cell)
    local wasElsweyr = isCellElsweyr(e.previousCell)
    if isElsweyr and not wasElsweyr then
        distantLandConfig.setEnabled(true)
    elseif wasElsweyr and not isElsweyr then
        distantLandConfig.setEnabled(false)
    end
end
event.register("cellChanged", onCellChanged)
