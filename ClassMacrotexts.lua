


local class = UnitClass("player")

if class == "Priest" then
CONTROLFREAKTARGETTYPES = {Undead = true}
CONTROLFREAKSPELL = "Shackle Undead"
CONTROLFREAKMACROTEXT = [[
/cast [target=focus,exists,nodead,harm] Shackle Undead
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] Shackle Undead
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
]]

elseif class == "Mage" then
CONTROLFREAKTARGETTYPES = {Beast = true, Humanoid = true, Critter = true}
CONTROLFREAKSPELL = "Polymorph"
CONTROLFREAKMACROTEXT = [[
/cast [target=focus,exists,nodead,harm] Polymorph
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] Polymorph
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
]]

elseif class == "Druid" then
CONTROLFREAKTARGETTYPES = {Beast = true, Dragonkin = true}
CONTROLFREAKSPELL = "Hibernate"
CONTROLFREAKMACROTEXT = [[
/cast [target=focus,exists,nodead,harm] Hibernate
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] Hibernate
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
]]

end

-- TODO:
-- Hunter: Trap, fear beast
-- Warlock: Banish, fear
-- Druid: Hibernate, cyclone
-- Paladin: Turn undead
