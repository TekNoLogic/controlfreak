
string.concat = strconcat

local macro, spellname, targtypes = CONTROLFREAKMACROTEXT, CONTROLFREAKSPELL, CONTROLFREAKTARGETTYPES
CONTROLFREAKMACROTEXT, CONTROLFREAKTARGETTYPES, CONTROLFREAKSPELL = nil, nil, nil
if not macro then return end


local lasthp, lasthptime, focusisenemy, focusdead, focusexists, targetisenemy, targetdead, targetexists, text, frame, updateframe, updating
local maxdebuffs, damageinterval, isvalid, controlled, colors = 40, 3, {}, {}, {
	default = {1.0, 0.8, 0.0, t = ""},
	red     = {1.0, 0.0, 0.0, t = "|cffff0000"},
	orange  = {1.0, 0.4, 0.0, t = "|cffff6600"},
	green   = {0.0, 1.0, 0.0, t = "|cff00ff00"},
	cyan    = {0.0, 0.8, 1.0, t = "|cff00ccff"},
	grey    = {0.8, 0.8, 0.8, t = "|cff808080"},
}
local L = {
	["Click to set focus\n"] = "Click to set focus\n",
	["Click to cast on focus\n"] = "Click to cast on focus\n",
	["Click to cast on target\n"] = "Click to cast on target\n",
	["Click to clear focus\n"] = "Click to clear focus\n",
	["Shift-click to clear focus\n"] = "Shift-click to clear focus\n",
	["Type /freak to open config"] = "Type /freak to open config",
}

local LegoBlock = DongleStub("LegoBlock-Beta0")
ControlFreak = DongleStub("Dongle-1.0"):New("ControlFreak")


function ControlFreak:Initialize()
	self.lego = LegoBlock:New("ControlFreak", "Controlled (000s)", nil, nil, "#p=UIParent#inh=SecureActionButtonTemplate")

	self.db = self:InitializeDB("ControlFreakDB", {profile = {
		macrotext = macro,
		spellname = spellname,
		targtypes = targtypes,
		breakthreshold = 5,
		alpha = 0.5,
		frameopts = {
			width = self.lego.Text:GetStringWidth(),
			locked = false,
			x = 0, y = -200,
			anchor = "CENTER",
			showIcon = false,
			showText = true,
			noresize = true,
			shown = true,
		}
	}})

	self.lego:SetDB(self.db.profile.frameopts)

	local slasher = self:InitializeSlashCommand("Control Freak config", "CONTROLFREAK", "freak")
	slasher:RegisterSlashHandler("Open config", "^$", "CreatePanel")

	self.lego.tooltiptext = L["Click to set focus\n"]..L["Type /freak to open config"]
	self.lego:SetText("Control Freak")
	self.lego:SetManyAttributes("type", "macro", "macrotext", self.db.profile.macrotext)
	self.lego:SetScript("OnEnter", self.OnEnter)
	self.lego:SetScript("OnLeave", self.OnLeave)

	-- Frame for OnUpdates
	updateframe = CreateFrame("Frame")
	updateframe:SetScript("OnUpdate", self.OnUpdate)
	updateframe:Hide()

	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UNIT_AURA")

	self:OnUpdate(true)
end


function ControlFreak:OnEnter()
	local sx, sy, x, y = GetScreenHeight(), GetScreenWidth(), self:GetCenter()
	local x1, y1, y2 = "RIGHT", "TOP", "BOTTOM"
	if x < (sx/2) then x1 = "LEFT" end
	if y < (sy/2) then y1, y2 = y2, y1 end
 	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(y1..x1, self, y2..x1)
	GameTooltip:SetText(self.tooltiptext)
end


function ControlFreak:OnLeave()
	GameTooltip:Hide()
end


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


function ControlFreak:PLAYER_REGEN_DISABLED()
	self.combatwarn:Show()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
end


function ControlFreak:PLAYER_REGEN_ENABLED()
	if self.macroupdated then self.lego:SetAttribute("macrotext", self.db.profile.macrotext) end
	self.macroupdated = nil
	self.combatwarn:Hide()
end


function ControlFreak:PLAYER_TARGET_CHANGED()
	targetexists = UnitExists("target")
	targetisenemy = targetexists and UnitIsEnemy("player", "target")
	targetdead = targetexists and UnitIsDead("target")
	isvalid.target = targtypes[UnitCreatureType("target")]

	if (not focusexists and not targetexists)
		or focusdead and not targetexists
		or targetdead and not focusexists
		or focusdead and targetdead then
			self:StopTimer()
	elseif not updating then self:StartTimer() end
end


function ControlFreak:PLAYER_FOCUS_CHANGED()
	focusexists = UnitExists("focus")
	focusisenemy = focusexists and UnitIsEnemy("player", "focus")
	focusdead = focusexists and UnitIsDead("focus")
	isvalid.focus = targtypes[UnitCreatureType("focus")]

	lasthp, lasthptime = focusexists and UnitHealth("focus"), 0

	if (not focusexists and not targetexists)
		or focusdead and not targetexists
		or targetdead and not focusexists
		or focusdead and targetdead then
			self:StopTimer()
	elseif not updating then self:StartTimer() end
end


function ControlFreak:UNIT_AURA(event, unit)
 	if unit ~= "focus" then return end

	local wascontrolled = (controlled[unit] ~= nil)
	controlled[unit] = nil
	for i=1,maxdebuffs do
		if UnitDebuff(unit, i) == spellname then controlled[unit] = i end
	end

	if wascontrolled ~= (controlled[unit]~= nil) then self:OnUpdate(true) end
end


function ControlFreak:OnUpdate(elapsed)
	self = ControlFreak
	self.elapsed = self.elapsed or 0

	if type(elapsed) == "number" then self.elapsed = self.elapsed + elapsed end
	if self.elapsed >= 0.25 or elapsed == true then self.elapsed = 0
	else return end

	local wasfocusdead = focusdead
	focusdead = focusexists and UnitIsDead("focus")

	local hp = focusexists and UnitHealth("focus")
	if hp and hp ~= lasthp then lasthp, lasthptime = hp, GetTime() end

	local alpha, color, note, range, unittag = self.db.profile.alpha, "default", "Control Freak", "", ""
	local unit
	if focusisenemy and not focusdead then unit = "focus" end
	if unit then
		if not isvalid[unit] then color, note, tiptext = "grey", "Invalid"
		else
			if IsSpellInRange(spellname, unit) == 0 then range = "*" end
			if lasthptime and lasthptime >= (GetTime()-damageinterval) then alpha, color, note = 1.0, "red", "Damage"
			elseif controlled[unit] then
				local _, _, _, _, _, _, timeLeft = UnitDebuff(unit, controlled[unit])
				color, note = "cyan", timeLeft and string.format("Controlled (%ds)", timeLeft or 0) or "Controlled"
				if timeLeft and timeLeft <= self.db.profile.breakthreshold then alpha = 1.0 end
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
	self.lego.tooltiptext = (setfocus and L["Click to set focus\n"] or "")..
		(castfocus and L["Click to cast on focus\n"] or "").. (casttarget and L["Click to cast on target\n"] or "")..
		(clearfocus1 and L["Click to clear focus\n"] or "").. (clearfocus2 and L["Shift-click to clear focus\n"] or "")..
		L["Type /freak to open config"]

	self.lego:SetAlpha(alpha)
	self.lego:SetBackdropBorderColor(unpack(colors[color]))
	self.lego:SetText(string.concat(colors[color].t, range, note, range))

	if focusdead and not wasfocusdead then self:PLAYER_FOCUS_CHANGED() end
end


