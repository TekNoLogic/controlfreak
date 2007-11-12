
string.concat = strconcat


------------------------------
--      Are you local?      --
------------------------------

local lego, lasthp, lasthptime, focusisenemy, focusdead, focusexists, targetisenemy, targetdead, targetexists, text, frame, updateframe, updating
local maxdebuffs, damageinterval, mydebuffs, isvalid, controlled, colors, defaultprofiles, presetprofiles = 40, 3, {}, {}, {}, {
	default = {1.0, 0.8, 0.0, t = ""},
	red     = {1.0, 0.0, 0.0, t = "|cffff0000"},
	orange  = {1.0, 0.4, 0.0, t = "|cffff6600"},
	green   = {0.0, 1.0, 0.0, t = "|cff00ff00"},
	cyan    = {0.0, 0.8, 1.0, t = "|cff00ccff"},
	grey    = {0.8, 0.8, 0.8, t = "|cff808080"},
}, {
	Druid   = "Druid - Hibernate",
	Mage    = "Mage - Polymorph",
	Priest  = "Priest - Shackle Undead",
	Warlock = "Warlock - Banish",
	Paladin = "Paladin - Turn Undead",
	Hunter  = "Hunter - Freezing Trap",
	Rogue   = "Rogue - Sap",
}, {
	["Druid - Hibernate"] = true,
	["Mage - Polymorph"] = true,
	["Mage - Random Polymorph"] = true,
	["Priest - Shackle Undead"] = true,
	["Warlock - Banish"] = true,
	["Paladin - Turn Undead"] = true,
	["Hunter - Freezing Trap"] = true,
	["Rogue - Sap"] = true,
}


----------------------------
--      Localization      --
----------------------------

local L = {
	["Click to set focus\n"] = "Click to set focus\n",
	["Click to cast on focus\n"] = "Click to cast on focus\n",
	["Click to cast on target\n"] = "Click to cast on target\n",
	["Click to clear focus\n"] = "Click to clear focus\n",
	["Shift-click to clear focus\n"] = "Shift-click to clear focus\n",
	["Type /freak or right-click to open config"] = "Type /freak or right-click to open config",
}


-------------------------
--      Namespace      --
-------------------------

local OptionHouse = LibStub("OptionHouse-1.1")
ControlFreak = DongleStub("Dongle-1.0"):New("ControlFreak")
if tekDebug then ControlFreak:EnableDebug(1, tekDebug:GetFrame("ControlFreak")) end


---------------------------
--      Init/Enable      --
---------------------------

function ControlFreak:Initialize()
	self.db = self:InitializeDB("ControlFreakDB", {
		char = {
			breakthreshold = 5,
			alpha = 0.5,
			showtooltip = true,
			frameopts = {locked = false}
		},
		profile = {
			spellname = "",
			macrotext = "/freak",
			targtypes = {},
		},
	}, defaultprofiles[UnitClass("player")])
	self:LoadDefaultMacros()

	local _, title = GetAddOnInfo("ControlFreak")
	local author, version = GetAddOnMetadata("ControlFreak", "Author"), GetAddOnMetadata("ControlFreak", "Version")
	local oh = OptionHouse:RegisterAddOn("Control Freak", title, author, version)
	oh:RegisterCategory("Options", ControlFreak, "CreatePanel")
	oh:RegisterCategory("Profiles", ControlFreak, "CreateProfilePanel")

	local slasher = self:InitializeSlashCommand("Control Freak config", "CONTROLFREAK", "freak")
	slasher:RegisterSlashHandler("Open config", "^$", function() OptionHouse:Open("Control Freak", "Options") end)

	-- Frame for OnUpdates
	updateframe = CreateFrame("Frame")
	updateframe:SetScript("OnUpdate", self.OnUpdate)
	updateframe:Hide()

	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UNIT_AURA")
end


function ControlFreak:Enable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")

	self:RegisterMessage("DONGLE_PROFILE_CHANGED", "ProfileLoaded")
	self:RegisterMessage("DONGLE_PROFILE_COPIED", "ProfileLoaded")
	self:RegisterMessage("DONGLE_PROFILE_DELETED", "ProfileDeleted")

	lego = ControlFreakFrame
	lego:SetText("Controlled (000s)")
	lego:Resize()
	lego:SetDB(self.db.char.frameopts)

	lego:SetTooltip(L["Click to set focus\n"]..L["Type /freak or right-click to open config"])
	lego:SetText("Control Freak")
	lego:SetAttribute("type", "macro")
	lego:SetAttribute("macrotext", self.db.profile.macrotext)

	self:ParseDebuffs(string.split(",", self.db.profile.spellname))

	self:OnUpdate(true)
end


------------------------
--      Profiles      --
------------------------

function ControlFreak:ProfileLoaded(msg, db, parent)
	if parent ~= self then return end

	self.macroupdated = true
	if not InCombatLockdown() then self:PLAYER_REGEN_ENABLED() end

	self:ParseDebuffs(string.split(",", self.db.profile.spellname))
end


function ControlFreak:ProfileDeleted(msg, db, parent, sv, profile)
	if parent ~= self or not presetprofiles[profile] then return end

	self:UnregisterMessage("DONGLE_PROFILE_CHANGED")
	self:UnregisterMessage("DONGLE_PROFILE_COPIED")

	self:LoadDefaultMacros()

	self:RegisterMessage("DONGLE_PROFILE_CHANGED", "ProfileLoaded")
	self:RegisterMessage("DONGLE_PROFILE_COPIED", "ProfileLoaded")
end


function ControlFreak:ParseDebuffs(...)
	for i in pairs(mydebuffs) do mydebuffs[i] = nil end
	for i=1,select("#", ...) do
		local v = string.trim((select(i, ...)))
		mydebuffs[v] = true
		self:DebugF(1, "Add debuff %q", v)
	end
end


------------------------------
--      Event Handlers      --
------------------------------

function ControlFreak:PLAYER_REGEN_DISABLED()
	if self.combatwarn then self.combatwarn:Show() end
end


function ControlFreak:PLAYER_REGEN_ENABLED()
	if self.macroupdated then lego:SetAttribute("macrotext", self.db.profile.macrotext) end
	self.macroupdated = nil
	if self.combatwarn then self.combatwarn:Hide() end
end


function ControlFreak:PLAYER_TARGET_CHANGED()
	targetexists = UnitExists("target")
	targetisenemy = targetexists and UnitIsEnemy("player", "target")
	targetdead = targetexists and UnitIsDead("target")
	isvalid.target = self.db.profile.targtypes[UnitCreatureType("target")]

	if (not focusexists and not targetexists)
		or focusdead and not targetexists
		or targetdead and not focusexists
		or focusdead and targetdead then
			self:StopTimer()
	elseif not updating then self:StartTimer() end
end


function ControlFreak:PLAYER_FOCUS_CHANGED()
	focusexists = UnitExists("focus")
	self:Debug(1, "PLAYER_FOCUS_CHANGED", focusexists)
	focusisenemy = focusexists and UnitIsEnemy("player", "focus")
	focusdead = focusexists and UnitIsDead("focus")
	isvalid.focus = self.db.profile.targtypes[UnitCreatureType("focus")]

	lasthp, lasthptime = focusexists and UnitHealth("focus"), 0

	if focusexists then self:UNIT_AURA("UNIT_AURA", "focus")
	else
		controlled.focus = nil
		self:OnUpdate(true)
	end

	if (not focusexists and not targetexists)
		or focusdead and not targetexists
		or targetdead and not focusexists
		or focusdead and targetdead then
			self:StopTimer()
	elseif not updating then self:StartTimer() end
end


function ControlFreak:UNIT_AURA(event, unit)
 	if unit ~= "focus" then return end

	self:Debug(1, "UNIT_AURA", controlled[unit])
	local wascontrolled = (controlled[unit] ~= nil)
	controlled[unit] = nil
	for i=1,maxdebuffs do
		self:Debug(1, i, UnitDebuff(unit, i))
		if mydebuffs[UnitDebuff(unit, i)] then controlled[unit] = i end
	end

	if wascontrolled ~= (controlled[unit]~= nil) then
		if not controlled[unit] then PlaySoundFile("Interface\\AddOns\\ControlFreak\\break.wav") end
		self:OnUpdate(true)
	end
end


------------------------------
--      Status Updater      --
------------------------------

function ControlFreak:StartTimer()
	updateframe:Show()
	updating = true
	self:OnUpdate(true)
end


function ControlFreak:StopTimer()
	updateframe:Hide()
	updating = false
	self:OnUpdate(true)
end


function ControlFreak:OnUpdate(elapsed)
	local self = ControlFreak
	self.elapsed = self.elapsed or 0

	if type(elapsed) == "number" then self.elapsed = self.elapsed + elapsed end
	if self.elapsed >= 0.25 or elapsed == true then self.elapsed = 0
	else return end

	local wasfocusdead = focusdead
	focusdead = focusexists and UnitIsDead("focus")

	local hp = focusexists and UnitHealth("focus")
	if hp and hp ~= lasthp then lasthp, lasthptime = hp, GetTime() end

	local alpha, color, note, range, unittag = self.db.char.alpha, "default", "Control Freak", "", ""
	local unit
	if focusisenemy and not focusdead then unit = "focus" end
	if unit then
		if not isvalid[unit] then color, note, tiptext = "grey", "Invalid"
		else
			if mydebuffs[1] and IsSpellInRange(mydebuffs[1], unit) == 0 then range = "*" end
			if controlled[unit] then
				local _, _, _, _, _, _, timeLeft = UnitDebuff(unit, controlled[unit])
				color, note = "cyan", timeLeft and string.format("Controlled (%ds)", timeLeft) or "Controlled"
				if timeLeft and timeLeft <= self.db.char.breakthreshold then alpha = 1.0 end
			elseif lasthptime and lasthptime >= (GetTime()-damageinterval) then alpha, color, note = 1.0, "red", "Damage"
			elseif UnitAffectingCombat(unit) then alpha, color, note = 1.0, "orange", "Loose"
			else alpha, color, note = 1.0, "green", "Ready" end
		end

	elseif focusisenemy and focusdead then color, note = "grey", "Dead"
	-- focus type
	-- target dead
	-- target type
	end

	local setfocus = not InCombatLockdown() and not focusexists
	local castfocus = focusisenemy and not focusdead
	local casttarget = InCombatLockdown() and (not focusexists or focusdead) and targetexists
	local clearfocus1 = focusexists and focusdead and not (InCombatLockdown() and targetexists and not targetdead)
	local clearfocus2 = focusexists and not focusdead
	lego:SetTooltip((setfocus and L["Click to set focus\n"] or "")..
		(castfocus and L["Click to cast on focus\n"] or "").. (casttarget and L["Click to cast on target\n"] or "")..
		(clearfocus1 and L["Click to clear focus\n"] or "").. (clearfocus2 and L["Shift-click to clear focus\n"] or "")..
		L["Type /freak or right-click to open config"])

	lego:SetAlpha(alpha)
	lego:SetBackdropBorderColor(unpack(colors[color]))
	lego:SetText(string.concat(colors[color].t, range, note, range))

	if focusdead and not wasfocusdead then self:PLAYER_FOCUS_CHANGED() end
end


