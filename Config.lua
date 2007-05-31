-- Size: 630 305
-- Offset: 190 -103

if not ControlFreak then return end


local DongleFrames = DongleStub("DongleFrames-1.0")
local ControlFreak, tiptexts = ControlFreak


local bg = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}


local function HideTooltip()
	GameTooltip:Hide()
end


local function ShowTooltip(self)
 	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(tiptexts[self])
end


tiptexts = setmetatable({}, {
	__newindex = function(t,i,v)
		i:SetScript("OnEnter", ShowTooltip)
		i:SetScript("OnLeave", HideTooltip)
		rawset(t,i,v)
	end,
})


local function AddLabel(frame, text, a1, aframe, a2, dx, dy)
	if not a1 then a1, aframe, a2, dx, dy = "LEFT", frame, "RIGHT", 5, 0 end
	local textframe = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	textframe:SetPoint(a1, aframe, a2, dx, dy)
	textframe:SetText(text)
	return textframe
end


function ControlFreak.CreatePanel()
	local name = "ControlFreakOptions"
	local parent = "" --"#p=OptionsHouseFrame"

	local f = getglobal(name)
	if f then return f:Show() end

	local frame = DongleFrames:Create("t=Frame#n="..name..parent.."#size=630,305#toplevel", "TOPLEFT", 190, -103)

	if parent == "" then
		frame:SetBackdrop(bg)
		frame:SetBackdropColor(.1,.1,.1,.75)
		table.insert(UISpecialFrames, name)
	end

	local lockpos = DongleFrames:Create("t=CheckButton#n="..name.."Lock#p="..name.."#size=22,22#inh=OptionsCheckButtonTemplate#toplevel", "TOPLEFT", 5, -5)
	lockpos:SetScript("OnClick", function() ControlFreak.locked = not ControlFreak.locked end)
	lockpos:SetChecked(ControlFreak.locked)
	AddLabel(lockpos, "Lock frame")
	tiptexts[lockpos] = "Locks the frame to prevent accidental movement"


	local editbox = DongleFrames:Create("t=EditBox#n="..name.."Edit#p="..name.."#w=620#toplevel", "BOTTOMLEFT", 5, 5)
	editbox:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, 205)
	editbox:SetFontObject(GameFontHighlight)
	editbox:SetTextInsets(8,8,8,8)
	editbox:SetBackdrop(bg)
	editbox:SetBackdropColor(.1,.1,.1,.3)
	editbox:SetMultiLine(true)
	editbox:SetAutoFocus(false)
	editbox:SetText(ControlFreak:GetMacro())
	editbox:SetScript("OnTextChanged", function(self) end)
	editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	AddLabel(editbox, "Macro", "BOTTOMLEFT", editbox, "TOPLEFT", 5, 0)
end
