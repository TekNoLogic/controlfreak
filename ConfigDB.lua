

if not ControlFreak then return end


----------------------
--      Locals      --
----------------------

local ww = LibStub("WidgetWarlock-Alpha1")
local GAP, EDGEGAP, DROPDOWNOFFSET = 8, 16, 16


---------------------
--      Panel      --
---------------------

local frame = CreateFrame("Frame", nil, UIParent)
frame.name = "Macro Profile"
frame.parent = "Control Freak"
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local ControlFreak = ControlFreak
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Macro Profile", "Tese controls let you select a different macro, or create your own.  To reset a default profile you've changed, just delete it!")


--~ 	local currentgroup = ww:SummonGroupBox(frame, nil, 105, "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
--~ 	currentgroup:SetPoint("LEFT", GAP, 0)
--~ 	currentgroup:SetPoint("RIGHT", -GAP, 0)
	local currentlabel = ww:SummonFontString(frame, "OVERLAY", "GameFontNormal", "Current profile:", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	local current = ww:SummonFontString(frame, "OVERLAY", "GameFontHighlight", ControlFreak.db:GetCurrentProfile(), "LEFT", currentlabel, "RIGHT", 10, 0)

	local profiles = ControlFreak.db:GetProfiles()

	local selected = CreateFrame("Frame", "ControlFreakProfileMenu", frame, "UIDropDownMenuTemplate")
	local loadbutton = ww:SummonButton(frame, "Load", nil, nil, "TOPLEFT", selected, "BOTTOMLEFT", DROPDOWNOFFSET, -GAP/2)
	local copybutton = ww:SummonButton(frame, "Copy", nil, nil, "LEFT", loadbutton, "RIGHT", GAP, 0)
	local deletebutton = ww:SummonButton(frame, "Delete", nil, nil, "LEFT", copybutton, "RIGHT", GAP, 0)

	selected:SetPoint("TOPLEFT", currentlabel, "BOTTOMLEFT", -DROPDOWNOFFSET, -GAP)
	ControlFreakProfileMenuRight:ClearAllPoints()
	ControlFreakProfileMenuRight:SetPoint("TOP", ControlFreakProfileMenuLeft)
	ControlFreakProfileMenuRight:SetPoint("RIGHT", frame, -EDGEGAP + DROPDOWNOFFSET, 0)
--~ 	ControlFreakProfileMenuMiddle:SetPoint("LEFT", ControlFreakProfileMenuLeft, "RIGHT")
	ControlFreakProfileMenuMiddle:SetPoint("RIGHT", ControlFreakProfileMenuRight, "LEFT")
--~ 	ControlFreakProfileMenuMiddle:SetWidth(250)

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

	local function selectedOnShow(self)
		UIDropDownMenu_Initialize(self, DropdownInit)
		UIDropDownMenu_SetSelectedValue(selected, profiles[1])
		ToggleButtons(profiles[1])
	end
	selected:SetScript("OnShow", selectedOnShow)
	selectedOnShow(selected)

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

	local createname = ww:SummonEditBox(frame, 187, "TOPLEFT", loadbutton, "BOTTOMLEFT", 8, 1)
	local createbutton = ww:SummonButton(frame, "Create", nil, nil, "LEFT", createname, "RIGHT", 5, -1)
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
