dofile("colossus.spells") -- TODO: mod active check before initialized (?)

local function onInitialized()
    if tes3.isModActive("Halls_of_Colossus.esm") then
        dofile("colossus.mcm")
        dofile("colossus.quests")
        dofile("colossus.elsweyr")
        dofile("colossus.adasamsibi")
        dofile("colossus.shaders.timeWound")
    end
end
event.register("initialized", onInitialized)
