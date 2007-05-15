

local macrotext, targtype, debuffname = CONTROLFREAKMACROTEXT, CONTROLFREAKTARGETTYPE, CONTROLFREAKDEBUFF
CONTROLFREAKMACROTEXT, CONTROLFREAKTARGETTYPE, CONTROLFREAKDEBUFF = nil, nil, nil
if not macrotext then return end


local focuscontrolled, focusisenemy, focusdead, focusexists, targetisenemy, targetdead, targetexists
local text, frame, updateframe, updating
local damageinterval = 3
local colors = {
	default = {1.0, 0.8, 0.0},
	red     = {1.0, 0.0, 0.0},
	green   = {0.0, 1.0, 0.0},
	blue    = {0.0, 0.0, 1.0},
	grey    = {0.7, 0.7, 0.7},
}

ControlFreak = DongleStub("Dongle-1.0"):New("ControlFreak")
local DongleFrames = DongleStub("DongleFrames-1.0")


function ControlFreak:Initialize()
	-- Create our frame --
	frame = DongleFrames:Create("t=Button#n=ControlFreakFrame#p=UIParent#size=100,32#mouse#drag=LeftButton#movable#clamp#inh=SecureActionButtonTemplate", "CENTER", 0, -200)
	frame.Text = DongleFrames:Create("p=ControlFreakFrame#t=FontString#inh=GameFontNormal#text=Control Freak", "CENTER", 0, 0)
	text = frame.Text
	frame:SetAttribute("type", "macro")
	frame:SetAttribute("macrotext", macrotext)
	frame:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	})
	frame:SetBackdropColor(0,0,0,0.4)
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
	if not IsShiftKeyDown() then return end
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

	if (not focusexists and not targetexists)
		or focusdead and not targetexists
		or targetdead and not focusexists
		or focusdead and targetdead then
			self:StopTimer(self, true)
	elseif not updating then self:StartTimer() end
end


function ControlFreak:UNIT_AURA(event, unit)
 	if unit ~= "focus" then return end

	-- aura ~= debuffname
--~ 	focuscontrolled = gained
--~ 	self:OnUpdate(true)
end


function ControlFreak.OnUpdate(self, elapsed)
	self = ControlFreak
	self.elapsed = self.elapsed or 0

	if type(elapsed) == "number" then self.elapsed = self.elapsed + elapsed end
	if self.elapsed >= 0.25 or elapsed == true then self.elapsed = 0
	else return end

	local wasfocusdead = focusdead
	focusdead = focusexists and UnitIsDead("focus")

	local color, text = "default", "Control Freak"
	if focusisenemy and not focusdead then -- need to check focus's type also
		---- DoT
		if self.damagetime and self.damagetime >= (GetTime()-damageinterval) then color, text = "red", "|cffff0000Damage"
		elseif focuscontrolled then color, text = "blue", "|cff0000ffControlled"
		---- OOC
		else color, text = "green", "|cff00ff00Ready" end

	-- Target, correct type
	---- DoT
	---- Damage
	---- CC
	---- OOC

	elseif focusisenemy and focusdead then color, text = "grey", "|cff808080Dead"
	-- focus type
	-- target dead
	-- target type
	end

	frame:SetBackdropBorderColor((unpack(colors[color])), 0.8)
	text:SetText(text)

	if focusdead and not wasfocusdead then self:PLAYER_FOCUS_CHANGED() end
end


