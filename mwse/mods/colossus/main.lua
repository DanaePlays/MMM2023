local function onInitialized()
    if tes3.isModActive("Halls_of_Colossus.esm") then
        dofile("colossus.mcm")
        dofile("colossus.quests")
        dofile("colossus.elsweyr")
        dofile("colossus.adasamsibi")
    end
end
event.register("initialized", onInitialized)
