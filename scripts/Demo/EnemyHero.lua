
local DIFY = 40
local DIFX = 40
local ATTACK_RANGE = 70





EnemyHero = class()
--color 0 我方 1 敌方
function EnemyHero:ctor(s, col)
    self.color = 1
    self.kind = 1
    self.scene = s

    initSoldier(self)

    --self.attackRange = 70
    --self.attack = 20

    --self.name = math.random()

    self.myTeam = self.scene.enemyTeam
    self.enemy = self.scene.myTeam

    --[[
    if self.color == 0 then
        self.myTeam = self.scene.myTeam
    else
       
    end
    --]]

    self.bg = CCNode:create()

    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    if col == 0 then
        spc:addSpriteFramesWithFile("userRole/userRole.plist")
        CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("userRole/userRole.json")

        self.changeDirNode = CCArmature:create("userRole")
        setScale(self.changeDirNode, SOL_SCALE)
    else
        spc:addSpriteFramesWithFile("enemy_1/enemy_1.plist")
        CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("enemy_1/enemy_1.json")
        self.changeDirNode = CCArmature:create("enemy_1")
        setScaleY(self.changeDirNode, SOL_SCALE)
        setScaleX(self.changeDirNode, -SOL_SCALE)
    end
    setAnchor(addChild(self.bg, self.changeDirNode), HERO_ANCHOR)

    local aniData = self.changeDirNode:getAnimation()
    print("aniData", aniData)
    print("movementCount", aniData:getMovementCount())


    local function moveEvent(me, t, s)
        --print('moveevent', me, t, s)
        --0 start
        --1 complete
        --2 loop complete
        if (t == 1 or t == 2) and s == 'attack' then
            self:onAttackOver()
        end
    end

    self.changeDirNode:getAnimation():setMovementEventCallFunc(moveEvent)
    --self.changeDirNode:getAnimation():setFrameEventCallFunc(frameEvent)

    --self.changeDirNode:getAnimation():play("wait")
    self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
    self.changeDirNode:getAnimation():setSpeedScale(0.5)



    self.target = nil

    self.needUpdate = true
    registerEnterOrExit(self)

    --self.state =  ACTOR_STATE.WAIT
    self.passTime = 0
    --self.health = 100
    --self.totalHealth = 100

    --self.attackProcess = coroutine.create(findTargetAndAttack)
    self.ok = true

    makeAttackable(self)
    addShadow(self)
    addBlood(self)
    makeHarmable(self)
end

function EnemyHero:update(diff)
    self.diff = diff
    if self.scene.state == 1 and self.ok then
        local res, err = coroutine.resume(self.attackProcess, self)  
        if not res then
            print(err)
            print(debug.traceback())
        end
        self.ok = res
    end
end

function EnemyHero:onAttackOver()
    self.attackOver = true
end

--[[
function EnemyHero:doHarm()
    local lab = ui.newTTFLabel({text='5', size=30, color={154, 12, 12}})
    setPos(addChild(self.bg, lab), {0, 50})
    lab:runAction(sequence({fadein(0.2), fadeout(0.2), callfunc(nil, removeSelf, lab)}))

    self.health = self.health-5

    Event:sendMsg("HERO_DAMAGE", self)
end
--]]

function EnemyHero:doCure()
end

