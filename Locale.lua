

----------------------------------------------------------------
--                    BIG BOLD CAPS NOTE!                     --
--        Localizations for macros do not belong here!        --
--      Create localized profiles in ClassMacrotexts.lua      --
----------------------------------------------------------------

local localized
local loc = GetLocale()


-----------------------
--      Engrish      --
-----------------------

local engrish = {}


----------------------
--      German      --
----------------------

if loc == "deDE" then localized = {
	Beast = "Wildtier",
	Demon = "D\195\164mon",
	Elemental = "Elementar",
	Dragonkin = "Drachkin",
	Giant = "Riese",
	Humanoid = "Humanoid",
	Mechanical = "Mechanisch",
	Undead = "Untoter",
	Unknown = "Nicht Spezifiziert",
} end


----------------------
--      French      --
----------------------

if loc == "frFR" then localized = {
	Beast = "B\195\170te",
	Critter = "Bestiole",
	Demon = "D\195\169mon",
	Dragonkin = "Draconien",
	Elemental = "El\195\169mentaire",
	Giant = "G\195\169ant",
	Humanoid = "Humano\195\175de",
	Mechanical = "M\195\169canique",
	Undead = "Mort-vivant",
} end


-- Metatable majicks... makes localized table fallback to engrish, or fallback to the index requested.
-- This ensures we ALWAYS get a value back, even if it's the index we requested originally
CONTROLFREAK_LOCALE = localized and setmetatable(localized, {__index = function(t,i) return engrish[i] or i end})
	or setmetatable(engrish, {__index = function(t,i) return i end})
