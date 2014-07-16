function registerUpdate(obj)
	local function update(diff)
		obj:update(diff)
	end
	obj:scheduleUpdate(update)
end
