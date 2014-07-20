require "Demo.AISoldier"
--检查自己有多少士兵
--检查冷却时间
--随机抽取一个士兵放置出来
local function think(self)
    local allEnemy = {1, 9, 10, 11, 14, 15, 16}
    local allItem = {}
    for k, v in ipairs(allEnemy) do
        local item = {curTime=0, totalTime=1}
        table.insert(allItem, item)
    end
    
    self.lastId = 0
    local vs = getVS()
    local ds = global.director.designSize
    local mh = ds[2]/2

    while true do
        waitForTime(self, 1)
        if #allEnemy > 0 then
            --local rd = math.random(#allEnemy)
            local rd = 1
            local it = allEnemy[rd]
            table.remove(allEnemy, rd)
            local ai = AISoldier.new(self.scene, it)
            addChild(self.scene.solLayer, ai.bg)
            if self.lastId == 0 then
                setPos(ai.bg, {vs.width-130, mh-50})
            elseif self.lastId == 1 then
                setPos(ai.bg, {vs.width-130, mh})
            else
                setPos(ai.bg, {vs.width-130, mh+50})
            end

            table.insert(self.scene.enemyTeam, ai)

            self.lastId = self.lastId+1
            self.lastId = self.lastId%3
        end
        coroutine.yield()
        --break
    end
end


AIPlayer = class()
function AIPlayer:ctor(s)
    self.scene = s

    self.bg = CCNode:create()
    self.needUpdate = true
    registerEnterOrExit(self)

    self.ok = true

    self.think = coroutine.create(think)
end

function AIPlayer:update(diff)
    self.diff = diff

    if self.scene.state == 1 and self.ok then
        local res, err = coroutine.resume(self.think, self)
        if not res then
            print(err)
        end
        self.ok = res
    end
end

