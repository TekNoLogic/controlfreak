

-- Mage: Poly (3 flavors)
-- Hunter: Trap, fear beast
-- Warlock: Banish, fear
-- Priest: Shackle Undead
-- Druid: Hibernate, cyclone
-- Paladin: Turn undead

local macros = {
	priest = [[
/cast [target=focus,exists,nodead,harm] Shackle Undead
/stopmacro [target=focus,exists,nodead,harm]
/cast [combat,harm,exists,nodead] Shackle Undead
/focus [exists,harm,nodead] target
/clearfocus [target=focus,dead]
]],
}

local CF = DongleStub("Dongle-1.0"):New("ControlFreak")
local DongleFrames = DongleStub("DongleFrames-1.0")


local function SetManyAttributes(self, ...)
	for i=1,select("#", ...),2 do
		local att,val = select(i, ...)
		if not att then return end
		self:SetAttribute(att,val)
	end
end


DongleFrames:Create("t=Button#n=ControlFreakFrame#p=UIParent#size=100,32#mouse#drag=LeftButton#movable#clamp#inh=SecureActionButtonTemplate", "CENTER", 0, -200)
ControlFreakFrame.Text = DongleFrames:Create("p=ControlFreakFrame#t=FontString#inh=GameFontNormal#text=Control Freak", "CENTER", 0, 0)
ControlFreakFrame.SetManyAttributes = SetManyAttributes
ControlFreakFrame:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
})
ControlFreakFrame:SetBackdropColor(0,0,0,0.4)
ControlFreakFrame:SetBackdropBorderColor(1,0.8,0,0.8)
ControlFreakFrame:SetScript("OnDragStart", function(self,button)
	if not IsShiftKeyDown() then return end
	self:StartMoving()
	self.isMoving = true
end)
ControlFreakFrame:SetScript("OnDragStop", function(self,button)
	if not self.isMoving then return end
	self:StopMovingOrSizing()
	self.isMoving = false
end)


ControlFreakFrame:SetManyAttributes("type1", "macro", "macrotext", macros.priest)