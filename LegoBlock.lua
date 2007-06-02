local major = "LegoBlock-Beta0-1.0"
local minor = tonumber(string.match("$Revision: 15 $", "(%d+)") or 1)

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
local legoGroups
local LegoBlock = {}

local DongleFrames = DongleStub("DongleFrames-1.0")

local TL, TR, BL, BR = "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
local L, R, C, T, B = "LEFT", "RIGHT", "CENTER", "TOP", "BOTTOM"
local border = 4

--[[---------------------------------------------------------------------------------
  General Library providing an alternate StartMoving() that allows you to
  specify a number of frames to snap-to when moving the frame around
------------------------------------------------------------------------------------]]

--[[---------------------------------------------------------------------------------
  Class declaration, along with a temporary table to hold any existing OnUpdate
  scripts.
------------------------------------------------------------------------------------]]

local StickyFrames = {}
StickyFrames.scripts = {}
StickyFrames.stuckFrames = {}

--[[---------------------------------------------------------------------------------
  StickyFrames:StartMoving() - Sets a custom OnUpdate for the frame so it follows
  the mouse and snaps to the frames you specify

	frame:	 	The frame we want to move.  Is typically "this"

	frameList: 	A integer indexed list of frames that the given frame should try to
				stick to.  These don't have to have anything special done to them,
				and they don't really even need to exist.  You can inclue the
				moving frame in this list, it will be ignored.  This helps you
				if you have a number of frames, just make ONE list to pass.

				{WatchDogFrame_player, WatchDogFrame_party1, .. WatchDogFrame_party4}

	left:		If your frame has a tranparent border around the entire frame
				(think backdrops with borders).  This can be used to fine tune the
				edges when you're stickying groups.  Refers to any offset on the
				LEFT edge of the frame being moved.

	top:		same
	right:		same
	bottom:		same
------------------------------------------------------------------------------------]]

function StickyFrames:StartMoving(frame, frameList, left, top, right, bottom)
	local x,y = GetCursorPosition()
	local aX,aY = frame:GetCenter()
	local aS = frame:GetEffectiveScale()

	aX,aY = aX*aS,aY*aS
	local xoffset,yoffset = (aX - x),(aY - y)
	self.scripts[frame] = frame:GetScript("OnUpdate")
	frame:SetScript("OnUpdate", self:GetUpdateFunc(frame, frameList, xoffset, yoffset, left, top, right, bottom))
end

--[[---------------------------------------------------------------------------------
  This stops the OnUpdate, leaving the frame at its last position.  This will
  leave it anchored to UIParent.  You can call StickyFrames:AnchorFrame() to
  anchor it back "TOPLEFT" , "TOPLEFT" to the parent.
------------------------------------------------------------------------------------]]

function StickyFrames:StopMoving(frame)
	frame:SetScript("OnUpdate", self.scripts[frame])
	self.scripts[frame] = nil
end

--[[---------------------------------------------------------------------------------
  This can be called in conjunction with StickyFrames:StopMoving() to anchor the
  frame right back to the parent, so you can manipulate its children as a group
  (This is useful in WatchDog)
------------------------------------------------------------------------------------]]

function StickyFrames:AnchorFrame(frame)
	local xA,yA = frame:GetCenter()
	local parent = frame:GetParent() or UIParent
	local xP,yP = parent:GetCenter()
	local sA,sP = frame:GetEffectiveScale(), parent:GetEffectiveScale()

	xP,yP = (xP*sP) / sA, (yP*sP) / sA

	local xo,yo = (xP - xA)*-1, (yP - yA)*-1

	frame:ClearAllPoints()
	frame:SetPoint("CENTER", parent, "CENTER", xo, yo)
end

--[[---------------------------------------------------------------------------------
  Returns an anonymous OnUpdate function for the frame in question.  Need
  to provide the frame, frameList along with the x and y offset (difference between
  where the mouse picked up the frame, and the insets (left,top,right,bottom) in the
  case of borders, etc.
------------------------------------------------------------------------------------]]

function StickyFrames:GetUpdateFunc(frame, frameList, xoffset, yoffset, left, top, right, bottom)
	return function()
		local x,y = GetCursorPosition()
		local s = frame:GetEffectiveScale()
		local sticky = nil
		local snap

		x,y = x/s,y/s

		frame:ClearAllPoints()
		frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x+xoffset, y+yoffset)

		for k,v in ipairs(frameList) do
			if frame ~= v then
				if self:Overlap(frame, v) then
					snap = self:SnapFrame(frame, v, left, top, right, bottom)
					if snap then
						self.stuckFrames[frame] = v
						break
					end
				end
			end
		end
		if not snap then
			self.stuckFrames[frame] = nil
		end
	end
end

--[[---------------------------------------------------------------------------------
  Determines the overlap between two frames.  Returns true if the frames
  overlap anywhere, or false if they don't.  Does not consider alpha on the edges of
  textures.
------------------------------------------------------------------------------------]]
function StickyFrames:Overlap(frameA, frameB)
	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()
	return ((frameA:GetLeft()*sA) < (frameB:GetRight()*sB))
		and ((frameB:GetLeft()*sB) < (frameA:GetRight()*sA))
		and ((frameA:GetBottom()*sA) < (frameB:GetTop()*sB))
		and ((frameB:GetBottom()*sB) < (frameA:GetTop()*sA))
end

--[[---------------------------------------------------------------------------------
  This is called when finding an overlap between two sticky frame.  If frameA is near
  a sticky edge of frameB, then it will snap to that edge and return true.  If there
  is no sticky edge collision, will return false so we can test other frames for
  stickyness.
------------------------------------------------------------------------------------]]
function StickyFrames:SnapFrame(frameA, frameB, left, top, right, bottom)
	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()
	local xA, yA = frameA:GetCenter()
	local xB, yB = frameB:GetCenter()
	local hA, hB = frameA:GetHeight() / 2, ((frameB:GetHeight() * sB) / sA) / 2
	local wA, wB = frameA:GetWidth() / 2, ((frameB:GetWidth() * sB) / sA) / 2

	if not left then left = 0 end
	if not top then top = 0 end
	if not right then right = 0 end
	if not bottom then bottom = 0 end

	-- Lets translate B's coords into A's scale
	xB, yB = (xB*sB) / sA, (yB*sB) / sA

	local stickyAx, stickyAy = wA * 0.75, hA * 0.75
	local stickyBx, stickyBy = wB * 0.75, hB * 0.75

	-- Grab the edges of each frame, for easier comparison

	local lA, tA, rA, bA = frameA:GetLeft(), frameA:GetTop(), frameA:GetRight(), frameA:GetBottom()
	local lB, tB, rB, bB = frameB:GetLeft(), frameB:GetTop(), frameB:GetRight(), frameB:GetBottom()
	local snap = nil

	-- Translate into A's scale
	lB, tB, rB, bB = (lB * sB) / sA, (tB * sB) / sA, (rB * sB) / sA, (bB * sB) / sA

	-- Lets check for Left stickyness
	if lA > (rB - stickyAx) then
		-- If we are 5 pixels above or below the top of the sticky frame
		-- Snap to the top edge of it.
		if tA <= (tB + 5) and tA >= (tB - 5) then
			yA = (tB - hA)
		elseif bA <= (bB + 5) and bA >= (bB - 5) then
			yA = (bB + hA)
		end

		-- Set the x sticky position
		xA = rB + (wA - left)

		-- Delay the snap until later
		snap = R

		-- Check for Right stickyness
	elseif rA < (lB + stickyAx) then
		-- If we are 5 pixels above or below the top of the sticky frame
		-- Snap to the top edge of it.
		if tA <= (tB + 5) and tA >= (tB - 5) then
			yA = (tB - hA)
		elseif bA <= (bB + 5) and bA >= (bB - 5) then
			yA = (bB + hA)
		end

		-- Set the x sticky position
		xA = lB - (wA - right)

		-- Delay the snap until later
		snap = L

	-- Bottom stickyness
	elseif bA > (tB - stickyAy) then

		-- If we are 5 pixels to the left or right of the sticky frame
		-- Snap to the edge of it.

		if lA <= (lB + 5) and lA >= (lB - 5) then
			xA = (lB + wA)
		elseif rA >= (rB - 5) and rA <= (rB + 5) then
			xA = (rB - wA)
		end

		-- Set the y sticky position
		yA = tB + (hA - bottom)

		-- Delay the snap
		snap = B

	elseif tA < (bB + stickyAy) then
		-- If we are 5 pixels to the left or right of the sticky frame
		-- Snap to the edge of it.
		if lA <= (lB + 5) and lA >= (lB - 5) then
			xA = (lB + wA)
		elseif rA >= (rB - 5) and rA <= (rB + 5) then
			xA = (rB - wA)
		end

		-- Set the y sticky position
		yA = bB - (hA - bottom)

		-- Delay the snap
		snap = T
	end

	if snap then
		frameA:ClearAllPoints()
		frameA:SetPoint("CENTER", UIParent, "BOTTOMLEFT", xA, yA)
		return snap
	end
end

--[[---------------------------------------------------------------------------------
	begin addon code
	-------------------------------------------------------------------------------]]

--[[-------------------------------------------------------------------------
	Begin grouping code
	-----------------------------------------------------------------------]]

local function ShouldJoinGroup(frame, group)
	local group = legoGroups[group]
	-- if there is no associated group it means it is a single block
	-- so we should group
	if not group then return true end
	local xF, yF = frame:GetCenter()
	local xG, yG = group:GetCenter()
	return (group:GetHeight() == frame:GetHeight() and yG == yF) or
		(group:GetWidth() == frame:GetWidth() and xG == xF)
end

local function JoinGroup(frame, group)
	local group = legoGroups[group]
	if not group then
		group = GetGroup()
	end
	local gL, gR, gT, gB = group:GetLeft(), group:GetRight(), group:GetTop(), group:GetBottom()
	local fL, fR, fT, fB = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom()
	local farLeft, farRight
end

--[[-------------------------------------------------------------------------
	Begin lego block code
	-----------------------------------------------------------------------]]

-- copied from PerfectRaid, credit goes to cladhaire
local function SavePosition(frame)
	local f = frame
	local optionsTbl = f.optionsTbl
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
	optionsTbl.x, optionsTbl.y, optionsTbl.anchor = xOff*s, yOff*s, anchor
end

-- copied from PerfectRaid, credit goes to cladhaire
local function RestorePosition(frame, x, y, anchor)
	local f = frame
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

local function OnDragStart(frame)
	if InCombatLockdown() then return end -- disable moving in combat
	-- here we do sticky stuff
	StickyFrames:StartMoving(frame, legos, border, border, border, border)
	frame.isMoving = true
end

local function OnDragStop(frame)
	if InCombatLockdown() or not frame.isMoving then return end -- disable moving in combat, if not moving, jump out
	-- here we do sticky stuff
	StickyFrames:StopMoving(frame)
	StickyFrames:AnchorFrame(frame)
	frame:StopMovingOrSizing()
	local group = frame:GetName()
	local xA, yA = frame:GetCenter()
	local sA, hA, wA = frame:GetEffectiveScale(), frame:GetHeight() / 2, frame:GetWidth() / 2
	local xB, yB, sB, hB, wB
	for k,v in pairs(legos) do
		if frame ~= v then
			if StickyFrames:Overlap(frame, v) then
				xB, yB = v:GetCenter()
				sB = v:GetEffectiveScale()
				hB, wB = ((v:GetHeight() * sB) / sA) / 2, ((v:GetWidth() * sB) / sA) / 2
				if (wB == wA and xB == xA) then
					if (frame:ShouldJoinGroup(v.optionsTbl.group)) then
						group = group .. '#' .. v.optionsTbl.group
					end
				elseif (hA == hB and yA == yB) then
					if (frame:ShouldJoinGroup(v.optionsTbl.group)) then
						group = group .. '#' .. v.optionsTbl.group
					end
				end
			end
		end
	end
	frame.optionsTbl.group = group
	frame:SavePosition()
	frame.isMoving = false
end

local function SetText(self, text, noresize)
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

--[[ LegoBlock:New
	name : string : name of the legoblock
	text : string : initial text on the block
	icon : string or texture : path or texture for the icon
	optionsTbl : table : table containing legoblock options, all fields optional
		format :
			[width] = int,
			[height] = int,
			[text] = string,
			[icon] = string,
			[x] = int,
			[y] = int,
			[anchor] = string,
			[showIcon] = boolean,
			[showText] = boolean,
			[group] = string separated by #,
			[appendString] = string,
			[savedFields] = integer indexed table with extra key/value pairs to fill in ]]--

function LegoBlock:New(name,text, icon, optionsTbl)
	local w = optionsTbl.width or minWidth
	local h = optionsTbl.height or 32
	local generationString = "t=Button#n=Lego"..name..'#size='..w..','..h..'#mouse#drag=LeftButton#movable#clamp'..(optionsTbl.appendString or '')
	local frame = DongleFrames:Create(generationString)
	frame.Icon = DongleFrames:Create(frame,"t=Texture#size=24,24", L, 4, 0)
	frame.Text = DongleFrames:Create(frame,"t=FontString#inh=GameFontNormal", L, frame.Icon, R, 0, 0)
	frame.showIcon = optionsTbl.showIcon or false
	frame.showText = optionsTbl.showText or false
	frame:SetBackdrop(bg)
	frame:SetBackdropColor(0,0,0,0.4)
	if (frame.showIcon) then frame.Icon:Show() else frame.Icon:Hide() end
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
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnDragStop", OnDragStop)
	frame.SetText = SetText
	frame.SetManyAttributes = SetManyAttributes
	frame.SavePosition = SavePosition
	frame.RestorePosition = RestorePosition
	if (optionsTbl.savedFields) then
		local savedFields = optionsTbl.savedFields
		for i=1,#savedFields,2 do
			local key,val = savedFields[i], savedFields[i+1]
			if not key then break end
			frame[key] = val
		end
	end
	frame.optionsTbl = optionsTbl
	local x, y, anchor = optionsTbl.x or 0, optionsTbl.y or 0, optionsTbl.anchor or 'CENTER'
	self:RestorePosition(frame, x, y, anchor)
	tinsert(legos, frame)
	return frame
end

-- [[ Misc library related stuff ]]--

local function Activate(new, old)
	new.legos = old and old.legos or {}
	new.legoGroups = old and old.legoGroups or {}
	legos = new.legos
	legoGroups = new.legoGroups
end

function LegoBlock:GetVersion() return major,minor end

DongleStub:Register(LegoBlock, Activate)
