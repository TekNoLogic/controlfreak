-- Size: 630 305
-- Offset: 190 -103

if not ControlFreak then return end


local DongleFrames = DongleStub("DongleFrames-1.0")
local ww = WidgetWarlock
WidgetWarlock = nil
local ControlFreak = ControlFreak


function ControlFreak:CreatePanel()
	local frame = CreateFrame("Frame", "ControlFreakFrame", UIParent)
	local name = "ControlFreakFrame"


	frame:SetScript("OnShow", function()
		if InCombatLockdown() then self.combatwarn:Show()
		else
			self.combatwarn:Hide()
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
		end
	end)
	frame:SetScript("OnHide", function() self:UnregisterEvent("PLAYER_REGEN_DISABLED") end)


	local lockpos, lockposlabel = ww.SummonLabeledCheckBox("Lock frame", 22, frame, "TOPLEFT", 15, -10)
	ww.EnslaveTooltip(lockpos, "Locks the frame to prevent accidental movement")
	lockpos:SetScript("OnClick", function() self.db.profile.frameopts.locked = not self.db.profile.frameopts.locked end)
	lockpos:SetChecked(self.db.profile.frameopts.locked)


	local showtip = ww.SummonLabeledCheckBox("Show tooltip", 22, frame, "TOPLEFT", lockpos, "TOPLEFT", 133, 0)
	ww.EnslaveTooltip(showtip, "Show help tooltip on hover")
	showtip:SetScript("OnClick", function() self.db.profile.showtooltip = not self.db.profile.showtooltip end)
	showtip:SetChecked(self.db.profile.showtooltip)


	local editbox = CreateFrame("EditBox", nil, frame)
	editbox:SetWidth(620) editbox:SetHeight(200)
	editbox:SetPoint("BOTTOMLEFT", 5, 5)
	editbox:SetFontObject(GameFontHighlight)
	editbox:SetTextInsets(8,8,8,8)
	editbox:SetBackdrop(ww.TooltipBorderBG)
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
	local macrolabel = ww.EnslaveLabel(editbox, "Macro", "BOTTOMLEFT", editbox, "TOPLEFT", 5, 0)
	self.combatwarn = ww.EnslaveLabel(editbox, "|cffff0000Macro changes will not apply until combat ends!", "BOTTOMRIGHT", editbox, "TOPRIGHT", -5, 0)

	local debuff = CreateFrame("EditBox", nil, frame)
	debuff:SetPoint("BOTTOMRIGHT", editbox, "TOPRIGHT", 0, 15) debuff:SetWidth(200) debuff:SetHeight(22)
	debuff:SetFontObject(GameFontHighlight)
	debuff:SetTextInsets(8,8,8,8)
	debuff:SetBackdrop(ww.TooltipBorderBG)
	debuff:SetBackdropColor(.1,.1,.1,.3)
	debuff:SetAutoFocus(false)
	debuff:SetText(self.db.profile.spellname)
	debuff:SetScript("OnTextChanged", function() self.db.profile.spellname = debuff:GetText() end)
	debuff:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	ww.EnslaveLabel(debuff, "Debuff", "RIGHT", debuff, "LEFT", -5, 0)


	local threshslider, threshslidertext = ww.SummonSlider(frame, "Break Threshold: "..self.db.profile.breakthreshold.." sec", 0, 10, "TOPLEFT", lockpos, "BOTTOMLEFT", -5, -15)
	ww.EnslaveTooltip(threshslider, "Time (in seconds) before spell breaks to unfade frame.")
	threshslider:SetValue(self.db.profile.breakthreshold)
	threshslider:SetValueStep(1)
	threshslider:SetScript("OnValueChanged", function()
		self.db.profile.breakthreshold = threshslider:GetValue()
		threshslidertext:SetText("Break Threshold: "..self.db.profile.breakthreshold.." sec")
	end)


	local alpha = math.floor(self.db.profile.alpha*100 + .5)
	local alphaslider, alphaslidertext = ww.SummonSlider(frame, "Alpha: "..alpha.."%", "0%", "100%", "LEFT", threshslider, "RIGHT", 10, 0)
	ww.EnslaveTooltip(alphaslider, "Alpha level to fade frame to when focus is controlled, dead, or not set.")
	alphaslider:SetValue(self.db.profile.alpha)
	alphaslider:SetValueStep(0.05)
	alphaslider:SetScript("OnValueChanged", function()
		self.db.profile.alpha = alphaslider:GetValue()
		local alpha = math.floor(self.db.profile.alpha*100 + .5)
		alphaslidertext:SetText("Alpha: "..alpha.."%")
		self:OnUpdate(true)
	end)


	local resetmacro = CreateFrame("Button", name.."ResetMacro", frame, "UIPanelButtonGrayTemplate")
	resetmacro:SetPoint("TOPRIGHT", -5, -5) resetmacro:SetWidth(120) resetmacro:SetHeight(22)
	resetmacro:SetText("Reset Defaults")
	resetmacro:SetScript("OnClick", function()
		local x, y, anch = self:GetPosition()
		self.db:ResetProfile()
		self:RestorePosition(x, y, anch)
		self.db.profile.x, self.db.profile.y, self.db.profile.anchor = x, y, anch

		editbox:SetText(self.db.profile.macrotext or "/script ChatFrame1:AddMessage(\"Error loading macro!\")")
		alphaslider:SetValue(self.db.profile.alpha)
		threshslider:SetValue(self.db.profile.breakthreshold)
		lockpos:SetChecked(self.db.profile.frameopts.locked)

		self.macroupdated = true
		if not InCombatLockdown() then self:PLAYER_REGEN_ENABLED()
		else self:RegisterEvent("PLAYER_REGEN_ENABLED") end
		self:OnUpdate(true)
	end)

	return frame
end

