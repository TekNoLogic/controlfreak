local major = "LegoBlock-Beta0-1.0"
local minor = tonumber(string.match("$Revision$", "(%d+)") or 1)

assert(DongleStub, string.format("%s requires DongleStub.", major))
if not DongleStub:IsNewerVersion(major, minor) then return end

local bg = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}

local minWidth = 20
local legos
local LegoBlock = {}

local DongleFrames = DongleStub("DongleFrames-1.0")

local TL, TR, BL, BR = "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
local L, R, C, T, B = "LEFT", "RIGHT", "CENTER", "TOP", "BOTTOM"
local border = 4
-- copied from PerfectRaid, credit goes to cladhaire
function LegoBlock:SavePosition(name)
	local f = getglobal(name)
	if not f then return end
	local x,y = f:GetCenter()
	local anchor = 'CENTER'
	local s = f:GetEffectiveScale()

	local h, w = UIParent:GetHeight(), UIParent:GetWidth()
	local xOff, yOff, anchor = 0, 0, 'CENTER'
	local fW, fH = f:GetWidth() / 2, f:GetHeight() / 2
	local left, top, right, bottom = x - fW, y + fH, x + fW, y - fH
	if (x > w/2) then -- on the right half of the screen
		if (y > h/2) then -- top half
			xOff = -(w - right)
			yOff = -(h - top)
			anchor = TR
		else -- bottom half
			xOff = -(w - right)
			yOff = bottom
			anchor = BR
		end
	else -- on the left half of the screen
		if (y > h/2) then -- top half
			xOff = left
			yOff = -(h - top)
			anchor = TL
		else -- bottom half
			xOff = left
			yOff = bottom
			anchor = BL
		end
	end
	return xOff*s, yOff*s, anchor
end

-- copied from PerfectRaid, credit goes to cladhaire
function LegoBlock:RestorePosition(name, x, y, anchor)
	local f = getglobal(name)
	local h, w = UIParent:GetHeight(), UIParent:GetWidth()
	local s = f:GetEffectiveScale()

	if not x or not y or not anchor then
		f:ClearAllPoints()
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		return
	end

	x, y = x/s, y/s
	f:SetPoint(anchor, UIParent, anchor, x, y)
end

local function SetManyAttributes(self, ...)
	for i=1,select("#", ...),2 do
		local att,val = select(i, ...)
		if not att then return end
		self:SetAttribute(att,val)
	end
end

function LegoBlock:SetText(text, noresize)
	text = text or ''
	self.showText = text ~= ''
	self.Text:SetText(text)
	if noresize or self.noresize or InCombatLockdown() then return end

	local w = minWidth
	if self.showIcon then w = w + self.Icon:GetWidth() end
	if self.showText then w = w + self.Text:GetStringWidth() end
	self:SetWidth(w)
end

function LegoBlock:SetIcon(icon)
	self.showIcon = icon and true
	self.Icon:SetTexture(icon)
	local w = minWidth
	if self.showIcon then w = w + self.Icon:GetWidth() end
	if self.showText then w = w + self.Text:GetStringWidth() end
	self:SetWidth(w)
end

function LegoBlock:OnDragStart()
	if InCombatLockdown() then return end -- disable moving in combat
	-- here we do sticky stuff
	StickyFrames:StartMoving(self, legos, border, border, border, border)
	--self:StartMoving()
	self.isMoving = true
end

function LegoBlock:OnDragStop()
	if InCombatLockdown() or not self.isMoving then return end -- disable moving in combat, if not moving, jump out
	-- here we do sticky stuff
	StickyFrames:StopMoving(self)
	StickyFrames:AnchorFrame(self)
	self:StopMovingOrSizing()
	self.isMoving = false
end

function LegoBlock:GetLego(name,text, icon)
	local w = minWidth
	local frame = DongleFrames:Create("t=Button#n=Lego"..name.."#p=UIParent#size=50,32#mouse#drag=LeftButton#movable#clamp#inh=SecureActionButtonTemplate", "CENTER", 0, -200)
	frame.Icon = DongleFrames:Create(frame,"t=Texture#size=24,24", L, 4, 0)
	frame.Text = DongleFrames:Create(frame,"t=FontString#inh=GameFontNormal", L, frame.Icon, R, 0, 0)
	frame.showIcon = false
	frame.showText = false
	frame.Icon:Hide()
	frame:SetBackdrop(bg)
	frame:SetBackdropColor(0,0,0,0.4)
	frame:SetScript("OnDragStart", self.OnDragStart)
	frame:SetScript("OnDragStop", self.OnDragStop)
	if icon then
		frame.showIcon = true
		w = w + frame.Icon:GetWidth()
		frame.Icon:SetTexture(icon)
		frame.Icon:Show()
	end
	if text then
		frame.showText = true
		frame.Text:SetText(text)
		w = w + frame.Text:GetStringWidth()
	end
	if not frame.showIcon then
		frame.Text:ClearAllPoints()
		frame.Text:SetPoint(C, 0, 0)
	end
	frame:SetWidth(w)
	frame.SetText = self.SetText
	frame.SetManyAttributes = SetManyAttributes
	tinsert(legos, frame)
	return frame
end

-- [[ Misc library related stuff ]]--

local function Activate(new, old)
	new.legos = old and old.legos or {}
	legos = new.legos
end

function LegoBlock:GetVersion() return major,minor end

DongleStub:Register(LegoBlock, Activate)
