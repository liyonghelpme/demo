

local AIHero = class("AIHero", function() return display.newNode() end)
function AIHero:ctor(s, col)
	self.color = 1
	self.scene = s
	self.attackRange = 70
	self.attack = 20
	self.position = 0
	self.name = math.random()
	self.health = 100
    self.totalHealth = 100


	self.myTeam = self.scene.enemyTeam
    self.enemy = self.scene.myTeam

    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    spc:addSpriteFramesWithFile("enemy_1/enemy_1.plist")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("enemy_1/enemy_1.json")
    self.changeDirNode = CCArmature:create("enemy_1")
    self.changeDirNode:setScaleX(-SOL_SCALE)
    self.changeDirNode:setScaleY(SOL_SCALE)
    self.changeDirNode:anchor(0.5, 0):addTo(self)

    local aniData = self.changeDirNode:getAnimation()
    registerAniEvent(self, self.changeDirNode)

    self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
    self.changeDirNode:getAnimation():setSpeedScale(0.5)

    self.canAttack = false
    self.target = nil

    registerUpdate(self)
    --self.attackProcess = coroutine.create(findTargetAndAttack)
    
    
    self.ok = true

    setAttackProcess(self)
    addShadow(self)
    addBlood(self)
    --如果传入一个函数 则使用自己的函数替换默认的行为
    makeHarmable(self)
    makeAttackable(self)
    makeDead(self)
end

function AIHero:onAniEvent(me, t, s)
	if (t == 1 or t == 2) and s == 'attack' then
        self:onAttackOver()
    end
end

function AIHero:update(diff)
	self.diff = diff
    if self.scene.state == 1 and self.ok then
        local res, err = coroutine.resume(self.attackProcess, self)  
        if not res then
            print(err)
        	self.ok = res
        end
    end
end


function AIHero:onAttackOver()
	self.attackOver = true
end



return AIHero