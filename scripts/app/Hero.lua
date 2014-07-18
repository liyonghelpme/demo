--英雄是不会移动的总是站在场景的中间
local function findTargetAndAttack(self)

end


local Hero = class("Hero", function() return display.newNode() end)
function Hero:ctor(s)
	self.scene = s
	self.name = math.random()
	self.myTeam = self.scene.myTeam
	self.enemy = self.scene.enemyTeam

	local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
	spc:addSpriteFramesWithFile("userRole/userRole.plist")
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("userRole/userRole.json")
	
	self.changeDirNode = CCArmature:create("userRole"):addTo(self)
	self.changeDirNode:scale(SOL_SCALE):anchor(HERO_ANCHOR[1], HERO_ANCHOR[2])

	local aniData = self.changeDirNode:getAnimation()
	registerAniEvent(self, self.changeDirNode)
	self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
	self.changeDirNode:getAnimation():setSpeedScale(0.5)

	--可能存在bug 需要使用registerEnterOrExit 来替换
	--setNodeEventEnabled  true listener
	registerUpdate(self)


	self.target = nil
	self.canAttack = false
	self.passTime = 0
	self.health = 100
	self.totalHealth = 100
	self.dead = false
	self.position = 0
	self.attackProcess = coroutine.create(findTargetAndAttack)
	self.ok = true

end

function Hero:update(diff)
	self.diff = diff
	if self.scene.state == 1 and self.ok then
		local res, err = coroutine.resume(self.attackProcess, self)
		if not res then 
			print(err)
			self.ok = res
		end
	end
end

function Hero:onAniEvent(me, t, s)
	if s == "attack" and (t == 1 or t == 2) then
		self:onAttackOver()
	end
end

function Hero:onAttackOver()
	self.attackOver = true
end


return Hero
