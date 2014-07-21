require "Demo.BattleMenu"
require "Demo.Hero2"
require "Demo.mycor"
require "Demo.EnemyHero"
require "Demo.AIPlayer"
require("Demo.MainUI")

BattleScene = class()
function BattleScene:ctor()
    self.bg = CCScene:create()
    self.layer = BattleLayer.new()
    addChild(self.bg, self.layer.bg)
end

local function battleProgress(self)
    local vs = getVS()
    local la = ui.newTTFLabel({text="3", size=100, color={42, 154, 12}})
    setPos(addChild(self.bg, la), {vs.width/2, vs.height/2})
    la:setOpacity(255)
    la:runAction(sequence({fadein(0.5), fadeout(0.5)}))
    waitForTime(self, 1)
    
    --[[
    la:setString("2")
    la:runAction(sequence({fadein(0.5), fadeout(0.5)}))
    waitForTime(self, 1)

    la:setString("1")
    la:runAction(sequence({fadein(0.5), fadeout(0.5)}))
    waitForTime(self, 1)
    --]]

    self.state = 1
end


BattleLayer = class()
function BattleLayer:ctor()
    self.name = "BattleLayer"

    self.bg = CCLayer:create()
    self.aiPlayer = AIPlayer.new(self)
    addChild(self.bg, self.aiPlayer.bg)

    local ds = global.director.designSize

    local sp = CCSprite:create("bbg_cave_hall.jpg")
    local vs = getVS()
    setPos(addChild(self.bg, sp), {vs.width/2, vs.height/2})
    local sca = math.max(vs.width/ds[1], vs.height/ds[2])
    setScale(sp, sca)

    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    spc:addSpriteFramesWithFile("userRole/userRole.plist")

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("userRole/userRole.json")

    self.solLayer = addChild(self.bg, CCNode:create())
    centerTemp(self.solLayer)

    
    --[[
    local hero = CCArmature:create("userRole")
    hero:getAnimation():playWithIndex(0)
    self.bg:addChild(hero)
    setPos(hero, {88, vs.height-134})
    hero:setScale(0.5)
    self.hero = hero
    --]]


    self.myTeam = {}
    self.enemyTeam = {}

    self.hero = Hero.new(self, 0)
    setPos(addChild(self.solLayer, self.hero.bg), {88, ds[2]/2})
    table.insert(self.myTeam, self.hero)

    self.enemy = EnemyHero.new(self, 1)
    setPos(addChild(self.solLayer, self.enemy.bg), {ds[1]-88, ds[2]/2})
    table.insert(self.enemyTeam, self.enemy)
    
    --[[
    spc:addSpriteFramesWithFile("enemy_1/enemy_1.plist")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("enemy_1/enemy_1.json")
    local enemy = CCArmature:create("enemy_1")
    enemy:getAnimation():playWithIndex(0)
    self.bg:addChild(enemy)
    setPos(enemy, {vs.width-88, vs.height-134})
    enemy:setScale(0.5)
    enemy:setScaleX(-0.5)
    --]]

    self.state = 0

    self.needUpdate = true
    self.inTouch = false
    self.touchCount = 0

    --registerMultiTouch(self)
    self.bg:setTouchPriority(256)
    registerTouch(self, 10)
    registerEnterOrExit(self)
    
    self.co = coroutine.create(battleProgress)

    self.updateInfo = coroutine.create(updateInfo)

    --self.menu = BattleMenu.new(self)
    --addChild(self.bg, self.menu.bg)

    self.menu = MainUI.new(self):addTo(self.bg)


    --self.touchValue = {count=0}
end

function updateInfo(self)
    while true do
        print("myt", #self.myTeam, #self.enemyTeam)
        waitForTime(self, 1)
    end
end

-- 参考miaomiao中的处理 standardTouchDelegate
function BattleLayer:touchesBegan(touches)
    print("multitouch")
    self.inTouch = true
    local _, temp2 = convertMultiToArr(touches)
    updateTouchTable(a, b)
end
function BattleLayer:touchesMoved(touches)
end

function BattleLayer:touchesEnded(touches)
end


function BattleLayer:touchBegan(x, y)
    print("touch began")
    self.inTouch = true
    self.touchPos = {x, y}
    return true
end
function BattleLayer:touchMoved(x, y)
    self.touchPos = {x, y}
end
function BattleLayer:touchEnded(x, y)
    print("touch ended")
    self.inTouch = false
end
function BattleLayer:touchCancel(x, y)
end



function BattleLayer:update(diff)
    --[[
    local cap = self.bg:isTouchCaptureEnabled()
    print("caputure touch", cap)
    local box = self.bg:getCascadeBoundingBox()
    print("cab", box.origin.x, box.origin.y, box.size.width, box.size.height)
    --]]

    self.diff = diff
    local res, err = coroutine.resume(self.co, self)    

    local res, err = coroutine.resume(self.updateInfo, self)
    if not res then
        print(err)
    end
end



