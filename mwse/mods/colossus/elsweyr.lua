local distantLandConfig = require("colossus.distantLandConfig")

local function onCellChanged(e)
    local isElsweyr = e.cell and e.cell.id == "Elsweyr, Oasis"
    local wasElsweyr = e.previousCell and e.previousCell.id == "Elsweyr, Oasis"
    if isElsweyr and not wasElsweyr then
        distantLandConfig.setEnabled(true)
    elseif wasElsweyr and not isElsweyr then
        distantLandConfig.setEnabled(false)
    end
end
event.register("cellChanged", onCellChanged)
