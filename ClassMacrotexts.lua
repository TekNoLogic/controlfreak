


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
CONTROLFREAKTARGETTYPES = {Beast = true, Humanoid = true}
CONTROLFREAKSPELL = "Polymorph"
--~ /cast [target=focus,exists,nodead,harm] Polymorph
CONTROLFREAKMACROTEXT = [[
/cast [target=focus,exists,nodead,harm] Polymorph
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] Polymorph
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
]]

end

-- TODO:
-- Mage: Poly (3 flavors)
-- Hunter: Trap, fear beast
-- Warlock: Banish, fear
-- Druid: Hibernate, cyclone
-- Paladin: Turn undead
