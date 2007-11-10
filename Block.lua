

------------------------------
--      Are you local?      --
------------------------------

local db, moving


--------------------------
--      Main Frame      --
--------------------------

local frame = CreateFrame("Button", "ControlFreakFrame", UIParent, "SecureActionButtonTemplate")
frame:SetHeight(24)

frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)

frame:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	insets = {left = 5, right = 5, top = 5, bottom = 5},
	tile = true, tileSize = 16,
})
frame:SetBackdropColor(0.09, 0.09, 0.19, 0.5)
frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)

frame:SetScript("OnDragStart", function(frame)
	if InCombatLockdown() or db.locked then return end
	frame:StartMoving()
end)

frame:SetScript("OnDragStop", function(frame)
	frame:StopMovingOrSizing()
	db.x, db.y = frame:GetCenter()
end)


function frame:SetDB(newdb)
	db = newdb
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, db.x and "BOTTOMLEFT" or "CENTER", db.x or 0, db.y or -100)
end


--------------------
--      Text      --
--------------------

local text = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
text:SetPoint("CENTER")


function frame:SetText(...)
	text:SetText(...)
end


function frame:Resize()
	frame:SetWidth(text:GetStringWidth() + 8)
end

