
if not ControlFreak then return end


----------------------------
--      Localization      --
----------------------------

local L = CONTROLFREAK_LOCALE
CONTROLFREAK_LOCALE = nil


----------------------
--      Locals      --
----------------------

local ww = LibStub("WidgetWarlock-Alpha1")
local GAP, EDGEGAP = 8, 16


---------------------
--      Panel      --
---------------------

local frame = CreateFrame("Frame")
frame.parent = "Control Freak"
frame.name = "Macro"
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local ControlFreak = ControlFreak
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Macro", "These controls let you customize the macro, creature types it applies to, and the debuffs to watch.")


	local checkgrouplabel = ww:SummonFontString(frame, "OVERLAY", "GameFontHighlightSmall", "Creature Types", "TOPLEFT", subtitle, "BOTTOMLEFT", -2 + EDGEGAP, -GAP)
	local checkgroup = ww:SummonGroupBox(frame, 305, 102, "TOPLEFT", checkgrouplabel, "BOTTOMLEFT", -EDGEGAP, 0)
	checkgroup:SetPoint("RIGHT", frame, "RIGHT", -EDGEGAP, 0)


	local a1, af, a2, dx, dy = "TOPLEFT", checkgroup, "TOPLEFT", 5, -5
	local checks = {}
	local creaturetypes = {L["Beast"], L["Demon"], L["Elemental"], L["Dragonkin"], L["Giant"], L["Humanoid"], L["Mechanical"], L["Undead"], L["Not specified"], L["Unknown"]}
	for i,v in ipairs(creaturetypes) do
		local check = ww:SummonCheckBox(checkgroup, 22, a1, af, a2, dx, dy)
		checks[v] = check
		ww:EnslaveLabel(check, v)
		check:SetHitRectInsets(0, -100, 0, 0)
		check:SetScript("OnClick", function() ControlFreak.db.profile.targtypes[v] = not ControlFreak.db.profile.targtypes[v] end)

		if i == 5 then a1, af, a2, dx, dy = "TOPLEFT", checkgroup, "TOP", 5, -5
		else a1, af, a2, dx, dy = "TOPLEFT", check, "BOTTOMLEFT", 0, 4 end
	end


	local debufflabel = ww:SummonFontString(frame, "OVERLAY", "GameFontNormalSmall", "Debuff", "TOPLEFT", checkgroup, "BOTTOMLEFT", 0, -GAP)
	local debuff = ww:SummonEditBox(frame, 200, "LEFT", debufflabel, "RIGHT", 10, 0)
	debuff:SetPoint("RIGHT", frame, "RIGHT", -EDGEGAP, 0)
	ww:EnslaveTooltip(debuff, "Debuffs to track for control.  Separate multiple debuffs with commas.")
	debuff:SetScript("OnEditFocusLost", function()
		ControlFreak.db.profile.spellname = debuff:GetText()
		ControlFreak:ParseDebuffs(string.split(",", ControlFreak.db.profile.spellname))
	end)
	debuff:SetScript("OnEscapePressed", debuff.ClearFocus)


	local macrolabel = ww:SummonFontString(frame, "OVERLAY", "GameFontNormalSmall", "Macro", "TOPLEFT", debufflabel, "BOTTOMLEFT", 0, -GAP)
--~ 	macrolabel:SetPoint("TOP", debuff, "BOTTOM", 0, -5)
	local editbox = CreateFrame("EditBox", nil, frame)
	editbox:SetPoint("TOP", macrolabel, "BOTTOM", 0, -5)
	editbox:SetPoint("LEFT", EDGEGAP/3, 0)
	editbox:SetPoint("BOTTOMRIGHT", -EDGEGAP/3, EDGEGAP/3)
	editbox:SetFontObject(GameFontHighlight)
	editbox:SetTextInsets(8,8,8,8)
	editbox:SetBackdrop(ww.TooltipBorderBG)
	editbox:SetBackdropColor(.1,.1,.1,.3)
	editbox:SetMultiLine(true)
	editbox:SetAutoFocus(false)
	editbox:SetScript("OnEditFocusLost", function()
		ControlFreak.db.profile.macrotext = editbox:GetText()
		ControlFreak.macroupdated = true
		if not InCombatLockdown() then ControlFreak:PLAYER_REGEN_ENABLED() end
	end)
	editbox:SetScript("OnEscapePressed", editbox.ClearFocus)
	ControlFreak.combatwarn = ww:EnslaveLabel(editbox, "|cffff0000Macro changes will not apply until combat ends!", "BOTTOMRIGHT", editbox, "TOPRIGHT", -5, 0)
	if InCombatLockdown() then ControlFreak.combatwarn:Show() else ControlFreak.combatwarn:Hide() end


	local function OnShow(frame)
		ww.FadeIn(frame, 0.5)
		debuff:SetText(ControlFreak.db.profile.spellname)
		editbox:SetText(ControlFreak.db.profile.macrotext or "/script ChatFrame1:AddMessage(\"Error loading macro!\")")
		for i,v in ipairs(creaturetypes) do checks[v]:SetChecked(ControlFreak.db.profile.targtypes[v]) end
	end
	frame:SetScript("OnShow", OnShow)
	OnShow(frame)
end)

InterfaceOptions_AddCategory(frame)

