local function findMoveAttack()
end

local AISoldier = class("AISoldier", function() return display.newNode() end)
function AISoldier:ctor(s, hid, pos)
	self.scene = s
	self.kind = hid
	self.name = math.random()
    self.health = 100
    self.attack = 5
    self.attackRange = 70
    self.position = pos

    self.enemy = self.scene.myTeam
    self.myTeam = self.scene.enemyTeam

	local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    local st = string.format("enemy_%d/enemy_%d.plist", hid, hid)
    spc:addSpriteFramesWithFile(st)
    local st = string.format("enemy_%d/enemy_%d.json", hid, hid)

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(st)
    self.changeDirNode = CCArmature:create("enemy_"..hid):addTo(self):scale(0.5)
    self.changeDirNode:getAnimation():setSpeedScale(0.25)
    self.changeDirNode:setScaleX(-0.5)

    registerAniEvent(self, self.changeDirNode)

    self.changeDirNode:getAnimation():play("wait", -1, -1, 1)

    registerUpdate(self)
    self.ok = true

    self.attackProcess = coroutine.create(findMoveAttack)
end

function AISoldier:update(diff)
    self.diff = diff
    if self.scene.state == 1 and self.ok then
        local res, err = coroutine.resume(self.attackProcess, self)
        if not res then
            print(err)
        end
        self.ok = res
    end
end

function AISoldier:onAttackOver()
    self.attackOver = true
end

return AISoldier