local function think(self)
    while self.scene.state ~= 1 do
        coroutine.yield()
    end
    
    local lastId = 0

    while true do
        --print("begin to think", self.myTurn)
        if self.myTurn then
            self.myTurn = false
            lastId = lastId%#self.scene.myTeam

            local findLive = false
            local findSol 
            for i=0, #self.scene.myTeam-1, 1 do
                local nid = (lastId+i)%#self.scene.myTeam+1
                local sol = self.scene.myTeam[nid]
                if not sol.dead then
                    lastId = nid
                    findLive = true
                    findSol = sol
                    break
                end
            end
            print("doAttack ", findLive)
            --print("findLive", findLive, findSol)
            if findLive then
                --self.scene.curSol
                self.scene:setCurSol(findSol)
                findSol:doAttack()
            end
        end
        coroutine.yield()
    end
    
end


--管理用户的行为
--用户动作回合
local Player = class("Player", function() return display.newNode()end)
function Player:ctor(s)
	self.scene = s
	registerUpdate(self)
	self.events = {"NEXT_ROUND"}

	registerEnterOrExit(self)
	self.myTurn = false
	self.ok = true
	self.thinkProcess = coroutine.create(think)
end


function Player:receiveMsg(msg, arg)
    --Playerprint("receiveMsg", msg, self.scene.roundId)
    if msg == "NEXT_ROUND" then
        if self.scene.roundId % 2 == 0 then
            print("setMyTurn")
            self.myTurn = true
        else
            self.myTurn = false
        end
    end
end


function Player:update(diff)
    if self.ok then
        local res, err = coroutine.resume(self.thinkProcess, self)
        if not res then
            print(err)
        end
        self.ok = res
    end
end


return Player