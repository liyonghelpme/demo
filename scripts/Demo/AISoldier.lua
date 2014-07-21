
--自动调整 位置和方向
AISoldier = class()
function AISoldier:ctor(s, hid)
    self.scene = s
    self.color = 1
    self.kind = hid
    --[[
    self.name = math.random()
    self.health = 100
    self.attack = 5
    --]]
    initSoldier(self)
    --self.attackRange = EnemyAttackRange[self.kind]
    --self.attack = EnemyAttack[self.kind]
    
    --self.attackRange = attackRange[self.kind] or 70

    self.enemy = self.scene.myTeam
    self.myTeam = self.scene.enemyTeam

    self.bg = CCNode:create()

    

    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    local st = string.format("enemy_%d/enemy_%d.plist", hid, hid)
    spc:addSpriteFramesWithFile(st)
    local st = string.format("enemy_%d/enemy_%d.json", hid, hid)

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(st)
    self.changeDirNode = CCArmature:create("enemy_"..hid)
    addChild(self.bg, self.changeDirNode)
    setScaleX(self.changeDirNode, -SOL_SCALE)
    setScaleY(self.changeDirNode, SOL_SCALE)
    self.changeDirNode:getAnimation():setSpeedScale(0.25)
    --setScaleX(self.bg, -1)

    
    
    local function moveEvent(me, t, s)
        --print('moveevent', me, t, s)
        --0 start
        --1 complete
        --2 loop complete
        if (t == 1 or t == 2) and s == 'attack' then
            self:onAttackOver()
        end
    end

    self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
    self.changeDirNode:getAnimation():setMovementEventCallFunc(moveEvent)

    self.needUpdate = true
    self.state = 0
    registerEnterOrExit(self)
    
    self.ok = true

    --self.attackProcess = coroutine.create(findMoveAttack)

    makeAttackable(self)
    addShadow(self)
    addBlood(self)
    makeHarmable(self)
end

function AISoldier:update(diff)
    self.diff = diff
    if self.scene.state == 1 and self.ok then
        local res, err = coroutine.resume(self.attackProcess, self)
        if not res then
            print(err)
        end
        self.ok = res
    end
end

function AISoldier:onAttackOver()
    self.attackOver = true
end

