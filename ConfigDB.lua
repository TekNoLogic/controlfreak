
local ww = LibStub("WidgetWarlock-Alpha1")


function ControlFreak:CreateProfilePanel()
	frame = CreateFrame("Frame", nil, UIParent)

	local currentgroup = ww:SummonGroupBox(frame, 310, 105, "TOPLEFT", 5, -20)
	local currentlabel = ww:SummonFontString(currentgroup, "OVERLAY", "GameFontNormal", "Current profile:", "TOPLEFT", 10, 15)
	local current = ww:SummonFontString(frame, "OVERLAY", "GameFontHighlight", self.db:GetCurrentProfile(), "LEFT", currentlabel, "RIGHT", 10, 0)

	local profiles = self.db:GetProfiles()

	local selected = CreateFrame("Frame", "ControlFreakProfileMenu", currentgroup, "UIDropDownMenuTemplate")
	local loadbutton = ww:SummonButton(currentgroup, "Load", nil, nil, "TOPLEFT", selected, "BOTTOMLEFT", 15, -5)
	local copybutton = ww:SummonButton(currentgroup, "Copy", nil, nil, "LEFT", loadbutton, "RIGHT", 10, 0)
	local deletebutton = ww:SummonButton(currentgroup, "Delete", nil, nil, "LEFT", copybutton, "RIGHT", 10, 0)

	selected:SetPoint("TOPLEFT", -5, -10)
	ControlFreakProfileMenuMiddle:SetWidth(250)

	local function ToggleButtons(value)
		if value == self.db:GetCurrentProfile() then
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
		local current = self.db:GetCurrentProfile()
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
		self.db:SetProfile(profile)
		current:SetText(profile)
		ToggleButtons(profile)

		self.macroupdated = true
		if not InCombatLockdown() then self:PLAYER_REGEN_ENABLED() end

		self:ParseDebuffs(string.split(",", self.db.profile.spellname))
	end)
	copybutton:SetScript("OnClick", function()
		self.db:ResetProfile()
		self.db:CopyProfile(UIDropDownMenu_GetSelectedValue(selected))
		profiles = self.db:GetProfiles()

		self.macroupdated = true
		if not InCombatLockdown() then self:PLAYER_REGEN_ENABLED() end

		self:ParseDebuffs(string.split(",", self.db.profile.spellname))
	end)
	deletebutton:SetScript("OnClick", function()
		self.db:DeleteProfile(UIDropDownMenu_GetSelectedValue(selected))
		profiles = self.db:GetProfiles()
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
			local oldprofile = self.db:GetCurrentProfile()
			self.db:SetProfile(profile)
			self.db:CopyProfile(oldprofile)
			current:SetText(profile)
			profiles = self.db:GetProfiles()
			createname:SetText("")
			createname:ClearFocus()
			createbutton:Disable()
			ToggleButtons("")
		end
	end)

	ww:EnslaveTooltip(copybutton, "Copy the selected profile into your current profile.")
	ww:EnslaveTooltip(createbutton, "Duplicate the current profile into a new profile.")

	frame:SetScript("OnShow", function(frame)
		ww.FadeIn(frame, 0.5)
		profiles = self.db:GetProfiles()
	end)

	return frame
end

