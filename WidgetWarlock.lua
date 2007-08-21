

WidgetWarlock = {}
local WidgetWarlock = WidgetWarlock


-----------------------------------
--      Background Textures      --
-----------------------------------

WidgetWarlock.TooltipBorderBG = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}


WidgetWarlock.HrizontalSliderBG = {
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	edgeSize = 8, tile = true, tileSize = 8,
	insets = {left = 3, right = 3, top = 6, bottom = 6}
}


------------------------------
--      Widget Summons      --
------------------------------

function WidgetWarlock.SummonCheckBox(size, parent, ...)
	local check = CreateFrame("CheckButton", nil, parent)
	check:SetWidth(size)
	check:SetHeight(size)
	if select(1, ...) then check:SetPoint(...) end

	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

	return check
end


function WidgetWarlock.SummonLabeledCheckBox(label, size, parent, ...)
	local check = WidgetWarlock.SummonCheckBox(size, parent, ...)
	local fs = WidgetWarlock.EnslaveLabel(check, label)
	return check, fs
end


function WidgetWarlock.SummonSlider(parent, label, lowvalue, highvalue, ...)
	local slider = CreateFrame("Slider", nil, parent)
	slider:SetWidth(128)
	slider:SetHeight(17)
	if select(1, ...) then slider:SetPoint(...) end
	slider:SetOrientation("HORIZONTAL")
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	slider:SetBackdrop(WidgetWarlock.HrizontalSliderBG)
	local text = WidgetWarlock.SummonFontString(slider, nil, "ARTWORK", "GameFontNormalSmall", label, "BOTTOM", slider, "TOP")
	local low  = WidgetWarlock.SummonFontString(slider, nil, "ARTWORK", "GameFontHighlightSmall", lowvalue, "TOPLEFT", slider, "BOTTOMLEFT", 2, 3)
	local high = WidgetWarlock.SummonFontString(slider, nil, "ARTWORK", "GameFontHighlightSmall", highvalue, "TOPRIGHT", slider, "BOTTOMRIGHT", -2, 3)

	if type(lowvalue) == "string" then slider:SetMinMaxValues(tonumber((lowvalue:gsub("%%", "")))/100, tonumber((highvalue:gsub("%%", "")))/100)
	else slider:SetMinMaxValues(lowvalue, highvalue) end

	return slider, text, low, high
end


function WidgetWarlock.SummonOptionHouseBaseFrame(frametype, name)
	local frame = CreateFrame(frametype or "Frame", name, OptionHouseOptionsFrame)
	frame:SetWidth(630)
	frame:SetHeight(305)
	frame:SetFrameStrata("HIGH")
	return frame
end


function WidgetWarlock.SummonTexture(parent, w, h, texture, ...)
	local tex = parent:CreateTexture()
	tex:SetWidth(w)
	tex:SetHeight(h)
	tex:SetTexture(texture)
	if select(1, ...) then tex:SetPoint(...) end
	return tex
end


function WidgetWarlock.SummonFontString(parent, name, layer, inherit, text, ...)
	local fs = parent:CreateFontString(name, layer, inherit)
	fs:SetText(text)
	if select(1, ...) then fs:SetPoint(...) end
	return fs
end


function WidgetWarlock.EnslaveLabel(frame, text, a1, aframe, a2, dx, dy)
	if not a1 then a1, aframe, a2, dx, dy = "LEFT", frame, "RIGHT", 5, 0 end
	local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	fs:SetPoint(a1, aframe, a2, dx, dy)
	fs:SetText(text)
	return fs
end


------------------------
--      Tooltips      --
------------------------

local tipvalues, tipanchors = {}, {}
local GameTooltip = GameTooltip

local function HideTooltip()
	GameTooltip:Hide()
end


local function ShowTooltip(self)
	local text = type(tipvalues[self]) == "function" and tipvalues[self]() or tipvalues[self]
 	GameTooltip:SetOwner(self, tipanchors[self])
	GameTooltip:SetText(text)
end


function WidgetWarlock.EnslaveTooltip(frame, text, anchor)
	if not text then
		frame:SetScript("OnEnter", nil)
		frame:SetScript("OnLeave", nil)
	else
		frame:SetScript("OnEnter", ShowTooltip)
		frame:SetScript("OnLeave", HideTooltip)
		tipvalues[frame] = text
		tipanchors[frame] = anchor or "ANCHOR_RIGHT"
	end
end
