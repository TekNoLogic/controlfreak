

-- TODO:
-- Hunter: fear beast
-- Warlock: fear

function ControlFreak:GenerateMacro(class, spellname, targets, effectname)
	self.db:SetProfile(class.. " - " ..spellname)
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/cast [target=focus,exists,nodead,harm] ]].. spellname.. [[
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] ]].. spellname.. [[
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = effectname or spellname
		self.db.profile.targtypes = targets
	end
end

function ControlFreak:LoadDefaultMacros()
	local profile = self.db:GetCurrentProfile()

	self:GenerateMacro("Druid",   "Hibernate",      {Beast = true, Dragonkin = true})
	self:GenerateMacro("Mage",    "Polymorph",      {Beast = true, Humanoid = true})
	self:GenerateMacro("Priest",  "Shackle Undead", {Undead = true})
	self:GenerateMacro("Warlock", "Banish",         {Demon = true, Elemental = true})
	self:GenerateMacro("Paladin", "Turn Evil",      {Undead = true, Demon = true})
	self:GenerateMacro("Paladin", "Repentance",     {Undead = true, Demon = true, Dragonkin = true, Humanoid = true, Giant = true})
	self:GenerateMacro("Hunter",  "Freezing Trap",  {Beast = true, Humanoid = true, Undead = true, Demon = true, Elemental = true, Dragonkin = true}, "Freezing Trap Effect")
	self:GenerateMacro("Rogue",   "Sap",            {Humanoid = true})
	self:GenerateMacro("Shaman",  "Bind Elemental", {Elemental = true})
	self:GenerateMacro("Shaman",  "Hex",            {Beast = true, Humanoid = true})

	-- Mage - Random Sheep/Pig --
	self.db:SetProfile("Mage - Random Sheep/Pig")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/castrandom [target=focus,exists,nodead,harm] Polymorph, Polymorph(Rank 1: Pig)
/stopmacro [target=focus,exists,nodead,harm]
/castrandom [combat,harm,exists,nodead] Polymorph, Polymorph(Rank 1: Pig)
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Polymorph"
		self.db.profile.targtypes = {Beast = true, Humanoid = true}
	end

	-- Mage - Random Sheep/Pig/Turtle --
	self.db:SetProfile("Mage - Random Sheep/Pig/Turtle")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/castrandom [target=focus,exists,nodead,harm] Polymorph, Polymorph(Rank 1: Pig), Polymorph(Rank 1: Turtle)
/stopmacro [target=focus,exists,nodead,harm]
/castrandom [combat,harm,exists,nodead] Polymorph, Polymorph(Rank 1: Pig), Polymorph(Rank 1: Turtle)
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Polymorph"
		self.db.profile.targtypes = {Beast = true, Humanoid = true}
	end

	-- Warlock - Seduction --
	self.db:SetProfile("Warlock - Seduction")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/petstay
/petfollow
/cast [pet:succubus,target=focus,exists,harm] Seduction
/stopmacro [target=focus,exists,nodead,harm]
/cast [pet:succubus, combat,harm,exists,nodead] Seduction
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Seduction"
		self.db.profile.targtypes = {Humanoid = true}
	end

	self.db:SetProfile(profile)
end


