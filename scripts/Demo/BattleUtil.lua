function addShadow(self)
    local shadow = display.newSprite("shadow.png"):anchor(0.5, 0.5)
    self.bg:addChild(shadow)
    shadow:setZOrder(-1)
    shadow:setScale(SHADOW_SCALE)

    --[[
    local name = ui.newTTFLabel({text=self.name, size=20, color=ccc3(0, 255, 0)})
    self.bg:addChild(name)
    name:pos(0, 50)
    --]]
end

function setDir(self)
    local myPos = getPos(self.bg)
    local tarPos = getPos(self.target.bg)
    if tarPos[1] > myPos[1] then
        setScaleX(self.changeDirNode, SOL_SCALE)
    else
        setScaleX(self.changeDirNode, -SOL_SCALE)
    end
end

function initSoldier(self)
    self.attackRange = 70
    
    self.attack = 20
    self.health = 100
    self.totalHealth = 100
    self.dead = false
    self.name = math.random(1, 1000)
    if self.color == 0 then
        self.speed = MyMoveSpeed[self.kind]
        self.attackRange = MyAttackRange[self.kind]
        self.attack = MyAttack[self.kind]
        
        self.health = MyHealth[self.kind]
        self.totalHealth = self.health

        self.myTeam = self.scene.myTeam
        self.enemy = self.scene.enemyTeam

        self.attackSpeed = MyAttackSpeed[self.kind]
    else
        self.speed = EnemyMoveSpeed[self.kind]
        self.attackRange = EnemyAttackRange[self.kind]
        self.attack = EnemyAttack[self.kind]
         
        self.health = EnemyHealth[self.kind]
        self.totalHealth = self.health
        
        self.myTeam = self.scene.enemyTeam
        self.enemy = self.scene.myTeam
        
        self.attackSpeed = EnemyAttackSpeed[self.kind]
    end
end

function addBlood(self)
    self.blood = createSprite("blood.png")
    setAnchor(setScale(setPos(addChild(self.bg, self.blood), {-40, 100}), 0.5), {0, 0.5})
end


local function floatText(self, damage)
    local lab = ui.newTTFLabel({text="-"..damage, size=30, color=ccc3(154, 12, 12)})
    print("labe is", lab)
    lab:addTo(self.bg):pos(-20, 50):anchor(0.5, 0.5)

    --local lab = ui.newTTFLabel({text='-5', size=30, color={154, 12, 12}})
    --setPos(addChild(self.bg, lab), {0, 50})
    lab:runAction(createSequence({CCFadeIn:create(0.2), CCFadeOut:create(0.5), callfunc(nil, removeSelf, lab)}))
    lab:runAction(createSequence({CCScaleTo:create(0.2, 2), CCScaleTo:create(0.2, 1) }) )
end


--为对象添加受伤处理函数
local function updateBlood(self)
    local rate = self.health/self.totalHealth
    print("self.health, self.totalHealth", self.health, self.totalHealth)
    rate = math.min(math.max(rate, 0), 1)
    self.blood:setTextureRect(CCRectMake(0, 0, 128*rate, 24))
end

local function defaultDoHarm(self, damage)
    --local damage = 50
    if damage == nil then
        damage = 50
    end
    
    self.health = self.health-damage
    updateBlood(self)
    floatText(self, damage)
end

function makeHarmable(obj)
    obj.doHarm = defaultDoHarm
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
            local mv = self.diff*self.speed*sign
            self.moveX = mv
            local rx = myPos[1]+mv
            local frontX = 0
            for k, v in ipairs(self.enemy) do
                if not v.dead then
                    local pos = getPos(v.bg)
                    if self.color == 0 and pos[1] > frontX then
                        frontX = pos[1]
                    elseif self.color == 1 and pos[1] < frontX then
                        frontX = pos[1]
                    end
                end
            end
            if self.color == 0 then
                frontX = frontX - 40
            else
                frontX = frontX + 40
            end

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
            local oldScale = self.changeDirNode:getAnimation():getSpeedScale()

            self.changeDirNode:getAnimation():setSpeedScale(self.attackSpeed)
            
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
            self.changeDirNode:getAnimation():setSpeedScale(oldScale)

            local minDist = math.abs(getPos(self.target.bg)[1]-getPos(self.bg)[1])
            if self.target.dead or minDist > self.attackRange then
                self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
                self.oldTarget = nil
                self.target = nil
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
        self.changeDirNode:getAnimation():play("death")
    end
end

--发现我方士兵 逐渐移动靠近 
--再发现 如果足够靠近了则攻击
local function findTargetAndAttack(self)
    local vs = getVS()

    setZord(self)
    print("getZord hero", self.bg:getZOrder())

    local enemy = self.enemy
    while true do
        --local finish = false
        if #enemy > 0 then
            handleDead(self)
            if self.dead then
                --Event:sendMsg("HERO_DEAD", self)
                break
            end

            findEnemy(self, enemy)
            moveForWhile(self)
            tryToAttack(self)
        end

        coroutine.yield()
    end

end


function makeAttackable(obj)
    obj.attackProcess = coroutine.create(findTargetAndAttack)
end


