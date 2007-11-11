

-- TODO:
-- Hunter: fear beast
-- Warlock: fear

function ControlFreak:LoadDefaultMacros()
	local profile = self.db:GetCurrentProfile()

	-- Druid - Hibernate --
	self.db:SetProfile("Druid - Hibernate")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/cast [target=focus,exists,nodead,harm] Hibernate
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] Hibernate
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Hibernate"
		self.db.profile.targtypes = {Beast = true, Dragonkin = true}
	end

	-- Mage - Polymorph --
	self.db:SetProfile("Mage - Polymorph")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/cast [target=focus,exists,nodead,harm] Polymorph
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] Polymorph
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Polymorph, Polymorph: Pig, Polymorph: Turtle"
		self.db.profile.targtypes = {Beast = true, Humanoid = true}
	end

	-- Mage - Random Sheep/Pig --
	self.db:SetProfile("Mage - Random Sheep/Pig")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/castrandom [target=focus,exists,nodead,harm] Polymorph, Polymorph: Pig
/stopmacro [target=focus,exists,nodead,harm]
/castrandom [combat,harm,exists,nodead] Polymorph, Polymorph: Pig
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Polymorph, Polymorph: Pig, Polymorph: Turtle"
		self.db.profile.targtypes = {Beast = true, Humanoid = true}
	end

	-- Mage - Random Sheep/Pig/Turtle --
	self.db:SetProfile("Mage - Random Sheep/Pig/Turtle")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/castrandom [target=focus,exists,nodead,harm] Polymorph, Polymorph: Pig, Polymorph: Turtle
/stopmacro [target=focus,exists,nodead,harm]
/castrandom [combat,harm,exists,nodead] Polymorph, Polymorph: Pig, Polymorph: Turtle
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Polymorph, Polymorph: Pig, Polymorph: Turtle"
		self.db.profile.targtypes = {Beast = true, Humanoid = true}
	end

	-- Priest - Shackle Undead --
	self.db:SetProfile("Priest - Shackle Undead")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/cast [target=focus,exists,nodead,harm] Shackle Undead
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] Shackle Undead
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Shackle Undead"
		self.db.profile.targtypes = {Undead = true}
	end

	-- Warlock - Banish --
	self.db:SetProfile("Warlock - Banish")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/cast [target=focus,exists,nodead,harm] Banish
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] Banish
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Banish"
		self.db.profile.targtypes = {Demon = true, Elemental = true}
	end

	-- Paladin - Turn Undead --
	self.db:SetProfile("Paladin - Turn Undead")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/cast [target=focus,exists,nodead,harm] Turn Undead
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] Turn Undead
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Turn Undead"
		self.db.profile.targtypes = {Undead = true}
	end

	-- Hunter - Freezing Trap --
	self.db:SetProfile("Hunter - Freezing Trap")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/cast [target=focus,exists,nodead,harm] Freezing Trap
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat] Freezing Trap
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Freezing Trap Effect"
		self.db.profile.targtypes = {Beast = true, Humanoid = true, Undead = true, Demon = true, Elemental = true, Dragonkin = true}
	end

	-- Rogue -- Sap --
	self.db:SetProfile("Rogue - Sap")
	if self.db.profile.macrotext == "/freak" then
		self.db.profile.macrotext = [[
/clearfocus [modifier:shift]
/stopmacro [modifier:shift]
/cast [target=focus,exists,nodead,harm,nocombat] Sap
/stopmacro [target=focus,exists,nodead,harm]
/cast [nocombat] Sap
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
/stopmacro [button:1/3/4/5] [combat]
/freak
]]
		self.db.profile.spellname = "Sap"
		self.db.profile.targtypes = {Humanoid = true}
	end

	self.db:SetProfile(profile)
end


