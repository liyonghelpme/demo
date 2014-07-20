local Soldier = require("app.Soldier")

local MainUI = class("MainUI", function()
	return display.newLayer()
end)

--卡片的接口
--继承外部的card结构添加一个 renderTarget
--可以根据外部的自己的计时 来更新自身的 结构
--注册有自己的update函数

--3个card 分别拥有独立的 tempNode 


--显示3个 卡片
local function makeCard(cardWidget, layer, cardId)

	local card = {}
	card.id = cardId
	card.layer = layer

	card.bg = cardWidget:clone()
	card.bg:setVisible(true)
	card.curTime = 0
	card.totalTime = 3
	card.bg.update = function(self, diff)
		card.curTime = card.curTime+diff
		--更新tempNode接着在
		card.tempNode:setVisible(true)
		--card.m2:setVisible(false)
		local leftTime = math.min(card.curTime/card.totalTime, 1)
		card.halfCircle:rotation(-leftTime*180)


		card.rt:beginWithClear(0, 0, 0, 0)
		card.tempNode:visit()
		card.rt:endToLua()
		card.tempNode:setVisible(false)


	end
	card.needUpdate = true
	--registerEnterOrExit(card)
	registerUpdate(card.bg)


	local function onTouch(obj, event)
		print(obj, event)

		if event == TOUCH_EVENT_ENDED then
			card.layer:onBut(card)
		end
	end



	local button = UIHelper:seekWidgetByName(card.bg, "button")
	button:addTouchEventListener(onTouch)

	local mask = UIHelper:seekWidgetByName(card.bg, "mask")

	mask:setVisible(false)

	local sz = mask:getSize()

	local tempNode = display.newNode()
	card.tempNode = tempNode
	card.bg:addNode(tempNode)
	tempNode:setPosition(ccp(sz.width/2, 0))

	tempNode:setVisible(false)
	

	local halfCircle = display.newSprite("halfCircle.png")
	halfCircle:addTo(tempNode):pos(0, 0):anchor(0.5, 0)
	--halfCircle:setRotation(-45)
	
	card.halfCircle = halfCircle


	local sp = tolua.cast(mask:getVirtualRenderer(), "CCSprite")
	local m2 = display.newSprite(sp:getTexture())
	m2:addTo(tempNode):pos(0, 0):anchor(0.5, 0)
	card.m2 = m2
	

	local bf = ccBlendFunc()
	bf.src = GL_DST_COLOR
	bf.dst = GL_ZERO
	--halfCircle:setBlendFunc(bf)
	m2:setBlendFunc(bf)

	--静态分配资源 如何在多个card上面共享使用
	local rt = CCRenderTexture:create(sz.width, sz.height)
	card.rt = rt
	
	--利用中间图层来渲染
	local button = UIHelper:seekWidgetByName(card.bg, "cardBack")
	button:addNode(rt)

	rt:setZOrder(10)
	rt:setClearColor(ccc4f(0, 0, 0, 0))
	--rt 是一个node 其中有一个sprite 子节点
	rt:setPosition(ccp(0, 0))
	--rt:setAnchorPoint(ccp(0.5, 0))

	--cardNode   card MaskNode 
	--tempNode  mask  halfCircle  0.5 0 为基准点  正常情况下面invisible 的
	--renderTexture

	return card
end

--点击到特定item上面
function MainUI:onBut(card)
	local p = card.id
	print("card info", p, card.curTime, card.totalTime, #self.myteamList)
	if card.curTime >= card.totalTime and #self.myteamList >= p then
		local hid = self.myteamList[p]
		local body 
		local freePos = 1
		print("myteam", #self.scene.layer.myTeam)
		
		for i=1, 4, 1 do
			local ok = true
			for k, v in ipairs(self.scene.layer.myTeam) do
				print()
				if not v.dead and v.position == i then
					ok = false
					break
				end
			end
			if ok then 
				freePos = i
				break
			else
				freePos = nil
			end
		end
		if freePos == nil then
			return
		end
		--当有空闲位置的时候 才上新的士兵
		table.remove(self.myteamList, p)
		local body = Soldier.new(self.scene.layer, hid, 0, freePos)
		body:addTo(self.scene.layer.solLayer)

		local pos = {
			{109, 240-50},
			{109, 240+50},
			{290, 240-50},
			{290, 240+50},

		}
		body:pos(pos[freePos][1], pos[freePos][2])
		card.curTime = 0
		--bug 为什么removeFromParent 没有作用呢?
		self.cardParent:removeChild(card.bg)

		--card.bg:removeFromParentAndCleanup(true)
		
		for i=p+1, #self.allBtns, 1 do
			local it = self.allBtns[i]
			it.bg:runAction(
				createSequence({CCMoveBy:create(0.7, ccp(-self.offX, 0))})
			)
			it.id = it.id-1
		end
		local tempBtn = {}
		for i=1, p-1, 1 do
			table.insert(tempBtn, self.allBtns[i])
		end
		for i=p+1, #self.allBtns, 1 do
			table.insert(tempBtn, self.allBtns[i])
		end
		self.allBtns = tempBtn
		print("myTeamLength", json.encode(self.myteamList))
		if #self.myteamList > #self.allBtns then
			local it = makeCard(self.cardTemplate, self, 3)
			it.bg:setPosition(ccp(30+self.offX*2, 23))
			self.cardParent:addChild(it.bg)
			table.insert(self.allBtns, it)
		end

		table.insert(self.scene.layer.myTeam, body)
	end
end

function MainUI:ctor(sc)
	self.scene = sc
	local touchGroup = TouchGroup:create()
	self:addChild(touchGroup)

	local w = GUIReader:shareReader():widgetFromJsonFile("ui/mainMenu.json")
	touchGroup:addWidget(w)
	local lay = tolua.cast(w, "Layout")
	lay:setBackGroundColorOpacity(0)
	self.myteamList = {1, 2, 3, 4, 5, 6, 7}


	print("start MainUI")

	local card = UIHelper:seekWidgetByName(w, "card")
	self.cardTemplate = card
	card:setVisible(false)

	local par = card:getParent()
	self.cardParent = par

	local offX = 125
	self.offX = offX

	local c1 = makeCard(card, self, 1)
	c1.bg:setPosition(ccp(30, 23))
	par:addChild(c1.bg)

	--115
	local c2 = makeCard(card, self, 2)
	c2.bg:setPosition(ccp(30+offX, 23))
	par:addChild(c2.bg)

	local c3 = makeCard(card, self, 3)
	c3.bg:setPosition(ccp(30+offX*2, 23))
	par:addChild(c3.bg)

	self.allBtns = {c1, c2, c3}



	--[[

	local mask = UIHelper:seekWidgetByName(card, "mask")
	local sz = mask:getSize()
	self.maskSz = sz

	print("mask size", sz.width, sz.height)
	--]]		
	

	

	--[[
	local tempNode = display.newNode()
	tempNode:addTo(self)
	tempNode:pos(200, 200)
	self.tempNode = tempNode
	

	local halfCircle = display.newSprite("halfCircle.png")
	halfCircle:addTo(tempNode):pos(0, 0):anchor(0.5, 0)
	self.halfCircle = halfCircle
	--halfCircle:runAction(CCRepeatForever:create(CCRotateBy:create(1, 360)))
	halfCircle:setRotation(45)
	--]]
	
	--local c2 = card:clone() 
	--c2:addTo(tempNode)
	--[[
	local m2 = mask:clone()
	m2:addTo(tempNode)
	m2:setPosition(ccp(0, 0))
	m2:anchor(0.5, 0)
	--]]

	--[[
	local sp = tolua.cast(mask:getVirtualRenderer(), "CCSprite")
	local m2 = display.newSprite(sp:getTexture())
	m2:addTo(tempNode):pos(0, 0):anchor(0.5, 0)
	
	--根据目标点的颜色 如果是1 则保留否则去除颜色
	local bf = ccBlendFunc()
	bf.src = GL_DST_COLOR
	bf.dst = GL_ZERO
	--halfCircle:setBlendFunc(bf)
	m2:setBlendFunc(bf)
	--]]
	
	
	--halfCircle:setBlendFunc(bf)



	--[[
	local rt = CCRenderTexture:create(sz.width, sz.height)
	--rt:addTo(self):pos(350, 350)
	self:addChild(rt)
	rt:setPosition(ccp(350, 350))

	self.rt = rt
	self.rt:setZOrder(10)
	self.rt:setClearColor(ccc4f(0, 0, 0, 0))


	registerUpdate(self)
	--]]
end

function MainUI:update(diff)
	--print("update", diff)

	--[[
	self.tempNode:setPosition(ccp(self.maskSz.width/2, 0))
	self.rt:beginWithClear(0, 0, 0, 0)
	self.tempNode:visit()
	self.rt:endToLua()

	self.tempNode:setPosition(ccp(200, 200))
	--]]

end


return MainUI