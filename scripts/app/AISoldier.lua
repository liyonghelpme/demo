--跳到对方面前进行攻击

--检查是否向前移动
local function checkWhetherMove(self)
    --后排
    local rep = {
        [1] = 3,
        [2] = 4,
    }
    if self.position == 1 or self.position == 2 then
        local empty = true
        for k, v in ipairs(self.myTeam) do
            --v 存活 且在 目标位置上面 则目标不为空
            if v.position == rep[self.position] and not v.dead then
                empty = false
                break
            end
        end
        --当前行的前排为空
        if empty then
            return true
        end
    end
    return false
end

--向前移动的时候 前面的位置需要锁定住 不能允许player 或者AIplayer放置新的士兵
local function tryToMoveForward(self)
    local rep = {
        [1] = 3,
        [2] = 4,
    }
    local tPos = rep[self.position]
    self.position = tPos

    local sx, sy = self:getPosition()
    local tx, ty = unpack(self.enemyPos[tPos])

    self.changeDirNode:getAnimation():play("run", -1, -1, 1)
    self:runAction(CCMoveTo:create(0.5, ccp(tx, ty)))
    waitForTime(self, 0.5)
    self.changeDirNode:getAnimation():play("wait", -1, -1, 1)
end


--canAttack 的时候判定向前移动
local function justDoAttack(self)
    adjustZord(self)
    while true do
         self:handleDead()
         if self.dead then
            break
        end
        if self.canAttack then
            self.canAttack = false
            --如果移动则先移动再攻击
            local needMove = checkWhetherMove(self)
            --需要移动则检测 等待时机是否到了 没有到则不要移动 否则先移动再攻击
            --移动之后
            if needMove then
                if self.countTime == nil then
                    self.countTime = 0
                end
                self.countTime = self.countTime+self.diff
                if self.countTime >= 3 then
                    tryToMoveForward(self)
                end
            else
                self.countTime = 0
            end

            if #self.enemy > 0 then
                self:findEnemy()
                if self.target ~= nil then
                    self:attackTarget()
                end
            end

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


local AISoldier = class("AISoldier", function() return display.newNode() end)
function AISoldier:ctor(s, hid, pos)
	self.scene = s
	self.kind = hid
	self.name = math.random()
    self.health = 100
    self.totalHealth = 100
    self.attack = 5
    self.attackRange = 70
    self.position = pos

    self.allPos = self.scene.enemyPos
    self.enemy = self.scene.myTeam
    self.myTeam = self.scene.enemyTeam


	local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    local st = string.format("enemy_%d/enemy_%d.plist", hid, hid)
    spc:addSpriteFramesWithFile(st)
    local st = string.format("enemy_%d/enemy_%d.json", hid, hid)

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(st)
    self.changeDirNode = CCArmature:create("enemy_"..hid):addTo(self):scale(SOL_SCALE)
    self.changeDirNode:getAnimation():setSpeedScale(0.25)
    self.changeDirNode:setScaleX(-SOL_SCALE)

    registerAniEvent(self, self.changeDirNode)

    self.changeDirNode:getAnimation():play("wait", -1, -1, 1)

    registerUpdate(self)
    self.ok = true
    self.canAttack = false

    

    --setAttackProcess(self)
    --士兵会在前方阵亡之后上
    self.attackProcess = coroutine.create(justDoAttack)
    --可攻击 可受伤 
    addBlood(self)
    addShadow(self)

    makeAttackable(self)
    makeHarmable(self)
    makeDead(self)
end

function AISoldier:update(diff)
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
function AISoldier:onAniEvent(me, t, s)
    if (t == 1 or t == 2) and s == 'attack' then
        self:onAttackOver()
    end
end

function AISoldier:onAttackOver()
    self.attackOver = true
end

--外部调用攻击
--[[
function AISoldier:doAttack()

    if self.health <= 0 then
        break
    end
    self.attackOver = false
    self.changeDirNode:getAnimation():play("attack")
    while true do
        if self.attackOver then
            --print("soldier attack over")
            break
        end
        coroutine.yield()
    end
    self.target:doHarm()
    --coroutine.yield()
end
--]]

return AISoldier