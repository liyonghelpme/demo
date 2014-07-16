local MainUI = class("MainUI", function()
	return display.newLayer()
end)

function MainUI:ctor(sc)
	self.scene = sc
	local touchGroup = TouchGroup:create()
	self:addChild(touchGroup)

	local w = GUIReader:shareReader():widgetFromJsonFile("ui/mainMenu.json")
	touchGroup:addWidget(w)

	print("start MainUI")

end


return MainUI