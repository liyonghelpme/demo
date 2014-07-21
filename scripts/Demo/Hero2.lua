--

local DIFY = 40
local DIFX = 40
local ATTACK_RANGE = 70



local function findEnemy(self, enemy)
    local dist = 99999
    local myPos = getPos(self.bg)
    local minEne
    for k, v in ipairs(enemy) do
        local enePos = getPos(v.bg)
        local ed = math.abs(enePos[1]-myPos[1])
        if not v.dead and ed < dist then
            dist = ed
            minEne = v
        end
        coroutine.yield()
    end
    self.minDist = dist
    self.target = minEne
end


--调整bg的scale 方向
local function doMove(self, dir)
    local vs = getVS()
    local frontX = vs.width
    for k, v in ipairs(self.enemy) do
        local p = getPos(v.bg)
        if not v.dead and p[1] < frontX then
            frontX = p[1]
        end
    end
    frontX = frontX-40

    local myPos = getPos(self.bg)
    local mv = dir*self.diff*self.speed
    if dir < 0 then
        setScaleX(self.changeDirNode, -SOL_SCALE)
        local rx = myPos[1]+mv
        --不能越位
        if myPos[1] > 30 and rx <= frontX then
            setPos(self.bg, {myPos[1]+mv, myPos[2]})
        end
    elseif dir > 0 then
        setScaleX(self.changeDirNode, SOL_SCALE)

        local rx = myPos[1]+mv
        if myPos[1] < vs.width-30 and rx <= frontX then
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


local function heroMove(self)
    --等待足够靠近了 
    while true do
        if self.target ~= nil then
            local minDist = math.abs(getPos(self.target.bg)[1]-getPos(self.bg)[1])
            local inTouch = self.scene.inTouch and self.color == 0
            if not inTouch and minDist < self.attackRange  then
                break
            else
                runForWhile(self)
                --[[
                --做小移动
                if self.scene.inTouch == true and self.color == 0 then
                    if self.scene.touchPos[1] < vs.width/2 then
                        doMove(self, -1)
                    else
                        doMove(self, 1)
                    end
                end
                --]]
            end
        end
        coroutine.yield()
    end
end



local function heroAttack(self)
    while true do
        setDir(self)

        self.attackOver = false

        --print("attack again")
        self.changeDirNode:getAnimation():play("attack")
        while true do
            if self.scene.inTouch then
                break
            end
            if self.attackOver then
                --print("soldier attack over")
                break
            end
            coroutine.yield()
        end
        --print("play wait animation")
        
        if self.scene.inTouch then
            self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
            break
        end
            --self.changeDirNode:getAnimation():play("wait")
        self.target:doHarm(self.attack)
        --当用户点击屏幕 则开始移动一下
        
        local minDist = math.abs(getPos(self.target.bg)[1]-getPos(self.bg)[1])
        if self.target.dead or minDist > self.attackRange then
            self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
            break
        end
        if self.color == 0 and self.scene.inTouch then
            --finish = true
            self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
            break
        end
        coroutine.yield()
    end
end


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
            findEnemy(self, enemy)
            heroMove(self)
            heroAttack(self)

            --moveToTarget(self)
            --[[
            if finish then
                finish = false
                print("refind enemy")
                --break
            end
            --]]
        else 
            heroMove(self)
        end

        coroutine.yield()
    end

end


Hero = class()
--color 0 我方 1 敌方
function Hero:ctor(s, col)
    self.color = 0
    self.kind = 0
    self.scene = s

    initSoldier(self)

    --self.attackRange = 70

    --self.name = math.random()

    self.myTeam = self.scene.myTeam
    self.enemy = self.scene.enemyTeam


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

    self.attackProcess = coroutine.create(findTargetAndAttack)
    self.ok = true

    addShadow(self)
    addBlood(self)
    makeHarmable(self)
end

function Hero:update(diff)
    self.diff = diff
    if self.scene.state == 1 and self.ok then
        local res, err = coroutine.resume(self.attackProcess, self)  
        if not res then
            print(err)
        end
        self.ok = res
    end
end

function Hero:onAttackOver()
    self.attackOver = true
end

--[[
function Hero:doHarm()
    local lab = ui.newTTFLabel({text='5', size=30, color={154, 12, 12}})
    setPos(addChild(self.bg, lab), {0, 50})
    lab:runAction(sequence({fadein(0.2), fadeout(0.2), callfunc(nil, removeSelf, lab)}))

    self.health = self.health-5

    Event:sendMsg("HERO_DAMAGE", self)
end
--]]

function Hero:doCure()
    self.health = self.health+5
    Event:sendMsg("HERO_DAMAGE", self)
end

