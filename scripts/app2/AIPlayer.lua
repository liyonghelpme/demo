local AISoldier = require("app.AISoldier")

local function putSoldier(self, allEnemy)

    local vs = getVS()
    local mh = vs.height/2
    while true do
        waitForTime(self, 1)
        if #allEnemy > 0 then
        	print("allEnemy", json.encode(allEnemy))
            --local rd = math.random(#allEnemy)
            local freePos = 1
            for i=1, 4, 1 do
                local ok = true
                for k, v in ipairs(self.scene.enemyTeam) do
                    if not v.dead and v.position == i then
                        ok = false
                        break
                    end
                end
                if ok then
                    freePos = i
                    break
                else
                    freePos = nil
                end
            end
            
            if freePos == nil then
                break
            else
                local rd = 1
                local it = allEnemy[rd]
                table.remove(allEnemy, rd)

                local ai = AISoldier.new(self.scene, it, freePos)
                --addChild(self.scene.solLayer, ai.bg)
                self.scene.solLayer:addChild(ai)

                --[[
                local pos = {
                    {800-150, 240-50},
                    {800-150, 240+50},
                    {800-250, 240-50},
                    {800-250, 240+50},
                }
                --]]

                local pos = {
					{960-109, 240-50},
					{960-109, 240+50},
					{960-290, 240-50},
					{960-290, 240+50},

				}

                --setPos(ai.bg, pos[freePos])
                ai:setPosition(ccp(pos[freePos][1], pos[freePos][2]))

                table.insert(self.scene.enemyTeam, ai)

            end
        end
        coroutine.yield()
        --break
    end
end


local function think(self)
    local allEnemy = {1, 9, 10, 11, 14, 15, 16}

    lastId = 0
    while true do
        putSoldier(self, allEnemy)
        if self.myTurn then
            self.myTurn = false
            lastId = lastId%#self.myTeam

            local findLive = false
            local findSol = nil
            print("myTeam", #self.myTeam)

            for i=0, #self.myTeam-1, 1 do
                local nid = (lastId+i)%#self.myTeam+1
                local sol = self.myTeam[nid]
                if not sol.dead then
                    lastId = nid
                    findLive = true
                    findSol = sol
                    break
                end
            end
            
            print("findLive", findLive, findSol)
            if findLive then
                print("name", findSol.name)
                --设置当前战斗对象
                self.scene:setCurSol(findSol)
                findSol:doAttack()
            else
                self.scene:setCurSol(nil)
            end
        end
        coroutine.yield()
    end
end


local AIPlayer = class("AIPlayer", function() return display.newNode() end)
function AIPlayer:ctor(s)
	self.scene = s
	self.myTeam = self.scene.enemyTeam
	self.myTurn = false
	self.events = {"NEXT_ROUND"}

	registerUpdate(self)
	registerEnterOrExit(self)

	self.ok = true
	self.think = coroutine.create(think)
end


--判定当前自己是否可以响应操作
function AIPlayer:receiveMsg(msg, arg)
	if msg == "NEXT_ROUND" then
		if self.scene.roundId % 2 == 1 then
			self.myTurn = true
        else
            self.myTurn = false
		end
	end
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

return AIPlayer