
string.concat = strconcat

local macrotext, spellname, targtypes = CONTROLFREAKMACROTEXT, CONTROLFREAKSPELL, CONTROLFREAKTARGETTYPES
CONTROLFREAKMACROTEXT, CONTROLFREAKTARGETTYPES, CONTROLFREAKSPELL = nil, nil, nil
if not macrotext then return end


local TIMETHRESHOLD = 5
local lasthp, lasthptime, focusisenemy, focusdead, focusexists, targetisenemy, targetdead, targetexists, text, frame, updateframe, updating
local maxdebuffs, damageinterval, isvalid, controlled, colors = 40, 3, {}, {}, {
	default = {1.0, 0.8, 0.0, t = ""},
	red     = {1.0, 0.0, 0.0, t = "|cffff0000"},
	orange  = {1.0, 0.4, 0.0, t = "|cffff6600"},
	green   = {0.0, 1.0, 0.0, t = "|cff00ff00"},
	cyan    = {0.0, 0.8, 1.0, t = "|cff00ccff"},
	grey    = {0.8, 0.8, 0.8, t = "|cff808080"},
}


ControlFreak = DongleStub("Dongle-1.0"):New("ControlFreak")
local LegoBlock = DongleStub("LegoBlock-Beta0-1.0")


function ControlFreak:Initialize()
	-- Create our frame --
	frame = LegoBlock:GetLego("ControlFreak", "Controlled (000s)")
	frame.noresize = true
	frame:SetText("Control Freak")
	frame:SetManyAttributes("type", "macro", "macrotext", macrotext)
	frame:SetScript("OnDragStart", self.OnDragStart)
	frame:SetScript("OnDragStop", self.OnDragStop)

	-- Frame for OnUpdates
	updateframe = CreateFrame("Frame")
	updateframe:SetScript("OnUpdate", self.OnUpdate)
	updateframe:Hide()

	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("UNIT_AURA")

	self:OnUpdate(true)
end


function ControlFreak:OnDragStart(button)
	self:StartMoving()
	self.isMoving = true
end


function ControlFreak:OnDragStop()
	if not self.isMoving then return end
	self:StopMovingOrSizing()
	self.isMoving = false
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

	local alpha, color, note, range, unittag = 0.5, "default", "Control Freak", "", ""
	local unit
	if focusisenemy and not focusdead then unit = "focus" end
	if unit then
		if not isvalid[unit] then color, note = "grey", "Invalid"
		else
			if IsSpellInRange(spellname, unit) == 0 then range = "*" end
			if lasthptime and lasthptime >= (GetTime()-damageinterval) then alpha, color, note = 1.0, "red", "Damage"
			elseif controlled[unit] then
				local _, _, _, _, _, _, timeLeft = UnitDebuff(unit, controlled[unit])
				color, note = "cyan", timeLeft and string.format("Controlled (%ds)", timeLeft or 0) or "Controlled"
				if timeLeft and timeLeft <= TIMETHRESHOLD then alpha = 1.0 end
			elseif UnitAffectingCombat(unit) then alpha, color, note = 1.0, "orange", "Loose"
			else alpha, color, note = 1.0, "green", "Ready" end
		end

	elseif focusisenemy and focusdead then color, note = "grey", "Dead"
	-- focus type
	-- target dead
	-- target type
	end

	frame:SetAlpha(alpha)
	frame:SetBackdropBorderColor(unpack(colors[color]))
	frame:SetText(string.concat(colors[color].t, range, note, range))

	if focusdead and not wasfocusdead then self:PLAYER_FOCUS_CHANGED() end
end


