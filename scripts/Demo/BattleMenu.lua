require "Demo.Soldier"
require "Demo.CureSoldier"

local function updateItem(self, diff)
    self.curTime = self.curTime+diff
    local rate = math.min(math.max((self.totalTime-self.curTime)/self.totalTime, 0), 1)

    self.mask:setTextureRect(CCRectMake(0, 0, 78, 78*rate))
end

local function createItem(self, p)
    print("init Button")
    local it1 = ui.newButton({image="101.jpg", delegate=self, callback=self.onBut, param=p}) 
    setPos(addChild(self.bg, it1.bg), {84, 65})

    local mask1 = createSprite("mask.png")
    it1.bg:addChild(mask1)
    it1.mask = mask1
    setPos(setAnchor(it1.mask, {0.5, 0}), {0, -39})

    it1.updateFunc = updateItem
    it1.totalTime = 1
    it1.curTime = 0

    return it1
end


BattleMenu = class()

function BattleMenu:onResume()
    global.director:replaceScene(BattleScene.new())
end

function BattleMenu:ctor(sc)
    self.scene = sc


    local vs = getVS()
    
    self.bg = CCLayer:create()

    local but = ui.newButton({text="重新开始", size=50, color={0, 0, 0}, image="round.png", delegate=self, callback=self.onResume})
    setPos(addChild(self.bg, but.bg), {50, 150})

    local it1 = createItem(self, 1)
    local it2 = createItem(self, 2)
    setPos(it2.bg, {84+94, 65})
    local it3 = createItem(self, 3)
    setPos(it3.bg, {84+94+94, 65})

    self.allBtns = {it1, it2, it3}

    --first three is three button heros 
    self.myteamList = {1, 2, 3, 4, 5, 6, 7}
    
    self.lastId = 0

    local blood = createSprite("blood.png")
    self.blood1 = blood
    setAnchor(setPos(addChild(self.bg, blood), {50, vs.height-40}), {0, 0.5})

    local blood = createSprite("blood.png")
    self.blood2 = blood
    setAnchor(setPos(addChild(self.bg, blood), {vs.width-50, vs.height-40}), {1, 0.5})


    local time = ui.newBMFontLabel({text="3:00", font="bound.fnt", size=30, color={10, 10, 10}})
    setPos(addChild(self.bg, time), {vs.width/2, vs.height-40})

    local star1 = setPos(addChild(self.bg, createSprite("star.png")), {vs.width/2-50, vs.height-80})
    local star2 = setPos(addChild(self.bg, createSprite("star.png")), {vs.width/2, vs.height-80})
    local star3 = setPos(addChild(self.bg, createSprite("star.png")), {vs.width/2+50, vs.height-80})
    self.star = {star1, star2, star3}


    self.needUpdate = true
    self.events = {"HERO_DAMAGE"}
    registerEnterOrExit(self)
end

function BattleMenu:receiveMsg(eve, arg)
    if eve == 'HERO_DAMAGE' then
        if arg.color == 0 then
            local rate = arg.health/arg.totalHealth
            rate = math.min(math.max(rate, 0), 1)
            self.blood1:setTextureRect(CCRectMake(0, 0, 128*rate, 24))
        else
            local rate = arg.health/arg.totalHealth
            rate = math.min(math.max(rate, 0), 1)
            self.blood2:setTextureRect(CCRectMake(128*(1-rate), 0, 128*rate, 24))
        end
    elseif eve == "HERO_DEAD" then
        if arg.color == 0 then
        else
            local lab = ui.newTTFLabel({text="你获胜了!", size=50, color={216, 219, 2}})
            local vs = getVS()
            setPos(addChild(self.bg, lab), {vs.width/2, vs.height/2})
        end
    end
end


function BattleMenu:update(diff)
    if self.scene.state == 1 then
        for k, v in ipairs(self.allBtns) do
            v:updateFunc(diff)
        end
    end
end


function BattleMenu:onBut(p)
    print("onSoldierButton ", p, #self.allBtns)
    local item = self.allBtns[p]
    if item == nil then
        return
    end

    print("on Soldier", item.curTime, item.totalTime, #self.myteamList, p)
    --随机士兵列表
    if item.curTime >= item.totalTime and #self.myteamList >= p then
        local hid = self.myteamList[p]
        table.remove(self.myteamList, p)
        local body
        if hid == 4 then
            body = CureSoldier.new(self.scene, hid, 0)             
        else
            body = Soldier.new(self.scene, hid, 0)             
        end
        addChild(self.scene.solLayer, body.bg)
        local vs = getVS()
        local ds = global.director.designSize
        local mh = ds[2]/2
        
        if self.lastId == 0 then
            setPos(body.bg, {130, mh-50})
        elseif self.lastId == 1 then
            setPos(body.bg, {130, mh})
        else
            setPos(body.bg, {130, mh+50})
        end

        item.curTime = 0

        self.lastId = self.lastId+1
        self.lastId = self.lastId%3
        
        --according to left soldier number adjust button state
        --[[
        for i=3, 1, -1 do
            if #self.myteamList < i then
            end
        end
        --]]
        item.sp:runAction(fadeout(0.5))
        for i=p+1, #self.allBtns, 1 do
            local it = self.allBtns[i]
            it.bg:runAction(sequence({moveby(0.7, -94, 0)}))
        end
        local tempBtn = {}
        for i=1, p-1, 1 do
            table.insert(tempBtn, self.allBtns[i])
        end

        for i=p+1, #self.allBtns, 1 do
            self.allBtns[i]:setParam(i-1)
            table.insert(tempBtn, self.allBtns[i])
        end
        self.allBtns = tempBtn
        
        --totalNumber > 3 add one 
        if #self.myteamList > #self.allBtns then
            print("add New Button ")
            local it = createItem(self, 3)
            setPos(it.bg, {84+94+94, 65})
            table.insert(self.allBtns, it)
            it.sp:runAction(fadein(1))
        end

        table.insert(self.scene.myTeam, body)

    else
        print("not ready or p > totalLen")
    end

    --[[
    if p == 1 then
    elseif p == 2 then

    elseif p == 3 then
    end
    --]]
end

