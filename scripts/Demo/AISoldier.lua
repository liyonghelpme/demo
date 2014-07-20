
local DIFY = 40
local DIFX = 70
local attackRange = {
    [1]=50,
    [9]=140,
    [10]=50,
    [11]=50,
    [14]=140,


}

local function adjustYPos(self)
    --print("adjustYPos", self)

    --x 方向最近的 Y 上太靠近的士兵 调整一下我方的 Y值
    --固定值调整 +20
    local minX = 9999
    local minFriend
    local minDy
    local myPos = getPos(self.bg)

    for k, v in ipairs(self.myTeam) do
        if v ~= self and not v.dead then
            local friPos = getPos(v.bg)
            local dist = friPos[1]-myPos[1]
            local dy = friPos[2]-myPos[2]
            --print("dist dy", self.name, dist, dy, self.dir)
            --Y distance < 20
            --如果友方在我的上下范围
            if math.abs(dy) < DIFY and dist * self.dir > 0 and math.abs(dist) <= DIFX then
                if math.abs(dist) < math.abs(minX) then
                    minX = dist
                    minDy = dy
                    minFriend = v
                end
            end
        end
    end

    --获取临近的空闲位置 链表检查
    if minFriend ~= nil then
        --setZord(self)

        --print("adjust Y pos")
        --local sign = getSign(-minDy) 
        --[[
        local sign = 1

        local vs = getVS()
        local mh = vs.height/2
        if myPos[2] >= mh+50 then
            sign = -1
        else
            sign = 1
        end



        local movey = sign*50*self.diff
        local ny = myPos[2]

        if ny >= mh+50 and movey > 0 then
            movey = 0
        end

        if ny <= mh-50 and movey < 0 then
            movey = 0
        end

        setPos(self.bg, {myPos[1], myPos[2]+movey})
        --]]
        local movey = 0

        --距离太小则抵消掉移动X 方向
        if math.abs(minX) < DIFX then
            setPos(self.bg, {myPos[1]-self.moveX, myPos[2]+movey})
        end
    end
end

local function setDir(self)
    local myPos = getPos(self.bg)
    local tarPos = getPos(self.target.bg)
    if tarPos[1] > myPos[1] then
        setScaleX(self.bg, 1)
    else
        setScaleX(self.bg, -1)
    end
end

local function soldierMoveForWhile(self)
    if self.oldTarget ~= self.target then
        self.changeDirNode:getAnimation():play("run", -1, -1, 1)
    end
     
    setDir(self)

    local frameCount = 0
    while frameCount < 10 do
        if self.health < 0 then
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
            adjustYPos(self)
            --adjustXPos(self)
        end
        coroutine.yield()
        frameCount = frameCount+1
    end
end

--self move and attack
local function soldierTryAttack(self)
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
            setDir(self)

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
            if self.target.dead then
                self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
                break
            end
            
            local minDist = math.abs(getPos(self.target.bg)[1]-getPos(self.bg)[1])
            if minDist > self.attackRange then
                self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
                break
            end
            coroutine.yield()
        end
    end
end


local function handleDead(self)
    if self.dead then
        return
    end

    if self.health <= 0 then
        self.dead = true
        self.changeDirNode:getAnimation():play("death", -1, -1, 0)
    end
end



local function findEnemy(self)
    self.oldTarget = self.target

    local dist = 99999
    local myPos = getPos(self.bg)
    local minEne
    for k, v in ipairs(self.enemy) do
        local enePos = getPos(v.bg)
        local ed = math.abs(enePos[1]-myPos[1])
        if ed < dist and not v.dead then
            dist = ed
            minEne = v
        end
        coroutine.yield()
    end
    self.target = minEne
end

local function moveToTarget(self)
    self.changeDirNode:getAnimation():play("run", -1, -1, 1)
    while true do
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
            adjustYPos(self)
            --adjustXPos(self)
        end
        coroutine.yield()
    end
end


local function doAttack(self)
    while true do
        if self.health <= 0 then
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
        self.target:doHarm()
        coroutine.yield()
    end
end

local function findMoveAttack(self)
    setZord(self)
    while true do
        handleDead(self)
        if self.dead then
            break
        end
        findEnemy(self)
        --moveToTarget(self)
        --doAttack(self)

        soldierMoveForWhile(self)
        soldierTryAttack(self)
        
        coroutine.yield()
    end
end

--自动调整 位置和方向
AISoldier = class()
function AISoldier:ctor(s, hid)
    self.scene = s
    self.kind = hid
    self.name = math.random()
    self.health = 100
    self.attack = 5
    self.attackRange = attackRange[self.kind] or 70

    self.enemy = self.scene.myTeam
    self.myTeam = self.scene.enemyTeam

    self.bg = CCNode:create()

    self.blood = createSprite("blood.png")
    setAnchor(setScale(setPos(addChild(self.bg, self.blood), {-40, 80}), 0.5), {0, 0.5})

    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    local st = string.format("enemy_%d/enemy_%d.plist", hid, hid)
    spc:addSpriteFramesWithFile(st)
    local st = string.format("enemy_%d/enemy_%d.json", hid, hid)

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(st)
    self.changeDirNode = CCArmature:create("enemy_"..hid)
    addChild(self.bg, self.changeDirNode)
    setScale(self.changeDirNode, 0.5)
    self.changeDirNode:getAnimation():setSpeedScale(0.25)
    setScaleX(self.bg, -1)

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

    self.attackProcess = coroutine.create(findMoveAttack)
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


function AISoldier:doHarm(att)
    local attack = att or 5

    local lab = ui.newTTFLabel({text='-5', size=30, color={154, 12, 12}})
    setPos(addChild(self.bg, lab), {0, 50})
    lab:runAction(sequence({fadein(0.2), fadeout(0.2), callfunc(nil, removeSelf, lab)}))

    self.health = self.health-attack
    
    local rate = self.health/100
    rate = math.min(math.max(rate, 0), 1)
    self.blood:setTextureRect(CCRectMake(0, 0, 128*rate, 24))

    
    --[[
    if self.health <= 0 then
        self.dead = true
    end
    --]]
    
    --Event:sendMsg("HERO_DAMAGE", self)
end
