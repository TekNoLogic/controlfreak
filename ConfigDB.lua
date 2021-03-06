﻿

if not ControlFreak then return end


----------------------
--      Locals      --
----------------------

local ww = LibStub("WidgetWarlock-Alpha1")
local butt = LibStub("tekKonfig-Button")
local GAP, EDGEGAP, DROPDOWNOFFSET, NUMROWS, ROWHEIGHT = 8, 16, 16, 13, 18


---------------------
--      Panel      --
---------------------

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Macro Profile"
frame.parent = "Control Freak"
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local ControlFreak = ControlFreak
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Control Freak - Macro Profile", "These controls let you select a different macro, or create your own.  To reset a default profile you've changed, just delete it!")


	local currentlabel = ww:SummonFontString(frame, "OVERLAY", "GameFontNormal", "Current profile:", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	local current = ww:SummonFontString(frame, "OVERLAY", "GameFontHighlight", ControlFreak.db:GetCurrentProfile(), "LEFT", currentlabel, "RIGHT", 10, 0)


	local createname = ww:SummonEditBox(frame, 255, "TOPLEFT", currentlabel, "BOTTOMLEFT", GAP - 2, -1)
	local createbutton = butt.new(frame, "LEFT", createname, "RIGHT", 5, 0)
	createbutton:SetText("Create")
	createbutton:Disable()
	createname:SetScript("OnTextChanged", function(frame) if frame:GetText() ~= "" then createbutton:Enable() else createbutton:Disable() end end)


	local deletebutton = butt.new(frame, "BOTTOMRIGHT", -EDGEGAP, EDGEGAP)
	deletebutton:SetText("Delete")

	local copybutton = butt.new(frame, "RIGHT", deletebutton, "LEFT", -GAP, 0)
	copybutton:SetText("Copy")

	local loadbutton = butt.new(frame, "RIGHT", copybutton, "LEFT", -GAP, 0)
	loadbutton:SetText("Load")

	local function ToggleButtons(value)
		if not value or value == ControlFreak.db:GetCurrentProfile() then
			loadbutton:Disable()
			copybutton:Disable()
			deletebutton:Disable()
		else
			loadbutton:Enable()
			copybutton:Enable()
			deletebutton:Enable()
		end
	end
	ToggleButtons()


	local rows = {}
	local offset, selectedprofile, proflies = 0
	local function sort(a,b) return string.lower(a) < string.lower(b) end
	local function UpdateRows()
		table.sort(profiles, sort)
		for i,row in ipairs(rows) do
			local profile = profiles[i + offset]
			if profile then
				row.text:SetText((profile == ControlFreak.db:GetCurrentProfile() and "|cff999999" or "")..profile)
				if profile == ControlFreak.db:GetCurrentProfile() then row:Disable() else row:Enable() end
				row.value = profile
				row:SetChecked(selectedprofile == profile)
			else
				row.text:SetText()
				row:Disable()
				row:SetChecked(false)
			end
		end
	end

	local function rowOnClick(self)
		selectedprofile = selectedprofile ~= self.value and self.value or nil
		ToggleButtons(selectedprofile)
		UpdateRows()
	end

	local function OnMouseWheel(f, val)
		offset = offset - val
		if (offset + NUMROWS) > #profiles then offset = #profiles - NUMROWS end
		if offset < 0 then offset = 0 end
		UpdateRows()
	end

	for i=1,NUMROWS do
		local row = CreateFrame("CheckButton", nil, frame)
		row:SetHeight(ROWHEIGHT)
		if i == 1 then row:SetPoint("TOP", createname, "BOTTOM", 0, -2) else row:SetPoint("TOP", rows[i-1], "BOTTOM", 0, 0) end
		row:SetPoint("LEFT", EDGEGAP, 0)
		row:SetPoint("RIGHT", -EDGEGAP, 0)

		row.text = ww:SummonFontString(row, "OVERLAY", "GameFontWhite", "SAMPLE PROFILE "..i, "LEFT", row, 10, 0)
		row.text:SetPoint("RIGHT", row, -10, 0)
		row.text:SetJustifyH("LEFT")

		local highlight = ww:SummonTextureWithCoords(row, nil, nil, nil, "Interface\\HelpFrame\\HelpFrameButton-Highlight", 0, 1, 0, 0.578125)
		highlight:SetAllPoints()
		row:SetHighlightTexture(highlight)
		row:SetCheckedTexture(highlight)

		row:EnableMouseWheel()
		row:SetScript("OnMouseWheel", OnMouseWheel)
		row:SetScript("OnClick", rowOnClick)
		rows[i] = row
	end


	loadbutton:SetScript("OnClick", function()
		local profile = selectedprofile
		ControlFreak.db:SetProfile(profile)
		current:SetText(profile)
		selectedprofile = nil
		ToggleButtons()
		UpdateRows()
	end)
	copybutton:SetScript("OnClick", function()
		ControlFreak.db:ResetProfile()
		ControlFreak.db:CopyProfile(selectedprofile)
		profiles = ControlFreak.db:GetProfiles()
	end)
	deletebutton:SetScript("OnClick", function()
		ControlFreak.db:DeleteProfile(selectedprofile)
		profiles, selectedprofile = ControlFreak.db:GetProfiles(), nil
		ToggleButtons()
		UpdateRows()
	end)
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
			UpdateRows()
		end
	end)

	ww:EnslaveTooltip(copybutton, "Copy the selected profile into your current profile.")
	ww:EnslaveTooltip(deletebutton, "Delete the selected profile.  Default profiles will reset to their original settings when deleted.")
	ww:EnslaveTooltip(createbutton, "Duplicate the current profile into a new profile.")

	local function OnShow(frame)
		profiles = ControlFreak.db:GetProfiles()
		UpdateRows()
	end
	frame:SetScript("OnShow", OnShow)
	OnShow(frame)
end)

InterfaceOptions_AddCategory(frame)
