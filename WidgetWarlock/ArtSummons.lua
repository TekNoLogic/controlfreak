
local lib = LibStub("WidgetWarlock-Alpha1", true)
if not lib.upgrading or lib.upgrading >= 1 then return end



-- Creates a texture object based on coords.
-- Cannot SetPoint!  You must do this.
-- Parent and coords (...) are required, all others optional
function lib:SummonTextureWithCoords(parent, layer, w, h, texture, ...)
	assert(parent, "Must pass a parent frame to create the texture")

	local tex = parent:CreateTexture(nil, layer)
	tex:SetTexture(texture)
	tex:SetTexCoord(...)
	if w then tex:SetWidth(w) end
	if h then tex:SetHeight(h) end
	return tex
end


-- Create a texture, set dims, texture and point if passed
-- Parent required, all others optional
function lib:SummonTexture(parent, layer, w, h, texture, ...)
	assert(parent, "Must pass a parent frame to create the texture")

	local tex = parent:CreateTexture(nil, layer)
	if w then tex:SetWidth(w) end
	if h then tex:SetHeight(h) end
	tex:SetTexture(texture)
	if select(1, ...) then tex:SetPoint(...) end
	return tex
end


-- Create a font string, set it's text and point
-- Parent required, all others optional
function lib:SummonFontString(parent, layer, inherit, text, ...)
	assert(parent, "Must pass a parent frame to create the fontstring")

	local fs = parent:CreateFontString(nil, layer, inherit)
	fs:SetText(text)
	if select(1, ...) then fs:SetPoint(...) end
	return fs
end


-- Attaches a label to a frame
-- Parent required, all others optional
-- Defaults to right side of the frame is no point is given
function lib:EnslaveLabel(parent, text, a1, aframe, a2, dx, dy)
	assert(parent, "Must pass a parent frame to create the fontstring")

	if not a1 then a1, aframe, a2, dx, dy = "LEFT", parent, "RIGHT", 5, 0 end
	local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fs:SetPoint(a1, aframe, a2, dx, dy)
	fs:SetText(text)
	return fs
end


lib.upgrading = nil
