local config = require("collosus.config")

local function leaveMCM()
    pcall(function()
        tes3ui.getMenuOnTop()
            :findChild("MWSE:ModConfigMenu_Close")
            :triggerEvent("mouseClick")
        tes3ui.getMenuOnTop()
            :findChild("MenuOptions_Return_container")
            :triggerEvent("mouseClick")
    end)
end


local template = mwse.mcm.createTemplate({ name = "Halls of Collosus" })
template:saveOnClose("collosus", config)
template:register()

local preferences = template:createSideBarPage({ label = "Preferences" })
preferences.sidebar:createInfo({
    text = "Version 0.0.0\n\n"
        .. "Debug functions for development. Can only be used after loading in-game.",
})

local teleports = preferences:createCategory({ label = "Cells" })
teleports:createDropdown({
    description = "Teleport to the various cells created for this mod.",
    inGameOnly = true,
    options = {
        {
            label = "Elsweyr",
            value = {
                reference = "player",
                cell = "Elsweyr",
                position = {-666.00,365.00,7000.00},
                orientation = {0.0,0.0,0.0},
            },
        },
        {
            label = "Cave Exterior",
            value = {
                reference = "player",
                cell = "Grazelands Region",
                position = {71377.05,69741.88,890.79},
                orientation = {0.00,0.00,-1.54},
            },
        },
        {
            label = "Cave Interior",
            value = {
                reference = "player",
                cell = "ggw cave",
                position = {-450.76,1443.23,523.56},
                orientation = {0.00,0.00,-2.52},
            },
        },
    },
    variable = mwse.mcm:createVariable({
        set = function(self, value)
            timer.frame.delayOneFrame(leaveMCM)
            tes3.positionCell(value)
        end,
    }),
})
