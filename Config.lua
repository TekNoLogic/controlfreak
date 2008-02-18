

if not ControlFreak then return end


----------------------
--      Locals      --
----------------------

local ww = LibStub("WidgetWarlock-Alpha1")
local GAP = 10

---------------------
--      Panel      --
---------------------

local frame = CreateFrame("Frame")
frame.name = "Control Freak"
frame:Hide()
ControlFreak.configframe = frame
frame:SetScript("OnShow", function(frame)
	local ControlFreak = ControlFreak

	local lockpos = ww:SummonCheckBox(frame, 22, "TOPLEFT", GAP, -GAP)
	ww:EnslaveLabel(lockpos, "Lock frame")
	lockpos:SetHitRectInsets(0, -100, 0, 0)
	ww:EnslaveTooltip(lockpos, "Locks the frame to prevent accidental movement")
	lockpos:SetScript("OnClick", function() ControlFreak.db.char.frameopts.locked = not ControlFreak.db.char.frameopts.locked end)
	lockpos:SetChecked(ControlFreak.db.char.frameopts.locked)


	local showtip = ww:SummonCheckBox(frame, 22, "TOPLEFT", lockpos, "BOTTOMLEFT", 0, -GAP)
	showtip:SetHitRectInsets(0, -100, 0, 0)
	ww:EnslaveLabel(showtip, "Show tooltip")
	ww:EnslaveTooltip(showtip, "Show help tooltip on hover")
	showtip:SetScript("OnClick", function() ControlFreak.db.char.showtooltip = not ControlFreak.db.char.showtooltip end)
	showtip:SetChecked(ControlFreak.db.char.showtooltip)


	local threshslider, threshslidertext, threashsliderlow = ww:SummonSlider(frame, "Break Threshold: "..ControlFreak.db.char.breakthreshold.." sec", 0, 10, "TOPLEFT", frame, "TOP", GAP, -GAP-10)
	ww:EnslaveTooltip(threshslider, "Time (in seconds) before spell breaks to unfade frame.")
	threshslider:SetValue(ControlFreak.db.char.breakthreshold)
	threshslider:SetValueStep(1)
	threshslider:SetScript("OnValueChanged", function()
		ControlFreak.db.char.breakthreshold = threshslider:GetValue()
		threshslidertext:SetText("Break Threshold: "..ControlFreak.db.char.breakthreshold.." sec")
	end)


	local alpha = math.floor(ControlFreak.db.char.alpha*100 + .5)
	local alphaslider, alphaslidertext, alphasliderlow = ww:SummonSlider(frame, "Alpha: "..alpha.."%", "0%", "100%", "TOP", threashsliderlow, "BOTTOM", 0, -GAP-10)
	alphaslider:SetPoint("LEFT", threshslider, "LEFT")
	ww:EnslaveTooltip(alphaslider, "Alpha level to fade frame to when focus is controlled, dead, or not set.")
	alphaslider:SetValue(ControlFreak.db.char.alpha)
	alphaslider:SetValueStep(0.05)
	alphaslider:SetScript("OnValueChanged", function()
		ControlFreak.db.char.alpha = alphaslider:GetValue()
		local alpha = math.floor(ControlFreak.db.char.alpha*100 + .5)
		alphaslidertext:SetText("Alpha: "..alpha.."%")
		ControlFreak:OnUpdate(true)
	end)


	--  DB  --
	local currentgroup = ww:SummonGroupBox(frame, nil, 105, "TOP", alphasliderlow, "BOTTOM", 0, -GAP-10)
	currentgroup:SetPoint("LEFT", GAP, 0)
	currentgroup:SetPoint("RIGHT", -GAP, 0)
	local currentlabel = ww:SummonFontString(currentgroup, "OVERLAY", "GameFontNormal", "Current profile:", "TOPLEFT", 10, 15)
	local current = ww:SummonFontString(frame, "OVERLAY", "GameFontHighlight", ControlFreak.db:GetCurrentProfile(), "LEFT", currentlabel, "RIGHT", 10, 0)

	local profiles = ControlFreak.db:GetProfiles()

	local selected = CreateFrame("Frame", "ControlFreakProfileMenu", currentgroup, "UIDropDownMenuTemplate")
	local loadbutton = ww:SummonButton(currentgroup, "Load", nil, nil, "TOPLEFT", selected, "BOTTOMLEFT", 15, -5)
	local copybutton = ww:SummonButton(currentgroup, "Copy", nil, nil, "LEFT", loadbutton, "RIGHT", 10, 0)
	local deletebutton = ww:SummonButton(currentgroup, "Delete", nil, nil, "LEFT", copybutton, "RIGHT", 10, 0)

	selected:SetPoint("TOPLEFT", -5, -10)
	ControlFreakProfileMenuMiddle:SetWidth(250)

	local function ToggleButtons(value)
		if value == ControlFreak.db:GetCurrentProfile() then
			loadbutton:Disable()
			copybutton:Disable()
			deletebutton:Disable()
		else
			loadbutton:Enable()
			copybutton:Enable()
			deletebutton:Enable()
		end
	end

	local function DropdownClick()
		UIDropDownMenu_SetSelectedValue(ControlFreakProfileMenu, this.value)
		ToggleButtons(this.value)
	end

	local ddt = {func = DropdownClick}
	local function DropdownInit()
		local current = ControlFreak.db:GetCurrentProfile()
		for i,v in ipairs(profiles) do
			ddt.checked = false
			ddt.text = v
			ddt.value = v
			ddt.disabled = v == current
			UIDropDownMenu_AddButton(ddt)
		end
	end

	selected:SetScript("OnShow", function(self)
		UIDropDownMenu_Initialize(self, DropdownInit)
		UIDropDownMenu_SetSelectedValue(selected, profiles[1])
		ToggleButtons(profiles[1])
	end)

	loadbutton:SetScript("OnClick", function()
		local profile = UIDropDownMenu_GetSelectedValue(selected)
		ControlFreak.db:SetProfile(profile)
		current:SetText(profile)
		ToggleButtons(profile)
	end)
	copybutton:SetScript("OnClick", function()
		ControlFreak.db:ResetProfile()
		ControlFreak.db:CopyProfile(UIDropDownMenu_GetSelectedValue(selected))
		profiles = ControlFreak.db:GetProfiles()
	end)
	deletebutton:SetScript("OnClick", function()
		ControlFreak.db:DeleteProfile(UIDropDownMenu_GetSelectedValue(selected))
		profiles = ControlFreak.db:GetProfiles()
		UIDropDownMenu_SetSelectedValue(selected, profiles[1])
		ToggleButtons(profiles[1])
	end)

	local createname = ww:SummonEditBox(currentgroup, 187, "TOPLEFT", loadbutton, "BOTTOMLEFT", 8, 1)
	local createbutton = ww:SummonButton(currentgroup, "Create", nil, nil, "LEFT", createname, "RIGHT", 5, -1)
	createbutton:Disable()
	createname:SetScript("OnTextChanged", function(frame) if frame:GetText() ~= "" then createbutton:Enable() else createbutton:Disable() end end)
	createbutton:SetScript("OnClick", function()
		local profile = createname:GetText()
		if profile ~= "" then
			local oldprofile = ControlFreak.db:GetCurrentProfile()
			ControlFreak.db:SetProfile(profile)
			ControlFreak.db:CopyProfile(oldprofile)
			current:SetText(profile)
			profiles = ControlFreak.db:GetProfiles()
			createname:SetText("")
			createname:ClearFocus()
			createbutton:Disable()
			ToggleButtons("")
		end
	end)

	ww:EnslaveTooltip(copybutton, "Copy the selected profile into your current profile.")
	ww:EnslaveTooltip(createbutton, "Duplicate the current profile into a new profile.")

	local function OnShow(frame)
		ww.FadeIn(frame, 0.5)
		profiles = ControlFreak.db:GetProfiles()
	end
	frame:SetScript("OnShow", OnShow)
	OnShow(frame)
end)

InterfaceOptions_AddCategory(frame)
