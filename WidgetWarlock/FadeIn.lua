
local lib = LibStub("WidgetWarlock-Alpha1", true)
if not lib.upgrading or lib.upgrading >= 1 then return end



lib.fadetimes = setmetatable({}, {__index = function() return 1 end})
lib.elapsed = setmetatable({}, {__index = function() return 0 end})
lib.OnUpdates = {}

do
	local fadetimes, elapsed = lib.fadetimes, lib.elapsed
	function lib.OnUpdate(frame, elap)
		elapsed[frame] = elapsed[frame] + elap
		if elapsed[frame] > fadetimes[frame] then
			frame:SetScript("OnUpdate", lib.OnUpdates[frame])
			frame:SetAlpha(1)
		else frame:SetAlpha(elapsed[frame]/fadetimes[frame]) end
	end
end


-- Fade a frame in
-- Note that this will overwrite the frame's OnUpdate while fading
-- Also note this function does not take a self (don't call it with a colon).
-- This allows you to set it directly as your frame's OnShow handler if you wish.
function lib.FadeIn(frame, time)
	frame = frame or self
	assert(frame, "No frame passed")
	assert(type(time) == "number" or type(time) == "nil", "Time must be a number or nil")
	assert(time == nil or time > 0, "Time must be positive")

	lib.fadetimes[frame] = time
	lib.OnUpdates[frame] = frame:GetScript("OnUpdate")
	lib.elapsed[frame] = 0
	frame:SetAlpha(0)
	frame:SetScript("OnUpdate", lib.OnUpdate)
end

