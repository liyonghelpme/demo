local Hero = require("app.Hero")
local Player = require "app.Player"
local AIPlayer = require "app.AIPlayer"
local AIHero = require("app.AIHero")


local function battleProgress(self)
end

local MainLayer = class("MainLayer", function ()
	return display.newLayer()
end)

function MainLayer:ctor(sc)
	self.scene = sc
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
end

function MainLayer:update(diff)
	self.diff = diff
	if self.ok then
		local res, err = coroutine.resume(self.attackProcess)
		if not res then
			print(err)
			self.ok = res
		end
	end
end




return MainLayer