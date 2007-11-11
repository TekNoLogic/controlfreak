-- Size: 630 305
-- Offset: 190 -103

if not ControlFreak then return end


local ww = LibStub("WidgetWarlock-Alpha1")


function ControlFreak:CreatePanel()
	local frame = CreateFrame("Frame", "ControlFreakFrame", UIParent)
	local name = "ControlFreakFrame"


	local displaygrouplabel = ww:SummonFontString(frame, "OVERLAY", "GameFontHighlightSmall", "Display Options", "TOPLEFT", frame, "TOPLEFT", 20, -5)
	local displaygroup = ww:SummonGroupBox(frame, 305, 75, "TOPLEFT", displaygrouplabel, "BOTTOMLEFT", -15, 0)


	local lockpos = ww:SummonCheckBox(displaygroup, 22, "TOPLEFT", 10, -5)
	ww:EnslaveLabel(lockpos, "Lock frame")
	lockpos:SetHitRectInsets(0, -100, 0, 0)
	ww:EnslaveTooltip(lockpos, "Locks the frame to prevent accidental movement")
	lockpos:SetScript("OnClick", function() self.db.char.frameopts.locked = not self.db.char.frameopts.locked end)
	lockpos:SetChecked(self.db.char.frameopts.locked)


	local showtip = ww:SummonCheckBox(displaygroup, 22, "TOPLEFT", lockpos, "TOPLEFT", 150, 0)
	showtip:SetHitRectInsets(0, -100, 0, 0)
	ww:EnslaveLabel(showtip, "Show tooltip")
	ww:EnslaveTooltip(showtip, "Show help tooltip on hover")
	showtip:SetScript("OnClick", function() self.db.char.showtooltip = not self.db.char.showtooltip end)
	showtip:SetChecked(self.db.char.showtooltip)


	local threshslider, threshslidertext = ww:SummonSlider(frame, "Break Threshold: "..self.db.char.breakthreshold.." sec", 0, 10, "TOPLEFT", lockpos, "BOTTOMLEFT", 5, -15)
	ww:EnslaveTooltip(threshslider, "Time (in seconds) before spell breaks to unfade frame.")
	threshslider:SetValue(self.db.char.breakthreshold)
	threshslider:SetValueStep(1)
	threshslider:SetScript("OnValueChanged", function()
		self.db.char.breakthreshold = threshslider:GetValue()
		threshslidertext:SetText("Break Threshold: "..self.db.char.breakthreshold.." sec")
	end)


	local alpha = math.floor(self.db.char.alpha*100 + .5)
	local alphaslider, alphaslidertext = ww:SummonSlider(frame, "Alpha: "..alpha.."%", "0%", "100%", "LEFT", threshslider, "RIGHT", 15, 0)
	ww:EnslaveTooltip(alphaslider, "Alpha level to fade frame to when focus is controlled, dead, or not set.")
	alphaslider:SetValue(self.db.char.alpha)
	alphaslider:SetValueStep(0.05)
	alphaslider:SetScript("OnValueChanged", function()
		self.db.char.alpha = alphaslider:GetValue()
		local alpha = math.floor(self.db.char.alpha*100 + .5)
		alphaslidertext:SetText("Alpha: "..alpha.."%")
		self:OnUpdate(true)
	end)


	local debufflabel = ww:SummonFontString(frame, "OVERLAY", "GameFontNormalSmall", "Debuff", "TOPLEFT", displaygroup, "BOTTOMLEFT", 5, -10)
	local debuff = ww:SummonEditBox(frame, 200, "LEFT", debufflabel, "RIGHT", 10, 0)
	ww:EnslaveTooltip(debuff, "Debuffs to track for control.  Separate multiple debuffs with commas.")
	debuff:SetScript("OnEditFocusLost", function()
		self.db.profile.spellname = debuff:GetText()
		self:ParseDebuffs(string.split(",", self.db.profile.spellname))
	end)
	debuff:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)


	local editbox = CreateFrame("EditBox", nil, frame)
	editbox:SetWidth(620)
	editbox:SetPoint("BOTTOMLEFT", 5, 5)
	editbox:SetPoint("TOP", frame, "BOTTOM", 0, 170)
	editbox:SetFontObject(GameFontHighlight)
	editbox:SetTextInsets(8,8,8,8)
	editbox:SetBackdrop(ww.TooltipBorderBG)
	editbox:SetBackdropColor(.1,.1,.1,.3)
	editbox:SetMultiLine(true)
	editbox:SetAutoFocus(false)
	editbox:SetScript("OnEditFocusLost", function()
		self.db.profile.macrotext = editbox:GetText()
		self.macroupdated = true
		if not InCombatLockdown() then self:PLAYER_REGEN_ENABLED() end
	end)
	editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	local macrolabel = ww:EnslaveLabel(editbox, "Macro", "BOTTOMLEFT", editbox, "TOPLEFT", 5, 0)
	self.combatwarn = ww:EnslaveLabel(editbox, "|cffff0000Macro changes will not apply until combat ends!", "BOTTOMRIGHT", editbox, "TOPRIGHT", -5, 0)
	if InCombatLockdown() then self.combatwarn:Show() else self.combatwarn:Hide() end


	local checkgrouplabel = ww:SummonFontString(frame, "OVERLAY", "GameFontHighlightSmall", "Creature Types", "TOPLEFT", frame, "TOPLEFT", 330, -5)
	local checkgroup = ww:SummonGroupBox(frame, 305, 102, "TOPLEFT", checkgrouplabel, "BOTTOMLEFT", -15, 0)


	local a1, af, a2, dx, dy = "TOPLEFT", checkgroup, "TOPLEFT", 5, -5
	local checks = {}
	local creaturetypes = {"Beast", "Demon", "Elemental", "Dragonkin", "Giant", "Humanoid", "Mechanical", "Undead", "Unknown"}
	for i,v in ipairs(creaturetypes) do
		local check = ww:SummonCheckBox(checkgroup, 22, a1, af, a2, dx, dy)
		checks[v] = check
		ww:EnslaveLabel(check, v)
		check:SetHitRectInsets(0, -100, 0, 0)
		check:SetScript("OnClick", function() self.db.profile.targtypes[v] = not self.db.profile.targtypes[v] end)

		if i == 5 then a1, af, a2, dx, dy = "TOPLEFT", checks.Beast, "TOPLEFT", 150, 0
		else a1, af, a2, dx, dy = "TOPLEFT", check, "BOTTOMLEFT", 0, 4 end
	end

	frame:SetScript("OnShow", function()
		ww.FadeIn(frame, 0.5)
		debuff:SetText(self.db.profile.spellname)
		editbox:SetText(self.db.profile.macrotext or "/script ChatFrame1:AddMessage(\"Error loading macro!\")")
		for i,v in ipairs(creaturetypes) do checks[v]:SetChecked(self.db.profile.targtypes[v]) end
	end)

	return frame
end

