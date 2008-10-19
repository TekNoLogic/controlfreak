
if not ControlFreak then return end


----------------------
--      Locals      --
----------------------

local tekcheck = LibStub("tekKonfig-Checkbox")
local tekslider = LibStub("tekKonfig-Slider")
local GAP = 8


---------------------
--      Panel      --
---------------------

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Control Freak"
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local ControlFreak = ControlFreak
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Control Freak", "These settings change the 'always up' frame.  They are saved on a per-char basis.")


	local lockpos = tekcheck.new(frame, nil, "Lock frame", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	lockpos.tiptext = "Locks the frame to prevent accidental movement"
	local checksound = lockpos:GetScript("OnClick")
	lockpos:SetScript("OnClick", function(self) checksound(self); ControlFreak.db.char.frameopts.locked = not ControlFreak.db.char.frameopts.locked end)
	lockpos:SetChecked(ControlFreak.db.char.frameopts.locked)


	local showtip = tekcheck.new(frame, nil, "Show tooltip", "TOPLEFT", lockpos, "BOTTOMLEFT", 0, -GAP)
	showtip.tiptext = "Show help tooltip on hover"
	showtip:SetScript("OnClick", function(self) checksound(self); ControlFreak.db.char.showtooltip = not ControlFreak.db.char.showtooltip end)
	showtip:SetChecked(ControlFreak.db.char.showtooltip)


	local compactmode = tekcheck.new(frame, nil, "Compact mode", "TOPLEFT", showtip, "BOTTOMLEFT", 0, -GAP)
	compactmode.tiptext = "Use compact feedback frame"
	compactmode:SetScript("OnClick", function(self)
		checksound(self)
		ControlFreak.db.char.compactmode = not ControlFreak.db.char.compactmode
		ControlFreakFrame:SetText(ControlFreak.db.char.compactmode and "000s" or "Controlled (000s)")
		ControlFreakFrame:Resize()
		ControlFreak:OnUpdate(true)
	end)
	compactmode:SetChecked(ControlFreak.db.char.compactmode)


	local threshslider, threshslidertext, threshcontainer = tekslider.new(frame, "Break Threshold: "..ControlFreak.db.char.breakthreshold.." sec", 0, 50, "LEFT", frame, "TOP", GAP, 0)
	threshcontainer:SetPoint("TOP", lockpos, "TOP", 0, 0)
	threshslider.tiptext = "Time (in seconds) before spell breaks to unfade frame."
	threshslider:SetValue(ControlFreak.db.char.breakthreshold)
	threshslider:SetValueStep(1)
	threshslider:SetScript("OnValueChanged", function()
		ControlFreak.db.char.breakthreshold = threshslider:GetValue()
		threshslidertext:SetText("Break Threshold: "..ControlFreak.db.char.breakthreshold.." sec")
	end)


	local alpha = math.floor(ControlFreak.db.char.alpha*100 + .5)
	local alphaslider, alphaslidertext, alphacontainer = tekslider.new(frame, "Alpha: "..alpha.."%", "0%", "100%", "TOP", threshcontainer, "BOTTOM", 0, -GAP)
	alphaslider.tiptext = "Alpha level to fade frame to when focus is controlled, dead, or not set."
	alphaslider:SetValue(ControlFreak.db.char.alpha)
	alphaslider:SetValueStep(0.05)
	alphaslider:SetScript("OnValueChanged", function()
		ControlFreak.db.char.alpha = alphaslider:GetValue()
		local alpha = math.floor(ControlFreak.db.char.alpha*100 + .5)
		alphaslidertext:SetText("Alpha: "..alpha.."%")
		ControlFreak:OnUpdate(true)
	end)


	local scale = math.floor(ControlFreak.db.char.frameopts.scale*100 + .5)
	local scaleslider, scaleslidertext = tekslider.new(frame, "Scale: "..scale.."%", "50%", "200%", "TOP", alphacontainer, "BOTTOM", 0, -GAP)
	scaleslider.tiptext = "Frame scale."
	scaleslider:SetValue(ControlFreak.db.char.frameopts.scale)
	scaleslider:SetValueStep(0.05)
	scaleslider:SetScript("OnValueChanged", function()
		local block, db = ControlFreakFrame, ControlFreak.db.char.frameopts
		local oldscale, oldx, oldy = block:GetScale(), block:GetCenter()
		db.scale = scaleslider:GetValue()
		db.x, db.y = oldx * oldscale / db.scale, oldy * oldscale / db.scale
		block:Position()
		scaleslidertext:SetText("Scale: "..math.floor(db.scale*100 + .5).."%")
	end)


	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)


-----------------------------
--      Slash command      --
-----------------------------

SLASH_CONTROLFREAK1 = "/freak"
SlashCmdList.CONTROLFREAK = function() InterfaceOptionsFrame_OpenToCategory(frame) end


----------------------------------------
--      Quicklaunch registration      --
----------------------------------------

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local launcher = ldb:GetDataObjectByName("ControlFreak") or ldb:NewDataObject("ControlFreak", {
	type = "launcher",
	icon = "Interface\\AddOns\\ControlFreak\\icon",
})
function launcher.OnClick() InterfaceOptionsFrame_OpenToCategory(frame) end
