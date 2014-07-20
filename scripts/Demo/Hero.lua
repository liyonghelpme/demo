--Actor 模式通过MessageCenter 来发送消息和接受消息
--cps  COMMUNICATION PROGRESS SYSTEM

ACTOR_STATE = {
    WAIT = 0,
    ATTACK = 1,
}

--层叠状态机模型
local function frameEvent(fe)
    print('frameEvent', fe)
end


local function testMove(self)
     
end


--随机攻击一个目标
--攻击一个英雄直到攻击到死么? 每次攻击随机一个对象
local function findTargetAndAttack(self)
    --随机找到一个目标攻击
    local enemy 
    if self.color == 0 then
        enemy = self.scene.enemyTeam
    else
        enemy = self.scene.myTeam
    end

    while true do
        if #enemy > 0 then
            local rd = math.random(#enemy)
            self.target = enemy[rd]

            self.attackOver = false
            self.changeDirNode:getAnimation():play("attack")
            while true do
                if self.attackOver then
                    break
                end
                coroutine.yield()
            end
            --print("play wait animation")
            self.changeDirNode:getAnimation():play("wait")
            
            self.target:doHarm()
        end
        coroutine.yield()
    end
end


Hero = class()
--color 0 我方 1 敌方
function Hero:ctor(s, col)
    self.color = col
    self.scene = s
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
    self.changeDirNode:getAnimation():setFrameEventCallFunc(frameEvent)

    self.changeDirNode:getAnimation():playWithIndex(0)
    self.changeDirNode:getAnimation():setSpeedScale(0.5)



    self.target = nil

    self.needUpdate = true
    registerEnterOrExit(self)

    self.state =  ACTOR_STATE.WAIT
    self.passTime = 0
    self.health = 100
    self.totalHealth = 100

    self.attackProcess = coroutine.create(findTargetAndAttack)
end



function Hero:update(diff)
    if self.scene.state == 1 then
        if self.state == ACTOR_STATE.WAIT then
            self.state = ACTOR_STATE.ATTACK
        end
    end

    if self.state == ACTOR_STATE.ATTACK then
        coroutine.resume(self.attackProcess, self)  
    end

end

function Hero:onAttackOver()
    self.attackOver = true
end

function Hero:doHarm()
    local lab = ui.newTTFLabel({text='5', size=30, color={154, 12, 12}})
    setPos(addChild(self.bg, lab), {0, 50})
    lab:runAction(sequence({fadein(0.2), fadeout(0.2), callfunc(nil, removeSelf, lab)}))

    self.health = self.health-5

    Event:sendMsg("HERO_DAMAGE", self)
end




