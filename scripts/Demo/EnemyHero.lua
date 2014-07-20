
local DIFY = 40
local DIFX = 40
local ATTACK_RANGE = 70

local function adjustYPos(self)
    --print("adjustYPos", self)

    --x 方向最近的 Y 上太靠近的士兵 调整一下我方的 Y值
    --固定值调整 +20
    local minX = 9999
    local minFriend
    local minDy
    local myPos = getPos(self.bg)

    for k, v in ipairs(self.myTeam) do
        if v ~= self then
            local friPos = getPos(v.bg)
            local dist = friPos[1]-myPos[1]
            local dy = friPos[2]-myPos[2]
            print("dist dy", self.name, dist, dy, self.dir)
            --Y distance < 20
            if math.abs(dy) < DIFY and dist * self.dir > 0 then
                if math.abs(dist) < math.abs(minX) then
                    minX = dist
                    minDy = dy
                    minFriend = v
                end
            end
        end
    end

    if minFriend ~= nil then
        setZord(self)
        print("adjust Y pos")
        local sign = getSign(-minDy) 
        if sign == 0 then
            sign = 1
        end
        local movey = sign*50*self.diff
        setPos(self.bg, {myPos[1], myPos[2]+movey})
        --距离太小则抵消掉移动X 方向
        if math.abs(minX) < DIFX then
            setPos(self.bg, {myPos[1]-self.moveX, myPos[2]+movey})
        end
    end
end

local function findEnemy(self, enemy)
    local dist = 99999
    local myPos = getPos(self.bg)
    local minEne
    self.oldTarget = self.target
    for k, v in ipairs(enemy) do
        local enePos = getPos(v.bg)
        local ed = math.abs(enePos[1]-myPos[1])
        if ed < dist and not v.dead then
            dist = ed
            minEne = v
        end
        coroutine.yield()
    end
    self.minDist = dist
    self.target = minEne
end

local function moveToTarget(self)
    self.changeDirNode:getAnimation():play("run", -1, -1, 1)
    while true do
        --print("start Move")
        local myPos = getPos(self.bg)
        local enePos = getPos(self.target.bg)
        local dir = enePos[1]-myPos[1]
        self.dir = getSign(dir)

        local dist = math.abs(dir)
        local sign = getSign(dir) 
        if dist < ATTACK_RANGE then
            break
        else
            --after move then adjust Y pos
            local mv = self.diff*100*sign
            self.moveX = mv
            setPos(self.bg, {myPos[1]+mv, myPos[2]})
            --print('start adjust')
            --bug: lua
            --当local 函数声明在 这个函数 之后的时候 无法调用 adjustPos 这个函数
            adjustYPos(self)
            --adjustXPos(self)
        end
        coroutine.yield()
    end
end

local function moveForWhile(self)
    if self.oldTarget ~= self.target then
        self.changeDirNode:getAnimation():play("run", -1, -1, 1)
    end
     
    local frameCount = 0
    while frameCount < 10 do
        if self.health <= 0 then
            break
        end
        --print("start Move")
        local myPos = getPos(self.bg)
        local enePos = getPos(self.target.bg)
        local dir = enePos[1]-myPos[1]
        self.dir = getSign(dir)

        local dist = math.abs(dir)
        local sign = getSign(dir) 
        if dist < self.attackRange then
            break
        else
            --after move then adjust Y pos
            local mv = self.diff*MOVE_SPEED*sign
            self.moveX = mv
            setPos(self.bg, {myPos[1]+mv, myPos[2]})
            --print('start adjust')
            --bug: lua
            --当local 函数声明在 这个函数 之后的时候 无法调用 adjustPos 这个函数
            --adjustYPos(self)
            --adjustXPos(self)
        end
        coroutine.yield()
        frameCount = frameCount+1
    end
end

local function tryToAttack(self)
    local myPos = getPos(self.bg)
    local enePos = getPos(self.target.bg)
    local dist = enePos[1]-myPos[1]
    if math.abs(dist) < self.attackRange then
        while true do
            if self.health <= 0 then
                break
            end

            if self.target.dead then
                break
            end

            self.attackOver = false
            --print("attack again")
            self.changeDirNode:getAnimation():play("attack")
            while true do
                if self.attackOver then
                    --print("soldier attack over")
                    break
                end
                coroutine.yield()
            end
            --print("play wait animation")
            
            --self.changeDirNode:getAnimation():play("wait")
            self.target:doHarm(self.attack)
            --当用户点击屏幕 则开始移动一下
            
            local minDist = math.abs(getPos(self.target.bg)[1]-getPos(self.bg)[1])
            if minDist > self.attackRange then
                self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
                break
            end
            coroutine.yield()
        end
    end
end



local function doMove(self, dir)
    local vs = getVS()

    local myPos = getPos(self.bg)
    local mv = dir*self.diff*100
    if dir < 0 then
        setScaleX(self.bg, -1)
        if myPos[1] > 30 then
            setPos(self.bg, {myPos[1]+mv, myPos[2]})
        end
    elseif dir > 0 then
        setScaleX(self.bg, 1)
        if myPos[1] < vs.width-30 then
            setPos(self.bg, {myPos[1]+mv, myPos[2]})
        end
    end
end

local function runForWhile(self)
    local vs = getVS()
    if self.scene.inTouch == true and self.color == 0 then
        self.changeDirNode:getAnimation():play("run", -1, -1, 1)
    end

    self.inMove = false
    while true do
        if self.scene.inTouch == true and self.color == 0 then
            self.inMove = true
            local pos = getPos(self.bg)
            local ds = self.scene.touchPos[1] - pos[1]
            if math.abs(ds) > 5 then
                if self.scene.touchPos[1] < pos[1] then
                    doMove(self, -1)
                else
                    doMove(self, 1)
                end
            else
                break
            end
        else
            break
        end
        coroutine.yield()
    end
    
    if self.inMove then
        self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
    end
    self.inMove = false
end

local function handleDead(self)
    if self.dead then
        return
    end

    if self.health <= 0 then
        self.dead = true
        self.changeDirNode:getAnimation():play("death")
    end
end

--发现我方士兵 逐渐移动靠近 
--再发现 如果足够靠近了则攻击
local function findTargetAndAttack(self)
    local vs = getVS()

    setZord(self)
    print("getZord hero", self.bg:getZOrder())

    local enemy 
    if self.color == 0 then
        enemy = self.scene.enemyTeam
    else
        enemy = self.scene.myTeam
    end
    while true do
        --local finish = false
        if #enemy > 0 then
            handleDead(self)
            if self.dead then
                Event:sendMsg("HERO_DEAD", self)
                break
            end

            findEnemy(self, enemy)
            moveForWhile(self)
            tryToAttack(self)
        end

        coroutine.yield()
    end

end


EnemyHero = class()
--color 0 我方 1 敌方
function EnemyHero:ctor(s, col)
    self.color = 1
    self.scene = s
    self.attackRange = 70
    self.attack = 20

    self.name = math.random()

    if self.color == 0 then
        self.myTeam = self.scene.myTeam
    else
        self.myTeam = self.scene.enemyTeam
    end

    self.bg = CCNode:create()

    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    if col == 0 then
        spc:addSpriteFramesWithFile("userRole/userRole.plist")
        CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("userRole/userRole.json")

        self.changeDirNode = CCArmature:create("userRole")
        setScale(self.changeDirNode, 0.5)
    else
        spc:addSpriteFramesWithFile("enemy_1/enemy_1.plist")
        CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("enemy_1/enemy_1.json")
        self.changeDirNode = CCArmature:create("enemy_1")
        setScaleY(self.changeDirNode, 0.5)
        setScaleX(self.changeDirNode, -0.5)
    end
    setAnchor(addChild(self.bg, self.changeDirNode), {0.5, 0})

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
    self.health = 100
    self.totalHealth = 100

    self.attackProcess = coroutine.create(findTargetAndAttack)
    self.ok = true

end

function EnemyHero:update(diff)
    self.diff = diff
    if self.scene.state == 1 and self.ok then
        local res, err = coroutine.resume(self.attackProcess, self)  
        if not res then
            print(err)
        end
        self.ok = res
    end
end

function EnemyHero:onAttackOver()
    self.attackOver = true
end

function EnemyHero:doHarm()
    local lab = ui.newTTFLabel({text='5', size=30, color={154, 12, 12}})
    setPos(addChild(self.bg, lab), {0, 50})
    lab:runAction(sequence({fadein(0.2), fadeout(0.2), callfunc(nil, removeSelf, lab)}))

    self.health = self.health-5

    Event:sendMsg("HERO_DAMAGE", self)
end

function EnemyHero:doCure()
end

