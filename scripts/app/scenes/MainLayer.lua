local Hero = require("app.Hero")
local Player = require "app.Player"
local AIPlayer = require "app.AIPlayer"
local AIHero = require("app.AIHero")


local function battleProgress(self)
	self.roundId = 0
	Event:sendMsg("NEXT_ROUND")
	while true do
		--waitForMsg(self, "FINISH_ROUND")
		waitForTime(self, 0.5)
		--如果AI 或者 Player 选择了攻击角色则 开始攻击否则 进入下一回合
		if self.curSol ~= nil then
			waitForMsg(self, "FINISH_ROUND")
		end


		self.roundId = self.roundId+1
		self.curSol = nil
		Event:sendMsg("NEXT_ROUND")
		coroutine.yield()
	end
end

local MainLayer = class("MainLayer", function ()
	return display.newLayer()
end)

function MainLayer:ctor(sc)
	self.scene = sc
	math.randomseed(0)

	self.myPos = {
	{109, 240-50},
	{109, 240+50},
	{290, 240-50},
	{290, 240+50},
	}

	self.enemyPos = {
	{960-109, 240-50},
	{960-109, 240+50},
	{960-290, 240-50},
	{960-290, 240+50},
	}

	local mx = CONFIG_SCREEN_WIDTH/2
	local my = CONFIG_SCREEN_HEIGHT/2
	local vs = getVS()

	local bg = display.newSprite("bbg_cave_hall.jpg")
	bg:addTo(self):pos(vs.width/2, vs.height/2)
	local sca = math.max(vs.width/CONFIG_SCREEN_WIDTH, vs.height/CONFIG_SCREEN_HEIGHT) 
    bg:scale(sca)


	registerUpdate(self)

	self.myTeam = {}
	self.enemyTeam = {}

	--两个思考者
	self.player = Player.new(self)
	self.player:addTo(self)

	self.aiPlayer = AIPlayer.new(self)
	self.aiPlayer:addTo(self)

	self.solLayer = display.newNode():addTo(self)
	midLayer(self.solLayer)
	


	local hero = Hero.new(self):addTo(self.solLayer):pos(214, 240)
	table.insert(self.myTeam, hero)

	local ds = getDS()
	local aiHero = AIHero.new(self):addTo(self.solLayer):pos(ds[1]-214, 240)
	table.insert(self.enemyTeam, aiHero)

	self.state = 1
	self.attackProcess = coroutine.create(battleProgress)
	self.ok = true

	self.events = {"FINISH_ROUND"}
	registerEnterOrExit(self)
end

function MainLayer:receiveMsg(msg, arg)
	if msg == "FINISH_ROUND" then
		self.FINISH_ROUND = true
	end
end
function MainLayer:setCurSol(s)
	self.curSol = s
end


function MainLayer:update(diff)
	self.diff = diff
	if self.ok then
		local res, err = coroutine.resume(self.attackProcess, self)
		if not res then
			print(err)
			self.ok = res
		end
	end
end




return MainLayer