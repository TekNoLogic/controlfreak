

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


-----------------------
--      Russian      --
-----------------------

if loc == "ruRU" then localized = {
	Beast = "\208\150\208\184\208\178\208\190\209\130\208\189\208\190\208\181",
	Demon = "\208\148\208\181\208\188\208\190\208\189",
	Elemental = "\208\173\208\187\208\181\208\188\208\181\208\189\209\130\208\176\208\187\209\140",
	Dragonkin = "\208\148\209\128\208\176\208\186\208\190\208\189",
	Giant = "\208\147\208\184\208\179\208\176\208\189\209\130",
	Humanoid = "\208\147\209\131\208\188\208\176\208\189\208\190\208\184\208\180",
	Mechanical = "\208\156\208\181\209\133\208\176\208\189\208\184\208\183\208\188",
	Undead = "\208\157\208\181\208\182\208\184\209\130\209\140",
	Unknown = "\208\157\208\181 \209\131\208\186\208\176\208\183\208\176\208\189\208\190",
} end


-- Metatable majicks... makes localized table fallback to engrish, or fallback to the index requested.
-- This ensures we ALWAYS get a value back, even if it's the index we requested originally
CONTROLFREAK_LOCALE = localized and setmetatable(localized, {__index = function(t,i) return engrish[i] or i end})
	or setmetatable(engrish, {__index = function(t,i) return i end})
