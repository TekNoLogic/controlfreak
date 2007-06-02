-- Size: 630 305
-- Offset: 190 -103

if not ControlFreak then return end


local DongleFrames = DongleStub("DongleFrames-1.0")
local ControlFreak, tiptexts = ControlFreak


local bg = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}


local function HideTooltip()
	GameTooltip:Hide()
end


local function ShowTooltip(self)
 	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(tiptexts[self])
end


tiptexts = setmetatable({}, {
	__newindex = function(t,i,v)
		i:SetScript("OnEnter", ShowTooltip)
		i:SetScript("OnLeave", HideTooltip)
		rawset(t,i,v)
	end,
})


local function AddLabel(frame, text, a1, aframe, a2, dx, dy)
	if not a1 then a1, aframe, a2, dx, dy = "LEFT", frame, "RIGHT", 5, 0 end
	local textframe = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	textframe:SetPoint(a1, aframe, a2, dx, dy)
	textframe:SetText(text)
	return textframe
end


function ControlFreak:CreatePanel()
--~ 	local self = ControlFreak
	local name = "ControlFreakOptions"
	local parent = "" --"#p=OptionsHouseFrame"

	local f = getglobal(name)
	if f then return f:Show() end

	local frame = DongleFrames:Create("t=Frame#n="..name..parent.."#size=630,305#toplevel", "TOPLEFT", 190, -103)

	if parent == "" then
		frame:SetBackdrop(bg)
		frame:SetBackdropColor(.1,.1,.1,.75)
		table.insert(UISpecialFrames, name)
	end

	frame:SetScript("OnShow", function()
		if InCombatLockdown() then self.combatwarn:Show()
		else
			self.combatwarn:Hide()
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
		end
	end)
	frame:SetScript("OnHide", function() self:UnregisterEvent("PLAYER_REGEN_DISABLED") end)


	local lockpos = DongleFrames:Create("t=CheckButton#n="..name.."Lock#p="..name.."#size=22,22#inh=OptionsCheckButtonTemplate#toplevel", "TOPLEFT", 15, -10)
	lockpos:SetScript("OnClick", function() self.db.profile.locked = not self.db.profile.locked end)
	lockpos:SetChecked(self.db.profile.locked)
	AddLabel(lockpos, "Lock frame")
	tiptexts[lockpos] = "Locks the frame to prevent accidental movement"


	local editbox = DongleFrames:Create("t=EditBox#n="..name.."Edit#p="..name.."#w=620#toplevel", "BOTTOMLEFT", 5, 5)
	editbox:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, 205)
	editbox:SetFontObject(GameFontHighlight)
	editbox:SetTextInsets(8,8,8,8)
	editbox:SetBackdrop(bg)
	editbox:SetBackdropColor(.1,.1,.1,.3)
	editbox:SetMultiLine(true)
	editbox:SetAutoFocus(false)
	editbox:SetText(self.db.profile.macrotext or "/script ChatFrame1:AddMessage(\"Error loading macro!\")")
	editbox:SetScript("OnTextChanged", function()
		self.db.profile.macrotext = editbox:GetText()
		self.macroupdated = true
		if not InCombatLockdown() then self:PLAYER_REGEN_ENABLED() end
	end)
	editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	local macrolabel = AddLabel(editbox, "Macro", "BOTTOMLEFT", editbox, "TOPLEFT", 5, 0)
	self.combatwarn = AddLabel(editbox, "|cffff0000Macro changes will not apply until combat ends!", "BOTTOMRIGHT", editbox, "TOPRIGHT", -5, 0)


	local threshslider = DongleFrames:Create("t=Slider#n="..name.."Threshold#p="..name.."#toplevel#inh=OptionsSliderTemplate", "TOPLEFT", lockpos, "BOTTOMLEFT", -5, -15)
	threshslider:SetMinMaxValues(0, 10)
	threshslider:SetValue(self.db.profile.breakthreshold)
	threshslider:SetValueStep(1)
	getglobal(name.."ThresholdLow"):SetText(0)
	getglobal(name.."ThresholdHigh"):SetText(10)
	getglobal(name.."ThresholdText"):SetText("Break Threshold")
	tiptexts[threshslider] = "Time (in seconds) before spell breaks to unfade frame."
	threshslider:SetScript("OnValueChanged", function() self.db.profile.breakthreshold = threshslider:GetValue() end)


	local alphaslider = DongleFrames:Create("t=Slider#n="..name.."Alpha#p="..name.."#toplevel#inh=OptionsSliderTemplate", "LEFT", threshslider, "RIGHT", 10, 0)
	alphaslider:SetMinMaxValues(0, 1)
	alphaslider:SetValue(self.db.profile.alpha)
	alphaslider:SetValueStep(0.05)
	getglobal(name.."AlphaLow"):SetText("0%")
	getglobal(name.."AlphaHigh"):SetText("100%")
	getglobal(name.."AlphaText"):SetText("Alpha")
	tiptexts[alphaslider] = "Alpha level to fade frame to when focus is controlled, dead, or not set."
	alphaslider:SetScript("OnValueChanged", function()
		self.db.profile.alpha = alphaslider:GetValue()
		self:OnUpdate(true)
	end)


	local resetmacro = DongleFrames:Create("t=Button#n="..name.."ResetMacro#p="..name.."#size=120,22#toplevel#inh=UIPanelButtonGrayTemplate#text=Reset Defaults", "TOPRIGHT", frame, "TOPRIGHT", -5, -5)
	resetmacro:SetScript("OnClick", function()
		local x, y, anch = self:GetPosition()
		self.db:ResetProfile()
		self:RestorePosition(x, y, anch)
		self.db.profile.x, self.db.profile.y, self.db.profile.anchor = x, y, anch

		editbox:SetText(self.db.profile.macrotext or "/script ChatFrame1:AddMessage(\"Error loading macro!\")")
		alphaslider:SetValue(self.db.profile.alpha)
		threshslider:SetValue(self.db.profile.breakthreshold)
		lockpos:SetChecked(self.db.profile.locked)

		self.macroupdated = true
		if not InCombatLockdown() then self:PLAYER_REGEN_ENABLED()
		else self:RegisterEvent("PLAYER_REGEN_ENABLED") end
		self:OnUpdate(true)
	end)
end
