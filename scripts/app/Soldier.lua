--local 不会注册到全局名字空间 但是会注册到 本地的_Env 名字空间 
local function justDoAttack(self)
end


local Soldier = class("Soldier", function() return display.newNode() end)

function Soldier:ctor(s, hid, col, pos)
	print("soldier information", s, hid, col, pos)
	self.scene = s
	self.kind = hid
	self.col = col
	self.name = math.random()
	self.health = 100
	self.totalHealth = 100
	self.dead = false
	--决定士兵移动到什么位置 或者采用像素级别的碰撞render技术
	self.attackRange = 70
	self.attack = 5
	self.position = pos

	--轮到自己回合出手 则攻击之 攻击过程 以及攻击结束之后向外界发送一些消息
	--通过对象体触发的这些事件来实现 上层控制
	--同时上层保有当前进行战斗的对象的一些数据	

	--上层要做的是将这两个对象激活
	--无论是 canAttack 还是canDefense 需要激活两者的行为
	--动画的时机 designer 手动设置 还是程序自动判定
	--有简单的规则可以遵循的 来自动判定
	self.canAttack = false

	self.enemy = self.scene.enemyTeam
	self.myTeam = self.scene.myTeam

	local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    local st = string.format("userDogface_%d_3/userDogface_%d_3.plist", hid, hid)
    spc:addSpriteFramesWithFile(st)
    local st = string.format("userDogface_%d_3/userDogface_%d_3.json", hid, hid)
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(st)
    self.changeDirNode = CCArmature:create("userDogface_"..hid.."_3")
    self:addChild(self.changeDirNode)
    self.changeDirNode:scale(0.5):getAnimation():setSpeedScale(0.5)
    
    registerAniEvent(self, self.changeDirNode)
    self.changeDirNode:getAnimation():play("wait")

    registerUpdate(self)

    self.attackProcess = coroutine.create(justDoAttack)
    self.ok = true
end

--也可以在触发战斗的时候需要等待上一个 progress结束才能进行下一个progress
--actionList progresslist
--AI 本身组织在行为树里面
function Soldier:update(diff)
	self.diff = diff
	if self.scene.state == 1 and self.ok then 
		local res, err = coroutine.resume(self.attackProcess, self)
		if not res then
			print(err)
			self.ok = res
		end
	end
end

function Soldier:onAniEvent(me, t, s)
	if s == 'attack' and (t == 1 or t == 2) then
		self:onAttackOver()
	end
end

function Soldier:onAttackOver()
	self.attackOver = true
end



return Soldier


