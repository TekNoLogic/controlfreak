

-- TODO:
-- Hunter: fear beast
-- Warlock: fear

local function tableincludes(t, v)
	for i,val in pairs(t) do if val == v then return true end
end


function ControlFreak:LoadDefaultMacros()
	local profile = self.db:GetCurrentProfile()
	local profiles = self.db:GetProfiles()

	-- Druid - Hibernate --
	if not tableincludes(profiles, "Druid - Hibernate") then
		self.db:SetProfile("Druid - Hibernate")
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
	if not tableincludes(profiles, "Mage - Polymorph") then
		self.db:SetProfile("Mage - Polymorph")
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

	-- Mage - Random Polymorph --
	if not tableincludes(profiles, "Mage - Random Polymorph") then
		self.db:SetProfile("Mage - Random Polymorph")
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
	if not tableincludes(profiles, "Priest - Shackle Undead") then
		self.db:SetProfile("Priest - Shackle Undead")
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
	if not tableincludes(profiles, "Warlock - Banish") then
		self.db:SetProfile("Warlock - Banish")
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
	if not tableincludes(profiles, "Paladin - Turn Undead") then
		self.db:SetProfile("Paladin - Turn Undead")
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
	if not tableincludes(profiles, "Hunter - Freezing Trap") then
		self.db:SetProfile("Hunter - Freezing Trap")
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
	if not tableincludes(profiles, "Rogue - Sap") then
		self.db:SetProfile("Rogue - Sap")
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

	if profile ~= self.db:GetCurrentProfile() then self.db:SetProfile(profile) end
end


