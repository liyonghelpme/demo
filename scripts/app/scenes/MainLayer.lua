local MainLayer = class("MainLayer", function ()
	return display.newLayer()
end)

function MainLayer:ctor(sc)
	self.scene = sc
	
	registerUpdate(self)
end
function MainLayer:update(diff)
end




return MainLayer