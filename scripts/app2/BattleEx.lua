--为对象添加受伤处理函数
local function updateBlood(self)
    local rate = self.health/self.totalHealth
    rate = math.min(math.max(rate, 0), 1)
    self.blood:setTextureRect(CCRectMake(0, 0, 128*rate, 24))
end

function addBlood(obj)
    obj.blood = display.newSprite("blood.png"):addTo(obj):pos(0, 80):scale(0.5)
end

local function floatText(self, damage)
    local lab = ui.newTTFLabelWithShadow({text="-"..damage, size=30, color=ccc3(154, 12, 12)})
    lab:addTo(self):pos(-20, 50):anchor(0.5, 0.5)

    --local lab = ui.newTTFLabel({text='-5', size=30, color={154, 12, 12}})
    --setPos(addChild(self.bg, lab), {0, 50})
    lab:runAction(createSequence({CCFadeIn:create(0.2), CCFadeOut:create(0.5), callfunc(removeSelf, lab)}))
    lab:runAction(createSequence({CCScaleTo:create(0.2, 2), CCScaleTo:create(0.2, 1) }) )
end

local function defaultDoHarm(self)
    local damage = 50
	self.health = self.health-damage
    updateBlood(self)
    floatText(self, damage)
end

function makeHarmable(obj)
	obj.doHarm = defaultDoHarm
end

local function defaultDoAttack(self)
	self.canAttack = true
end

local function findEnemy(self)
    self.oldTarget = self.target

    local dist = 99999
    local myPos = pack(self:getPosition())
    local minEne
    for k, v in ipairs(self.enemy) do
        local enePos = pack(v:getPosition())
        local ed = math.abs(enePos[1]-myPos[1])
        if ed < dist and not v.dead then
            dist = ed
            minEne = v
        end
        coroutine.yield()
    end
    self.target = minEne
end


--移动靠近目标
--接着播放砍杀动作
--接着跳跃回来
local function attackTarget(self)
    local mx, my = self:getPosition()
    local px, py = self.target:getPosition()

    local dir = Sign(mx-px)
    --print("self.name", self.name, dir)
    local offX = dir*50


    self:runAction(CCJumpTo:create(1, ccp(px+offX, py), 200, 1))
    waitForTime(self, 1)

    self.changeDirNode:getAnimation():play("attack", -1, -1, 0)

    self.attackOver = false
    while true do
        if self.attackOver then
            break
        end
        coroutine.yield()
    end
    self.target:doHarm(self.attack)
    self.changeDirNode:getAnimation():play("wait", -1, -1, 1)

    --> 0 则往回跳跃
    local oldS = self.changeDirNode:getScaleY()
    self.changeDirNode:setScaleX(oldS*dir)

    self:runAction(CCJumpTo:create(1, ccp(mx, my), 200, 1))
    waitForTime(self, 1)

    self.changeDirNode:setScaleX(oldS*-dir)
    
    --完成本回合攻击 发送消息给上层战斗管理器
    --或者该回合对方没有行动也会发送这个消息
    
end


function makeAttackable(obj)
	obj.doAttack = defaultDoAttack
	obj.findEnemy = findEnemy
    obj.attackTarget = attackTarget
end


local function handleDead(self)

    if self.dead then
        return
    end

    if self.health <= 0 then
        self.dead = true
        self.changeDirNode:getAnimation():play("death")
        local function onDead()
        end
        self.changeDirNode:runAction(createSequence({CCDelayTime:create(0.2), CCFadeOut:create(0.2), callfunc(onDead, nil)}))
    end
end


function makeDead(obj)
	obj.handleDead = handleDead
end


function addShadow(self)
    local shadow = display.newSprite("shadow.png"):anchor(0.5, 0.5)
    self:addChild(shadow)
    shadow:setZOrder(-1)
end

local function justDoAttack(self)
    adjustZord(self)
    while true do
         self:handleDead()
         if self.dead then
            break
        end
        if self.canAttack then
            self.canAttack = false
            if #self.enemy > 0 then
                self:findEnemy()
                if self.target ~= nil then
                    self:attackTarget()
                end
            end
            --攻击结束发送结束本回合信号
            Event:sendMsg("FINISH_ROUND") 
        end
        coroutine.yield()
    end
    
    --如果自己死亡了
    if self.canAttack then
        self.canAttack = false
        Event:sendMsg("FINISH_ROUND") 
    end
end



function setAttackProcess(obj)
    obj.attackProcess = coroutine.create(justDoAttack)
end




