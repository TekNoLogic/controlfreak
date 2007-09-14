
local lib = LibStub("WidgetWarlock-Alpha1", true)
if not lib.upgrading or lib.upgrading >= 2 then return end


lib.tipvalues = {}
lib.tipanchors = setmetatable({}, {__index = function() return "ANCHOR_RIGHT" end})
local GameTooltip = GameTooltip

function lib.HideTooltip() GameTooltip:Hide() end
function lib.ShowTooltip(self)
	local text = type(lib.tipvalues[self]) == "function" and lib.tipvalues[self]() or lib.tipvalues[self]
	GameTooltip:SetOwner(self, lib.tipanchors[self])
	GameTooltip:SetText(text, nil, nil, nil, nil, true)
end


function lib:EnslaveTooltip(frame, text, anchor)
	assert(frame, "Must pass a frame")

	if not text then
		frame:SetScript("OnEnter", nil)
		frame:SetScript("OnLeave", nil)
	else
		frame:SetScript("OnEnter", lib.ShowTooltip)
		frame:SetScript("OnLeave", lib.HideTooltip)
		lib.tipvalues[frame] = text
		lib.tipanchors[frame] = anchor
	end
end
