

--扩充一个 超级Scene 类 方法
--可以使用 这种 类似于 actionscript 的 链表达式
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)


local MainLayer = require "app.scenes.MainLayer"
local MainUI = require "app.MainUI"

function MainScene:ctor()
    --[[
    ui.newTTFLabel({text = "Hello, World", size = 64, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx, display.cy)
        :addTo(self)
	--]]

    --registerUpdate(self)
    local layer = MainLayer.new(self)
    layer:addTo(self)
    self.layer = layer

    local uiLayer = MainUI.new(self)
    uiLayer:addTo(self)
    
end

function MainScene:update(diff)
end


function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
