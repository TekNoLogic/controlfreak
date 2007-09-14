
local lib, oldminor = LibStub:NewLibrary("WidgetWarlock-Alpha1", 3)
if not lib then return end
lib.upgrading = oldminor or 0
if lib.upgrading >= 3 then return end


-- Creates a text edit box.
-- All args optional, parent highly recommended
function lib:SummonEditBox(parent, w, ...)
	local f = CreateFrame('EditBox', nil, parent)
	f:SetAutoFocus(false)

	local left = self:SummonTextureWithCoords(f, "BACKGROUND", 8, 20, "Interface\\Common\\Common-Input-Border", 0, 0.0625, 0, 0.625)
	local right = self:SummonTextureWithCoords(f, "BACKGROUND", 8, 20, "Interface\\Common\\Common-Input-Border", 0.9375, 1, 0, 0.625)
	local center = self:SummonTextureWithCoords(f, "BACKGROUND", 10, 20, "Interface\\Common\\Common-Input-Border", 0.0625, 0.9375, 0, 0.625)

	left:SetPoint("LEFT", f, "LEFT", -5, 0)
	right:SetPoint("RIGHT", f, "RIGHT", 0, 0)
	center:SetPoint("RIGHT", right, "LEFT", 0, 0)
	center:SetPoint("LEFT", left, "RIGHT", 0, 0)

	f:SetScript("OnEscapePressed", f.ClearFocus)
	f:SetScript("OnEditFocusLost", lib.ClearHighlight)
	f:SetScript("OnEditFocusGained", f.HighlightText)

	f:SetFontObject('ChatFontNormal')

	if select('#', ...) > 0 then f:SetPoint(...) end
	f:SetWidth(w or 100)
	f:SetHeight(32)

	return f
end


if lib.upgrading >= 1 then return end



-- Creates a background box to place behind widgets for visual grouping.
-- All args optional, parent highly recommended
function lib:SummonGroupBox(parent, w, h, ...)
	local box = CreateFrame('Frame', nil, parent)
	box:SetBackdrop(self.GroupBoxBG)
	box:SetBackdropBorderColor(0.4, 0.4, 0.4)
	box:SetBackdropColor(0.1, 0.1, 0.1)
	if select('#',...) > 0 then box:SetPoint(...) end
	if w then box:SetWidth(w) end
	if h then box:SetHeight(h) end

	return box
end


function lib.ClearHighlight(f) f:HighlightText(0,0) end


-- Creates a button
-- All args optional, parent highly recommended
function lib:SummonButton(parent, text, w, h, ...)
	local b = CreateFrame("Button", nil, parent)
 	if select(1, ...) then b:SetPoint(...) end
	b:SetWidth(w or 90)
	b:SetHeight(h or 21)

	-- Fonts --
	b:SetDisabledFontObject(GameFontDisable)
	b:SetHighlightFontObject(GameFontHighlight)
	b:SetTextFontObject(GameFontNormal)

	-- Textures --
	b:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	b:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	b:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	b:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	b:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	b:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	b:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	b:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	b:GetHighlightTexture():SetBlendMode("ADD")

	b:SetText(text)

	return b
end


-- Create a checkbox.
-- All args optional but parent is highly recommended
function lib:SummonCheckBox(parent, size, ...)
	local check = CreateFrame("CheckButton", nil, parent)
	check:SetWidth(size or 32)
	check:SetHeight(size or 32)
	if select(1, ...) then check:SetPoint(...) end

	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

	return check
end


-- Create a slider.
-- All args optional, parent recommended
-- If lowvalue and highvalue are strings it is assumed they are % values
-- and the % is parsed and set as decimal values for min/max
function lib:SummonSlider(parent, label, lowvalue, highvalue, ...)
	local slider = CreateFrame("Slider", nil, parent)
	slider:SetWidth(128)
	slider:SetHeight(17)
	if select(1, ...) then slider:SetPoint(...) end
	slider:SetOrientation("HORIZONTAL")
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	slider:SetBackdrop(self.HorizontalSliderBG)
	local text = self:SummonFontString(slider, "ARTWORK", "GameFontNormalSmall", label, "BOTTOM", slider, "TOP")
	local low  = self:SummonFontString(slider, "ARTWORK", "GameFontHighlightSmall", lowvalue, "TOPLEFT", slider, "BOTTOMLEFT", 2, 3)
	local high = self:SummonFontString(slider, "ARTWORK", "GameFontHighlightSmall", highvalue, "TOPRIGHT", slider, "BOTTOMRIGHT", -2, 3)

	if type(lowvalue) == "string" then slider:SetMinMaxValues(tonumber((lowvalue:gsub("%%", "")))/100, tonumber((highvalue:gsub("%%", "")))/100)
	else slider:SetMinMaxValues(lowvalue, highvalue) end

	return slider, text, low, high
end



