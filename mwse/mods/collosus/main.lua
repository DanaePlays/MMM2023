local function onInitialized()
    if tes3.isModActive("Halls_of_Colossus.esm") then
        dofile("collosus.mcm")
        dofile("collosus.elsweyr")
    end
end
event.register("initialized", onInitialized)
